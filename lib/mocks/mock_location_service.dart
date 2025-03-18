// Enhanced MockLocationService

import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:irescue/services/location_service.dart';

class MockLocationService implements LocationService {
  // Default location (San Francisco coordinates)
  double _latitude = 37.7749;
  double _longitude = -122.4194;
  
  // Store last known position
  Position? _lastKnownPosition;
  
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
    
    // Set initial last known position
    _lastKnownPosition = Position(
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
    
    // Update last known position
    _lastKnownPosition = Position(
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
  
  /// Set a specific mock location
  void setMockLocation(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
    
    // Update last known position
    _lastKnownPosition = Position(
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
  Future<Position> getCurrentPosition() async {
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 10% chance of simulating a location error for testing error handling
    if (Random().nextDouble() < 0.1) {
      throw Exception('Mock location error - simulated for testing');
    }
    
    final position = Position(
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
    
    // Store as last known position
    _lastKnownPosition = position;
    
    return position;
  }
  
  @override
  Future<Position> getLastKnownPosition() async {
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_lastKnownPosition != null) {
      return _lastKnownPosition!;
    }
    
    // If no last known position, create a new one
    final position = Position(
      longitude: _longitude,
      latitude: _latitude,
      timestamp: DateTime.now(),
      accuracy: 10.0, // Less accurate than getCurrentPosition
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
    
    _lastKnownPosition = position;
    return position;
  }

  @override
  Stream<Position> startLocationTracking({int intervalInSeconds = 10}) {
    if (_isTracking) {
      return _locationController.stream;
    }
    
    _isTracking = true;
    
    // Emit current position immediately
    Future.microtask(() async {
      try {
        final position = await getCurrentPosition();
        if (!_locationController.isClosed) {
          _locationController.add(position);
        }
      } catch (e) {
        print('Error getting initial position for tracking: $e');
      }
    });
    
    // Set up periodic location updates with small random movements
    _locationTimer = Timer.periodic(
      Duration(seconds: intervalInSeconds),
      (_) async {
        try {
          // Simulate small movement
          final random = Random();
          _latitude += (random.nextDouble() - 0.5) * 0.0005;
          _longitude += (random.nextDouble() - 0.5) * 0.0005;
          
          final position = Position(
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
          
          _lastKnownPosition = position;
          
          if (!_locationController.isClosed) {
            _locationController.add(position);
          }
        } catch (e) {
          print('Error updating location during tracking: $e');
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
    
    // Sort by distance (closest first)
    nearbyLocations.sort((a, b) {
      return (a['distance'] as double).compareTo(b['distance'] as double);
    });
    
    return nearbyLocations;
  }
  
  /// Dispose resources
  void dispose() {
    stopLocationTracking();
    _locationController.close();
  }
}