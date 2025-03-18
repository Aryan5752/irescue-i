// lib/screens/common/map_screen.dart

import 'package:flutter/material.dart';
import 'mock_map_screen.dart';

/// This wrapper class allows us to seamlessly switch between real Google Maps
/// and our mock implementation for the hackathon demo.
/// 
/// For the hackathon, we'll always use the mock implementation.
class MapScreen extends StatelessWidget {
  final double initialLatitude;
  final double initialLongitude;
  final double initialZoom;
  final Map<String, Map<String, dynamic>>? markers;
  final Map<String, Map<String, dynamic>>? polygons;
  final Map<String, Map<String, dynamic>>? circles;
  final Map<String, Map<String, dynamic>>? polylines;
  final bool showUserLocation;
  final Function(dynamic)? onMapTap;
  final Function(dynamic)? onCameraMove;

  const MapScreen({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    this.initialZoom = 14.0,
    this.markers,
    this.polygons,
    this.circles,
    this.polylines,
    this.showUserLocation = true,
    this.onMapTap,
    this.onCameraMove,
  });

  @override
  Widget build(BuildContext context) {
    // Always use mock maps for hackathon demo
    return MockMapScreen(
      initialLatitude: initialLatitude,
      initialLongitude: initialLongitude,
      initialZoom: initialZoom,
      markers: markers,
      polygons: polygons,
      circles: circles,
      polylines: polylines,
      showUserLocation: showUserLocation,
      onMapTap: onMapTap,
      onCameraMove: onCameraMove,
    );
    
    // In a real app, we would check a condition and use Google Maps when appropriate
    // if (!isDemoMode) {
    //   return GoogleMapScreen(...); // Real implementation
    // } else {
    //   return MockMapScreen(...);
    // }
  }
}