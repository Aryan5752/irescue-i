// Updated LocationService interface with the getLastKnownPosition method

import 'package:geolocator/geolocator.dart';

abstract class LocationService {
  /// Gets the current device position.
  /// 
  /// Returns a [Position] object with location data.
  Future<Position> getCurrentPosition();
  
  /// Gets the last known position of the device.
  /// This is useful as a fallback when getCurrentPosition fails or times out.
  /// 
  /// Returns a [Position] object with location data.
  Future<Position> getLastKnownPosition();

  /// Starts tracking the device location with periodic updates.
  /// 
  /// [intervalInSeconds] determines how frequently location updates are emitted.
  /// Returns a Stream of [Position] objects.
  Stream<Position> startLocationTracking({int intervalInSeconds = 10});

  /// Stops location tracking, canceling any active streams.
  void stopLocationTracking();
  
  /// Calculates the distance in kilometers between two coordinates using the Haversine formula.
  /// 
  /// [startLatitude], [startLongitude]: Coordinates of the starting point.
  /// [endLatitude], [endLongitude]: Coordinates of the end point.
  /// Returns the distance in kilometers.
  double calculateDistance(
    double startLatitude, 
    double startLongitude, 
    double endLatitude, 
    double endLongitude,
  );
  
  /// Checks if a location is within a specified radius of another location.
  /// 
  /// [centerLatitude], [centerLongitude]: Coordinates of the center point.
  /// [pointLatitude], [pointLongitude]: Coordinates of the point to check.
  /// [radiusInKm]: The radius in kilometers.
  /// Returns true if the point is within the radius.
  bool isWithinRadius(
    double centerLatitude, 
    double centerLongitude, 
    double pointLatitude, 
    double pointLongitude, 
    double radiusInKm,
  );
  
  /// Filters a list of locations to only those within a specified radius.
  /// 
  /// [latitude], [longitude]: Coordinates of the center point.
  /// [locations]: List of location objects with latitude and longitude fields.
  /// [radiusInKm]: The radius in kilometers.
  /// Returns filtered list of nearby locations.
  List<Map<String, dynamic>> getNearbyLocations(
    double latitude, 
    double longitude, 
    List<Map<String, dynamic>> locations, 
    double radiusInKm,
  );
}