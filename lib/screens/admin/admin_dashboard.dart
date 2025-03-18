// admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../bloc/alert/alert_bloc.dart';
import '../../bloc/sos/sos_bloc.dart';
import '../../bloc/warehouse/warehouse_bloc.dart';
import '../../bloc/connectivity/connectivity_bloc.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/warehouse_card.dart';
import '../common/profile_screen.dart';
import 'alerts_map_screen.dart';
import 'warehouse_management.dart';
import 'resource_allocation.dart';

class AdminDashboard extends StatefulWidget {
  final User currentUser;

  const AdminDashboard({
    super.key,
    required this.currentUser,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Load data when screen initializes
    _loadData();
  }
  
  // Load all necessary data
  void _loadData() {
    // Load alerts
    context.read<AlertBloc>().add(const AlertsStarted(isAdmin: true));
    
    // Load SOS requests
    context.read<SosBloc>().add(
      SosLoadRequests(
        userId: widget.currentUser.id,
        isAdmin: true,
      ),
    );
    
    // Load warehouses
    context.read<WarehouseBloc>().add(const WarehousesStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, connectivityState) {
        // Show offline banner if disconnected
        final bool isOffline = connectivityState is ConnectivityDisconnected;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Navigate to alerts management
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlertsMapScreen(
                        currentUser: widget.currentUser,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
              ),
            ],
          ),
          body: Stack(
            children: [
              // Main content
              _buildSelectedScreen(),
              
              // Offline banner
              if (isOffline)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.wifi_off,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You are offline. Some features may be limited.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: _selectedIndex == 0
              ? FloatingActionButton(
                  onPressed: () {
                    // Create a new alert or resource
                    _showCreateMenu(context);
                  },
                  child: const Icon(Icons.add),
                )
              : null,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2),
                label: 'Resources',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Show create menu
  void _showCreateMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.warning_amber),
            title: const Text('Create Alert'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to create alert screen
              // For hackathon, we're just showing a mock dialog
              _showCreateAlertDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Add Warehouse'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to create warehouse screen
              // For hackathon, we're just showing a mock dialog
              _showCreateWarehouseDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Add Resources'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to resource management
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResourceAllocationScreen(
                    currentUser: widget.currentUser,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  // Show create alert dialog
  void _showCreateAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Alert'),
        content: const Text('This would open the create alert form.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  // Show create warehouse dialog
  void _showCreateWarehouseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Warehouse'),
        content: const Text('This would open the add warehouse form.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  // Build the selected screen based on bottom navigation
  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardScreen();
      case 1:
        return AlertsMapScreen(currentUser: widget.currentUser);
      case 2:
        return WarehouseManagementScreen(currentUser: widget.currentUser);
      case 3:
        return ProfileScreen(currentUser: widget.currentUser);
      default:
        return _buildDashboardScreen();
    }
  }
  
  // Build the dashboard screen content
  Widget _buildDashboardScreen() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Text(
              'Welcome, ${widget.currentUser.name}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            
            // Stats overview
            _buildStatsOverview(),
            const SizedBox(height: 24),
            
            // Active SOS requests
            _buildSosRequestsSection(),
            const SizedBox(height: 24),
            
            // Active alerts
            _buildAlertsSection(),
            const SizedBox(height: 24),
            
            // Warehouses
            _buildWarehousesSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  // Build stats overview
  Widget _buildStatsOverview() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          icon: Icons.warning_amber,
          iconColor: Colors.orange,
          title: 'Active Alerts',
          value: _getActiveAlertsCount().toString(),
        ),
        _buildStatCard(
          icon: Icons.sos,
          iconColor: Colors.red,
          title: 'SOS Requests',
          value: _getPendingSosCount().toString(),
        ),
        _buildStatCard(
          icon: Icons.store,
          iconColor: Colors.blue,
          title: 'Warehouses',
          value: _getWarehousesCount().toString(),
        ),
        _buildStatCard(
          icon: Icons.inventory_2,
          iconColor: Colors.green,
          title: 'Low Stock Items',
          value: _getLowStockCount().toString(),
        ),
      ],
    );
  }
  
