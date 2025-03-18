// civilian_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../bloc/alert/alert_bloc.dart';
import '../../bloc/connectivity/connectivity_bloc.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/sos_button.dart';
import 'sos_screen.dart';
import 'alerts_screen.dart';
import '../common/map_screen.dart';
import '../common/profile_screen.dart';
import '../common/settings_screen.dart';

class CivilianHomeScreen extends StatefulWidget {
  final User currentUser;

  const CivilianHomeScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<CivilianHomeScreen> createState() => _CivilianHomeScreenState();
}

class _CivilianHomeScreenState extends State<CivilianHomeScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Load alerts when screen initializes
    context.read<AlertBloc>().add(const AlertsStarted(isAdmin: false));
  }
  
  // Navigate to SOS screen
  void _navigateToSosScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SosScreen(currentUser: widget.currentUser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, connectivityState) {
        // Show offline banner if disconnected
        final bool isOffline = connectivityState is ConnectivityDisconnected;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Disaster Management'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Navigate to notifications or alerts history
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlertsScreen(currentUser: widget.currentUser),
                    ),
                  );
                },
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
          // SOS button
          floatingActionButton: _selectedIndex == 0
              ? SosButton(
                  onPressed: _navigateToSosScreen,
                  size: 80,
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items:  [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Build the selected screen based on bottom navigation
  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return MapScreen(
          initialLatitude: widget.currentUser.latitude ?? 0.0,
          initialLongitude: widget.currentUser.longitude ?? 0.0,
          initialZoom: 12.0,
        );
      case 2:
        return ProfileScreen(currentUser: widget.currentUser);
      case 3:
        return SettingsScreen(currentUser: widget.currentUser);
      default:
        return _buildHomeScreen();
    }
  }
  
  // Build the home screen content
  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Extra bottom padding for SOS button
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Welcome, ${widget.currentUser.name}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          
          // Active alerts section
          const Text(
            'Active Alerts in Your Area',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Alerts list
          BlocBuilder<AlertBloc, AlertState>(
            builder: (context, state) {
              if (state is AlertLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is AlertsLoaded) {
                // Filter only active alerts
                final activeAlerts = state.alerts
                    .where((alert) => alert.active)
                    .toList();
                
                if (activeAlerts.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 48,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No active alerts in your area',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Stay safe and be prepared',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // Show max 3 alerts on home screen
                final displayAlerts = activeAlerts.take(3).toList();
                
                return Column(
                  children: [
                    for (final alert in displayAlerts)
                      AlertCard(
                        alert: alert,
                        onTap: () {
                          // Navigate to alert details
                          // This could show more info or directions
                        },
                        onViewMap: () {
                          // Navigate to map with this alert highlighted
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(
                                initialLatitude: alert.latitude,
                                initialLongitude: alert.longitude,
                                initialZoom: 14.0,
                                markers: {
                                  alert.id: {
                                    'latitude': alert.latitude,
                                    'longitude': alert.longitude,
                                    'title': alert.title,
                                    'snippet': alert.description,
                                    'type': 'alert',
                                    'severity': alert.severity,
                                  },
                                },
                                circles: {
                                  alert.id: {
                                    'latitude': alert.latitude,
                                    'longitude': alert.longitude,
                                    'radius': alert.radius * 1000, // Convert km to meters
                                    'fillColor': Colors.red.withOpacity(0.2),
                                    'strokeColor': Colors.red,
                                    'strokeWidth': 2,
                                  },
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    
                    // Show "View All" button if there are more alerts
                    if (activeAlerts.length > 3)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlertsScreen(
                                currentUser: widget.currentUser,
                              ),
                            ),
                          );
                        },
                        child: const Text('View All Alerts'),
                      ),
                  ],
                );
              } else if (state is AlertError) {
                return Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AlertBloc>().add(
                                const AlertsStarted(isAdmin: false),
                              );
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: Text('No alerts available'),
                );
              }
            },
          ),
          
          const SizedBox(height: 24),
          
          // Emergency resources section
          const Text(
            'Emergency Resources',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Emergency resources cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildResourceCard(
                icon: Icons.medical_services,
                title: 'Medical Centers',
                onTap: () {
                  // Navigate to medical centers map or list
                },
              ),
              _buildResourceCard(
                icon: Icons.local_fire_department,
                title: 'Fire Stations',
                onTap: () {
                  // Navigate to fire stations map or list
                },
              ),
              _buildResourceCard(
                icon: Icons.local_police,
                title: 'Police Stations',
                onTap: () {
                  // Navigate to police stations map or list
                },
              ),
              _buildResourceCard(
                icon: Icons.store,
                title: 'Relief Centers',
                onTap: () {
                  // Navigate to relief centers map or list
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Emergency contacts section
          const Text(
            'Emergency Contacts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Emergency contacts list
          Card(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildContactTile(
                  icon: Icons.call,
                  title: 'Emergency Hotline',
                  subtitle: '911',
                  onTap: () {
                    // Call emergency number
                  },
                ),
                const Divider(height: 1),
                _buildContactTile(
                  icon: Icons.medical_services,
                  title: 'Medical Emergency',
                  subtitle: '108',
                  onTap: () {
                    // Call medical emergency
                  },
                ),
                const Divider(height: 1),
                _buildContactTile(
                  icon: Icons.local_police,
                  title: 'Police',
                  subtitle: '100',
                  onTap: () {
                    // Call police
                  },
                ),
                const Divider(height: 1),
                _buildContactTile(
                  icon: Icons.local_fire_department,
                  title: 'Fire Department',
                  subtitle: '101',
                  onTap: () {
                    // Call fire department
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Disaster tip of the day
          Card(
            color: Colors.lightBlue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.amber[700],
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Tip of the Day',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Keep an emergency kit ready with essential items like water, non-perishable food, medications, flashlight, and a first-aid kit.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build resource card
  Widget _buildResourceCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build contact list tile
  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.phone_forwarded),
      onTap: onTap,
    );
  }
}