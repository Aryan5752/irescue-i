// // location_service.dart
// import 'dart:async';
// import 'dart:math' show cos, sqrt, asin, sin;

// import 'package:geolocator/geolocator.dart';

// class LocationService {
//   // Singleton pattern
//   static final LocationService _instance = LocationService._internal();
//   factory LocationService() => _instance;
//   LocationService._internal();
  
//   // Stream controller for location updates
//   StreamController<Position>? _locationController;
//   Timer? _locationTimer;
//   bool _isTracking = false;

//   // Initialize location services
//   Future<void> initialize() async {
//     await _checkPermission();
//   }
  
//   // Check and request location permissions
//   Future<bool> _checkPermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Test if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Location services are not enabled
//       return false;
//     }

//     // Check location permission
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // Permissions are denied
//         return false;
//       }
//     }
    
//     if (permission == LocationPermission.deniedForever) {
//       // Permissions are permanently denied
//       return false;
//     }

//     // Permissions are granted
//     return true;
//   }

//   // Get current position
//   Future<Position> getCurrentPosition() async {
//     if (!await _checkPermission()) {
//       throw Exception('Location permission not granted');
//     }

//     try {
//       return await Geolocator.getCurrentPosition();
//     } catch (e) {
//       throw Exception('Failed to get current position: $e');
//     }
//   }

//   // Start tracking location
//   Stream<Position> startLocationTracking({int intervalInSeconds = 10}) {
//     if (_isTracking) {
//       // Return existing stream if already tracking
//       return _locationController!.stream;
//     }

//     // Check if controller exists and is closed
//     if (_locationController == null || _locationController!.isClosed) {
//       _locationController = StreamController<Position>.broadcast();
//     }

//     _isTracking = true;
    
//     // Set up periodic location updates
//     _locationTimer = Timer.periodic(
//       Duration(seconds: intervalInSeconds),
//       (_) async {
//         try {
//           final position = await getCurrentPosition();
//           if (!_locationController!.isClosed) {
//             _locationController!.add(position);
//           }
//         } catch (e) {
//           if (!_locationController!.isClosed) {
//             _locationController!.addError('Failed to get location: $e');
//           }
//         }
//       },
//     );

//     // Get initial position
//     getCurrentPosition().then((position) {
//       if (!_locationController!.isClosed) {
//         _locationController!.add(position);
//       }
//     }).catchError((error) {
//       if (!_locationController!.isClosed) {
//         _locationController!.addError('Failed to get initial location: $error');
//       }
//     });

//     return _locationController!.stream;
//   }

//   // Stop location tracking
//   void stopLocationTracking() {
//     _locationTimer?.cancel();
//     _locationController?.close();
//     _isTracking = false;
//   }
  
//   // Calculate distance between two coordinates (Haversine formula)
//   double calculateDistance(
//     double startLatitude, 
//     double startLongitude, 
//     double endLatitude, 
//     double endLongitude,
//   ) {
//     const int earthRadius = 6371; // Earth's radius in kilometers
    
//     final double latDistance = _toRadians(endLatitude - startLatitude);
//     final double lonDistance = _toRadians(endLongitude - startLongitude);
    
//     final double a = sin(latDistance / 2) * sin(latDistance / 2) +
//         cos(_toRadians(startLatitude)) * cos(_toRadians(endLatitude)) *
//         sin(lonDistance / 2) * sin(lonDistance / 2);
        
//     final double c = 2 * asin(sqrt(a));
    
//     return earthRadius * c; // Distance in kilometers
//   }
  
//   // Convert degrees to radians
//   double _toRadians(double degree) {
//     return degree * (3.141592653589793 / 180);
//   }
  
//   // Check if a location is within a certain radius of another location
//   bool isWithinRadius(
//     double centerLatitude, 
//     double centerLongitude, 
//     double pointLatitude, 
//     double pointLongitude, 
//     double radiusInKm,
//   ) {
//     final distance = calculateDistance(
//       centerLatitude, 
//       centerLongitude, 
//       pointLatitude, 
//       pointLongitude,
//     );
    
//     return distance <= radiusInKm;
//   }
  
//   // Get nearby locations from a list
//   List<Map<String, dynamic>> getNearbyLocations(
//     double latitude, 
//     double longitude, 
//     List<Map<String, dynamic>> locations, 
//     double radiusInKm,
//   ) {
//     return locations.where((location) {
//       final locationLatitude = location['latitude'] as double;
//       final locationLongitude = location['longitude'] as double;
      
//       return isWithinRadius(
//         latitude, 
//         longitude, 
//         locationLatitude, 
//         locationLongitude, 
//         radiusInKm,
//       );
//     }).toList();
//   }
// }