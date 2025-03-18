// lib/screens/common/mock_map_screen.dart

import 'package:flutter/material.dart';
import 'dart:math';
import '../../widgets/custom_map_marker.dart';

/// A mock implementation of the map screen that displays a grid with markers.
/// This replaces the actual Google Maps implementation for the hackathon demo.
class MockMapScreen extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final double initialZoom;
  final Map<String, Map<String, dynamic>>? markers;
  final Map<String, Map<String, dynamic>>? circles;
  final Map<String, Map<String, dynamic>>? polygons;
  final Map<String, Map<String, dynamic>>? polylines;
  final bool showUserLocation;
  final Function(dynamic)? onMapTap;
  final Function(dynamic)? onCameraMove;

  const MockMapScreen({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    this.initialZoom = 14.0,
    this.markers,
    this.circles,
    this.polygons,
    this.polylines,
    this.showUserLocation = true,
    this.onMapTap,
    this.onCameraMove,
  });

  @override
  State<MockMapScreen> createState() => _MockMapScreenState();
}

class _MockMapScreenState extends State<MockMapScreen> {
  late double _currentZoom;
  late double _centerLatitude;
  late double _centerLongitude;
  bool _showLabels = true;
  
  // Grid colors
  final List<Color> _gridColors = [
    Colors.lightBlue[50]!,
    Colors.lightBlue[100]!,
  ];
  
  @override
  void initState() {
    super.initState();
    _currentZoom = widget.initialZoom;
    _centerLatitude = widget.initialLatitude;
    _centerLongitude = widget.initialLongitude;
  }
  
  // Handle map tap
  void _handleTap(Offset position) {
    if (widget.onMapTap != null) {
      // Convert screen position to lat/lng
      // For mock purposes, we'll generate a location near the center
      final random = Random();
      final latOffset = (random.nextDouble() - 0.5) * 0.01;
      final lngOffset = (random.nextDouble() - 0.5) * 0.01;
      
      final tapLatLng = {
        'latitude': _centerLatitude + latOffset,
        'longitude': _centerLongitude + lngOffset,
      };
      
      widget.onMapTap!(tapLatLng);
    }
  }
  
  // Zoom in
  void _zoomIn() {
    setState(() {
      _currentZoom = min(_currentZoom + 1, 20);
    });
    
    if (widget.onCameraMove != null) {
      widget.onCameraMove!({
        'zoom': _currentZoom,
        'target': {
          'latitude': _centerLatitude,
          'longitude': _centerLongitude,
        },
      });
    }
  }
  
  // Zoom out
  void _zoomOut() {
    setState(() {
      _currentZoom = max(_currentZoom - 1, 1);
    });
    
    if (widget.onCameraMove != null) {
      widget.onCameraMove!({
        'zoom': _currentZoom,
        'target': {
          'latitude': _centerLatitude,
          'longitude': _centerLongitude,
        },
      });
    }
  }
  
  // Toggle labels
  void _toggleLabels() {
    setState(() {
      _showLabels = !_showLabels;
    });
  }
  
  // Get marker size based on zoom level
  double _getMarkerSize() {
    return 24 + (_currentZoom * 1.5);
  }
  