  // Build stat card
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  // Build SOS requests section
  Widget _buildSosRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SOS Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to SOS management
              },
              child: const Text('View All'),
            ),
          ],
        ),
        BlocBuilder<SosBloc, SosState>(
          builder: (context, state) {
            if (state is SosLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is SosRequestsLoaded) {
              final requests = state.requests
                  .where((req) => req.status == 'pending')
                  .toList();
              
              if (requests.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text('No pending SOS requests'),
                    ),
                  ),
                );
              }
              
              // Show max 3 requests on dashboard
              final displayRequests = requests.take(3).toList();
              
              return Column(
                children: displayRequests.map((request) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.red, width: 1),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(Icons.sos, color: Colors.white),
                      ),
                      title: Text(request.type),
                      subtitle: Text(
                        request.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: OutlinedButton(
                        onPressed: () {
                          // Show SOS details
                        },
                        child: const Text('Respond'),
                      ),
                    ),
                  );
                }).toList(),
              );
            } else {
              return const Center(
                child: Text('Failed to load SOS requests'),
              );
            }
          },
        ),
      ],
    );
  }
  
  // Build alerts section
  Widget _buildAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Alerts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to alerts management
              },
              child: const Text('View All'),
            ),
          ],
        ),
        BlocBuilder<AlertBloc, AlertState>(
          builder: (context, state) {
            if (state is AlertLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is AlertsLoaded) {
              final activeAlerts = state.alerts
                  .where((alert) => alert.active)
                  .toList();
              
              if (activeAlerts.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text('No active alerts'),
                    ),
                  ),
                );
              }
              
              // Show max 2 alerts on dashboard
              final displayAlerts = activeAlerts.take(2).toList();
              
              return Column(
                children: displayAlerts.map((alert) {
                  return AlertCard(
                    alert: alert,
                    onTap: () {
                      // Show alert details
                    },
                    onViewMap: () {
                      // Navigate to map with this alert
                    },
                  );
                }).toList(),
              );
            } else {
              return const Center(
                child: Text('Failed to load alerts'),
              );
            }
          },
        ),
      ],
    );
  }
  
  // Build warehouses section
  Widget _buildWarehousesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Warehouses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to warehouse management
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WarehouseManagementScreen(
                      currentUser: widget.currentUser,
                    ),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        BlocBuilder<WarehouseBloc, WarehouseState>(
          builder: (context, state) {
            if (state is WarehouseLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is WarehousesLoaded) {
              final warehouses = state.warehouses;
              
              if (warehouses.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text('No warehouses available'),
                    ),
                  ),
                );
              }
              
              // Show max 2 warehouses on dashboard
              final displayWarehouses = warehouses.take(2).toList();
              
              return Column(
                children: displayWarehouses.map((warehouse) {
                  return WarehouseCard(
                    warehouse: warehouse,
                    onTap: () {
                      // Show warehouse details
                    },
                    onViewMap: () {
                      // Navigate to map with this warehouse
                    },
                    onManage: () {
                      // Navigate to manage warehouse
                    },
                  );
                }).toList(),
              );
            } else {
              return const Center(
                child: Text('Failed to load warehouses'),
              );
            }
          },
        ),
      ],
    );
  }
  
  // Helper methods to get counts for stats
  int _getActiveAlertsCount() {
    final alertState = context.read<AlertBloc>().state;
    if (alertState is AlertsLoaded) {
      return alertState.alerts.where((alert) => alert.active).length;
    }
    return 0;
  }
  
  int _getPendingSosCount() {
    final sosState = context.read<SosBloc>().state;
    if (sosState is SosRequestsLoaded) {
      return sosState.requests.where((req) => req.status == 'pending').length;
    }
    return 0;
  }
  
  int _getWarehousesCount() {
    final warehouseState = context.read<WarehouseBloc>().state;
    if (warehouseState is WarehousesLoaded) {
      return warehouseState.warehouses.length;
    }
    return 0;
  }
  
  int _getLowStockCount() {
    final warehouseState = context.read<WarehouseBloc>().state;
    if (warehouseState is WarehousesLoaded) {
      int count = 0;
      for (final warehouse in warehouseState.warehouses) {
        count += warehouse.resources.where((r) => r.isLowStock).length;
      }
      return count;
    }
    return 0;
  }
}