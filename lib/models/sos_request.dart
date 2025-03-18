// sos_request.dart
import 'package:equatable/equatable.dart';

class SosRequest extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String type;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String status; // pending, active, completed, cancelled
  final List<String> photoUrls;
  final String? assignedToId;
  final String? assignedToName;
  final String? notes;
  final DateTime? lastUpdated;

  const SosRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.status,
    required this.photoUrls,
    this.assignedToId,
    this.assignedToName,
    this.notes,
    this.lastUpdated,
  });

  // Create from map (e.g., Firestore document)
  factory SosRequest.fromMap(Map<String, dynamic> map) {
    return SosRequest(
      id: map['id'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      type: map['type'] as String,
      description: map['description'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      timestamp: DateTime.parse(map['timestamp'] as String),
      status: map['status'] as String,
      photoUrls: List<String>.from(map['photoUrls'] as List),
      assignedToId: map['assignedToId'] as String?,
      assignedToName: map['assignedToName'] as String?,
      notes: map['notes'] as String?,
      lastUpdated: map['lastUpdated'] != null 
          ? DateTime.parse(map['lastUpdated'] as String) 
          : null,
    );
  }

  // Convert to map (e.g., for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'photoUrls': photoUrls,
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
      'notes': notes,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    description,
    latitude,
    longitude,
    timestamp,
    status,
    photoUrls,
    assignedToId,
    assignedToName,
    notes,
    lastUpdated,
  ];
  
  // Create a copy with optional updated fields
  SosRequest copyWith({
    String? status,
    String? assignedToId,
    String? assignedToName,
    String? notes,
  }) {
    return SosRequest(
      id: id,
      userId: userId,
      userName: userName,
      type: type,
      description: description,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      status: status ?? this.status,
      photoUrls: photoUrls,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      notes: notes ?? this.notes,
      lastUpdated: DateTime.now(),
    );
  }
}