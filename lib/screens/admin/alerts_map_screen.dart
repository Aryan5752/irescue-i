// alerts_map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../bloc/alert/alert_bloc.dart';
import '../../bloc/sos/sos_bloc.dart';
import '../common/map_screen.dart';

class AlertsMapScreen extends StatefulWidget {
  final User currentUser;

  const AlertsMapScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<AlertsMapScreen> createState() => _AlertsMapScreenState();
}

class _AlertsMapScreenState extends State<AlertsMapScreen> {
  bool _showAlerts = true;
  bool _showSosRequests = true;
  
  @override
  void initState() {
    super.initState();
    
    // Load data when screen initializes
    _loadData();
  }
  
  // Load necessary data
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map with alerts and SOS requests
          _buildMap(),
          
          // Layer controls
          Positioned(
            top: 16,
            left: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Map Layers',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLayerToggle(
                      label: 'Alerts',
                      value: _showAlerts,
                      onChanged: (value) {
                        setState(() {
                          _showAlerts = value!;
                        });
                      },
                    ),
                    _buildLayerToggle(
                      label: 'SOS Requests',
                      value: _showSosRequests,
                      onChanged: (value) {
                        setState(() {
                          _showSosRequests = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Create new alert button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                // Show create alert dialog
                _showCreateAlertDialog();
              },
              child: const Icon(Icons.add_alert),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build map with alerts and SOS requests
  Widget _buildMap() {
    return BlocBuilder<AlertBloc, AlertState>(
      builder: (context, alertState) {
        return BlocBuilder<SosBloc, SosState>(
          builder: (context, sosState) {
            // Prepare markers, circles, etc.
            final Map<String, Map<String, dynamic>> markers = {};
            final Map<String, Map<String, dynamic>> circles = {};
            
            // Add alert markers and circles
            if (alertState is AlertsLoaded && _showAlerts) {
              for (final alert in alertState.alerts) {
                // Skip inactive alerts
                if (!alert.active) continue;
                
                // Add marker
                markers[alert.id] = {
                  'latitude': alert.latitude,
                  'longitude': alert.longitude,
                  'title': alert.title,
                  'snippet': alert.description,
                  'type': 'alert',
                  'severity': alert.severity,
                };
                
                // Add circle for affected area
                circles[alert.id] = {
                  'latitude': alert.latitude,
                  'longitude': alert.longitude,
                  'radius': alert.radius * 1000, // Convert km to meters
                  'fillColor': _getSeverityColor(alert.severity).withOpacity(0.2),
                  'strokeColor': _getSeverityColor(alert.severity),
                  'strokeWidth': 2,
                };
              }
            }
            
            // Add SOS request markers
            if (sosState is SosRequestsLoaded && _showSosRequests) {
              for (final request in sosState.requests) {
                // Skip completed or cancelled requests
                if (request.status == 'completed' || request.status == 'cancelled') {
                  continue;
                }
                
                // Add marker
                markers['sos_${request.id}'] = {
                  'latitude': request.latitude,
                  'longitude': request.longitude,
                  'title': 'SOS: ${request.type}',
                  'snippet': request.description,
                  'type': 'sos',
                };
              }
            }
            
            // Determine initial location
            double initialLatitude = 0.0;
            double initialLongitude = 0.0;
            
            // If user has location, use it
            if (widget.currentUser.latitude != null && widget.currentUser.longitude != null) {
              initialLatitude = widget.currentUser.latitude!;
              initialLongitude = widget.currentUser.longitude!;
            }
            // Otherwise use first alert or SOS request
            else if (markers.isNotEmpty) {
              final firstMarker = markers.values.first;
              initialLatitude = firstMarker['latitude'] as double;
              initialLongitude = firstMarker['longitude'] as double;
            }
            // Fallback to default location
            else {
              initialLatitude = 37.7749;
              initialLongitude = -122.4194;
            }
            
            return MapScreen(
              initialLatitude: initialLatitude,
              initialLongitude: initialLongitude,
              initialZoom: 10.0,
              markers: markers,
              circles: circles,
              showUserLocation: true,
              onMapTap: (latLng) {
                // Handle map tap
                // Could show a dialog to create alert at that location
              },
            );
          },
        );
      },
    );
  }
  
  // Build layer toggle
  Widget _buildLayerToggle({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Text(label),
      ],
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
  
  // Show create alert dialog
  void _showCreateAlertDialog() {
    // For hackathon purposes, we're showing a simplified dialog
    // In a real app, this would be a form with more fields
    
    String type = 'Earthquake';
    int severity = 3;
    double radius = 5.0;
    
    final types = ['Earthquake', 'Flood', 'Fire', 'Hurricane', 'Tornado', 'Chemical', 'Other'];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Alert'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                  onChanged: (value) {
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Type',
                  ),
                  value: type,
                  items: types.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      type = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Severity (1-5)'),
                Slider(
                  value: severity.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: severity.toString(),
                  onChanged: (value) {
                    severity = value.round();
                  },
                ),
                const SizedBox(height: 16),
                const Text('Radius (km)'),
                Slider(
                  value: radius,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: radius.toString(),
                  onChanged: (value) {
                    radius = value;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Note: In a real app, you would select a location on the map.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // For hackathon demo, just show a snackbar
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alert created successfully'),
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}