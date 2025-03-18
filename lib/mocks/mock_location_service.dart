// lib/services/mock/mock_location_service.dart

import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:irescue/services/location_service.dart';

class MockLocationService implements LocationService {
  // Default location (San Francisco coordinates)
  double _latitude = 37.7749;
  double _longitude = -122.4194;
  
  // Stream controller for location updates
  final _locationController = StreamController<Position>.broadcast();
  Timer? _locationTimer;
  bool _isTracking = false;

  /// Initialize with slightly randomized location
  Future<void> initialize() async {
    final random = Random();
    // Add small random variation to default location
    _latitude += (random.nextDouble() - 0.5) * 0.01;
    _longitude += (random.nextDouble() - 0.5) * 0.01;
  }
  
  /// Reset to default location
  void reset() {
    // Stop tracking if active
    stopLocationTracking();
    
    // Reset to default location
    _latitude = 37.7749;
    _longitude = -122.4194;
    
    // Add small variation
    final random = Random();
    _latitude += (random.nextDouble() - 0.5) * 0.01;
    _longitude += (random.nextDouble() - 0.5) * 0.01;
  }
  
  /// Set a specific mock location
  void setMockLocation(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
  }
  
  @override
  Future<Position> getCurrentPosition() async {
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return Position(
      longitude: _longitude,
      latitude: _latitude,
      timestamp: DateTime.now(),
      accuracy: 4.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }

  @override
  Stream<Position> startLocationTracking({int intervalInSeconds = 10}) {
    if (_isTracking) {
      return _locationController.stream;
    }
    
    _isTracking = true;
    
    // Emit current position immediately
    Future.microtask(() async {
      final position = await getCurrentPosition();
      if (!_locationController.isClosed) {
        _locationController.add(position);
      }
    });
    
    // Set up periodic location updates with small random movements
    _locationTimer = Timer.periodic(
      Duration(seconds: intervalInSeconds),
      (_) async {
        // Simulate small movement
        final random = Random();
        _latitude += (random.nextDouble() - 0.5) * 0.0005;
        _longitude += (random.nextDouble() - 0.5) * 0.0005;
        
        final position = await getCurrentPosition();
        if (!_locationController.isClosed) {
          _locationController.add(position);
        }
      },
    );
    
    return _locationController.stream;
  }

  @override
  void stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _isTracking = false;
  }
  
  @override
  double calculateDistance(
    double startLatitude, 
    double startLongitude, 
    double endLatitude, 
    double endLongitude,
  ) {
    const int earthRadius = 6371; // Earth's radius in kilometers
    
    final double latDistance = _toRadians(endLatitude - startLatitude);
    final double lonDistance = _toRadians(endLongitude - startLongitude);
    
    final double a = sin(latDistance / 2) * sin(latDistance / 2) +
        cos(_toRadians(startLatitude)) * cos(_toRadians(endLatitude)) *
        sin(lonDistance / 2) * sin(lonDistance / 2);
        
    final double c = 2 * asin(sqrt(a));
    
    return earthRadius * c; // Distance in kilometers
  }
  
  // Convert degrees to radians
  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
  
  @override
  bool isWithinRadius(
    double centerLatitude, 
    double centerLongitude, 
    double pointLatitude, 
    double pointLongitude, 
    double radiusInKm,
  ) {
    final distance = calculateDistance(
      centerLatitude, 
      centerLongitude, 
      pointLatitude, 
      pointLongitude,
    );
    
    return distance <= radiusInKm;
  }
  
  @override
  List<Map<String, dynamic>> getNearbyLocations(
    double latitude, 
    double longitude, 
    List<Map<String, dynamic>> locations, 
    double radiusInKm,
  ) {
    final nearbyLocations = locations.where((location) {
      final locationLatitude = location['latitude'] as double;
      final locationLongitude = location['longitude'] as double;
      
      return isWithinRadius(
        latitude, 
        longitude, 
        locationLatitude, 
        locationLongitude, 
        radiusInKm,
      );
    }).toList();
    
    // Add distance field to results
    for (final location in nearbyLocations) {
      final locationLatitude = location['latitude'] as double;
      final locationLongitude = location['longitude'] as double;
      
      location['distance'] = calculateDistance(
        latitude, longitude, locationLatitude, locationLongitude);
    }
    
    return nearbyLocations;
  }
  
  /// Dispose resources
  void dispose() {
    stopLocationTracking();
    _locationController.close();
  }
}