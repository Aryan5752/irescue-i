// alert.dart
import 'package:equatable/equatable.dart';

class Alert extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type; // earthquake, flood, fire, etc.
  final int severity; // 1-5, with 5 being most severe
  final double latitude;
  final double longitude;
  final double radius; // in kilometers
  final DateTime timestamp;
  final bool active;
  final String createdById;
  final String createdByName;
  final DateTime? lastUpdated;

  const Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.timestamp,
    required this.active,
    required this.createdById,
    required this.createdByName,
    this.lastUpdated,
  });

  // Create from map (e.g., Firestore document)
  factory Alert.fromMap(Map<String, dynamic> map) {
    return Alert(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      severity: map['severity'] as int,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      radius: map['radius'] as double,
      timestamp: DateTime.parse(map['timestamp'] as String),
      active: map['active'] as bool,
      createdById: map['createdById'] as String,
      createdByName: map['createdByName'] as String,
      lastUpdated: map['lastUpdated'] != null 
          ? DateTime.parse(map['lastUpdated'] as String) 
          : null,
    );
  }

  // Convert to map (e.g., for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'severity': severity,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'timestamp': timestamp.toIso8601String(),
      'active': active,
      'createdById': createdById,
      'createdByName': createdByName,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    severity,
    latitude,
    longitude,
    radius,
    timestamp,
    active,
    createdById,
    createdByName,
    lastUpdated,
  ];
  
  // Create a copy with optional updated fields
  Alert copyWith({
    String? title,
    String? description,
    int? severity,
    bool? active,
    double? radius,
  }) {
    return Alert(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type,
      severity: severity ?? this.severity,
      latitude: latitude,
      longitude: longitude,
      radius: radius ?? this.radius,
      timestamp: timestamp,
      active: active ?? this.active,
      createdById: createdById,
      createdByName: createdByName,
      lastUpdated: DateTime.now(),
    );
  }
}