  // Build grid squares
  List<Widget> _buildGridSquares() {
    final gridSize = 10;
    final squares = <Widget>[];
    
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        final color = _gridColors[(i + j) % 2];
        squares.add(
          Positioned(
            left: j * (MediaQuery.of(context).size.width / gridSize),
            top: i * (MediaQuery.of(context).size.height / gridSize),
            width: MediaQuery.of(context).size.width / gridSize,
            height: MediaQuery.of(context).size.height / gridSize,
            child: Container(
              color: color,
            ),
          ),
        );
      }
    }
    
    return squares;
  }
  
  // Build markers
  List<Widget> _buildMarkers() {
    final markers = <Widget>[];
    
    // Add user location marker if enabled
    if (widget.showUserLocation) {
      markers.add(
        Positioned(
          left: MediaQuery.of(context).size.width / 2 - _getMarkerSize() / 2,
          top: MediaQuery.of(context).size.height / 2 - _getMarkerSize() / 2,
          child: CustomMapMarker(
            type: 'user',
            label: 'You',
            size: _getMarkerSize(),
          ),
        ),
      );
    }
   
    // Add custom markers
    if (widget.markers != null) {
      int index = 0;
      for (final entry in widget.markers!.entries) {
        final data = entry.value;
        
        // Calculate position based on lat/lng difference from center
        // For mock purposes, we'll place them around in a staggered grid
        
        // Place markers in a visible area
        
        // Calculate staggered positions
        final row = index ~/ 3;
        final col = index % 3;
        
        final dx = MediaQuery.of(context).size.width / 4 * (col + 1);
        final dy = MediaQuery.of(context).size.height / 4 * (row + 1);
        
        // Type and severity
        final type = data['type'] as String? ?? 'default';
        final severity = data['severity'] as int? ?? 3;
        final title = data['title'] as String? ?? '';
        
        // Create marker
        markers.add(
          Positioned(
            left: dx - _getMarkerSize() / 2,
            top: dy - _getMarkerSize() / 2,
            child: CustomMapMarker(
              type: type,
              severity: severity,
              label: _showLabels ? title : '',
              size: _getMarkerSize(),
            ),
          ),
        );
        
        index++;
      }
    }
    
    return markers;
  }
  
  // Build circles for alert radiuses
  List<Widget> _buildCircles() {
    final circles = <Widget>[];
    
    if (widget.circles != null) {
      for (final entry in widget.circles!.entries) {
        final id = entry.key;
        final data = entry.value;
        
        final radius = data['radius'] as double? ?? 1000.0;
        final scaledRadius = radius * 0.02 * _currentZoom;
        final fillColor = data['fillColor'] as Color? ?? Colors.red.withOpacity(0.2);
        final strokeColor = data['strokeColor'] as Color? ?? Colors.red;
        final strokeWidth = data['strokeWidth'] as int? ?? 2;
        
        // Find matching marker to position the circle
        if (widget.markers?.containsKey(id) == true) {
          
          // Use the same positioning logic as for markers
          final row = widget.markers!.keys.toList().indexOf(id) ~/ 3;
          final col = widget.markers!.keys.toList().indexOf(id) % 3;
          
          final dx = MediaQuery.of(context).size.width / 4 * (col + 1);
          final dy = MediaQuery.of(context).size.height / 4 * (row + 1);
          
          circles.add(
            Positioned(
              left: dx - scaledRadius,
              top: dy - scaledRadius,
              width: scaledRadius * 2,
              height: scaledRadius * 2,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fillColor,
                  border: Border.all(
                    color: strokeColor,
                    width: strokeWidth.toDouble(),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }
    
    return circles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => _handleTap(const Offset(0, 0)),
        child: Stack(
          children: [
            // Map grid background
            ..._buildGridSquares(),
            
            // Map labels
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mock Map View',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${_centerLatitude.toStringAsFixed(4)}, Lng: ${_centerLongitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Zoom: ${_currentZoom.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Circles (alert radiuses)
            ..._buildCircles(),
            
            // Markers
            ..._buildMarkers(),
            
            // Map controls
            Positioned(
              right: 16,
              top: 16,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _zoomIn,
                          tooltip: 'Zoom in',
                        ),
                        const Divider(height: 1),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _zoomOut,
                          tooltip: 'Zoom out',
                        ),
                        const Divider(height: 1),
                        IconButton(
                          icon: Icon(_showLabels ? Icons.label_off : Icons.label),
                          onPressed: _toggleLabels,
                          tooltip: _showLabels ? 'Hide labels' : 'Show labels',
                        ),
                        const Divider(height: 1),
                        IconButton(
                          icon: const Icon(Icons.my_location),
                          onPressed: () {
                            setState(() {
                              _centerLatitude = widget.initialLatitude;
                              _centerLongitude = widget.initialLongitude;
                            });
                          },
                          tooltip: 'My location',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Mock attribution
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Mock Map (Hackathon Demo)',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}