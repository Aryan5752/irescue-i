// alerts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/alert/alert_bloc.dart';
import '../../models/alert.dart';
import '../../models/user.dart';
import '../../widgets/alert_card.dart';
import '../common/map_screen.dart';

class AlertsScreen extends StatefulWidget {
  final User currentUser;

  const AlertsScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool _showActiveOnly = true;
  String _filterType = 'All';
  
  final List<String> _alertTypes = [
    'All',
    'Earthquake',
    'Flood',
    'Fire',
    'Hurricane',
    'Tornado',
    'Tsunami',
    'Landslide',
    'Chemical',
    'Security',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    
    // Load alerts on screen initialization
    _loadAlerts();
  }
  
  void _loadAlerts() {
    // Determine if user is admin
    final isAdmin = widget.currentUser.role == 'admin' || widget.currentUser.role == 'government';
    
    // Dispatch event to load alerts
    context.read<AlertBloc>().add(AlertsStarted(isAdmin: isAdmin));
  }
  
  // Filter alerts based on current filters
  List<Alert> _filterAlerts(List<Alert> alerts) {
    return alerts.where((alert) {
      // Filter by active status
      if (_showActiveOnly && !alert.active) {
        return false;
      }
      
      // Filter by type
      if (_filterType != 'All' && alert.type != _filterType) {
        return false;
      }
      
      return true;
    }).toList();
  }
  
  // View alert on map
  void _viewAlertOnMap(Alert alert) {
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
              'fillColor': _getSeverityColor(alert.severity).withOpacity(0.2),
              'strokeColor': _getSeverityColor(alert.severity),
              'strokeWidth': 2,
            },
          },
        ),
      ),
    );
  }
  
  // Get color based on severity
  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 5:
        return Colors.purple[900]!;
      case 4:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.amber;
      case 1:
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: Column(
        children: [
          // Filter controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Status filter
                Row(
                  children: [
                    const Text('Show only active alerts:'),
                    const Spacer(),
                    Switch(
                      value: _showActiveOnly,
                      onChanged: (value) {
                        setState(() {
                          _showActiveOnly = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Type filter
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Filter by type',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  value: _filterType,
                  items: _alertTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _filterType = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Alert list
          Expanded(
            child: BlocBuilder<AlertBloc, AlertState>(
              builder: (context, state) {
                if (state is AlertLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is AlertsLoaded) {
                  final filteredAlerts = _filterAlerts(state.alerts);
                  
                  if (filteredAlerts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_off,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _showActiveOnly 
                                ? 'No active alerts in your area'
                                : 'No alerts match your filters',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_showActiveOnly || _filterType != 'All')
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showActiveOnly = false;
                                  _filterType = 'All';
                                });
                              },
                              child: const Text('Clear Filters'),
                            ),
                        ],
                      ),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadAlerts();
                    },
                    child: ListView.builder(
                      itemCount: filteredAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = filteredAlerts[index];
                        return AlertCard(
                          alert: alert,
                          onTap: () {
                            // Show alert details (could navigate to detail page)
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(alert.title),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Type: ${alert.type}'),
                                    Text('Severity: ${alert.severity}'),
                                    Text('Description: ${alert.description}'),
                                    Text('Radius: ${alert.radius} km'),
                                    Text('Status: ${alert.active ? "Active" : "Cleared"}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _viewAlertOnMap(alert);
                                    },
                                    child: const Text('View on Map'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onViewMap: () => _viewAlertOnMap(alert),
                        );
                      },
                    ),
                  );
                } else if (state is AlertError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAlerts,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Text('No alerts to display'),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.currentUser.role == 'admin' || widget.currentUser.role == 'government'
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to create alert screen
                // For hackathon purposes, we're not implementing this screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create Alert functionality would be here'),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}