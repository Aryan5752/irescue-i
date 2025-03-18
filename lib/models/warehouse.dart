// warehouse.dart
import 'package:equatable/equatable.dart';
import 'resource.dart';

class Warehouse extends Equatable {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String managerId;
  final String managerName;
  final List<Resource> resources;
  final int capacity;
  final int usedCapacity;
  final String status; // active, inactive, maintenance
  final DateTime createdAt;
  final DateTime? lastUpdated;

  const Warehouse({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.managerId,
    required this.managerName,
    required this.resources,
    required this.capacity,
    required this.usedCapacity,
    required this.status,
    required this.createdAt,
    this.lastUpdated,
  });

  // Create from map (e.g., Firestore document)
  factory Warehouse.fromMap(Map<String, dynamic> map) {
    return Warehouse(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      managerId: map['managerId'] as String,
      managerName: map['managerName'] as String,
      resources: (map['resources'] as List<dynamic>)
          .map((resource) => Resource.fromMap(resource as Map<String, dynamic>))
          .toList(),
      capacity: map['capacity'] as int,
      usedCapacity: map['usedCapacity'] as int,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'] as String)
          : null,
    );
  }

  // Convert to map (e.g., for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'managerId': managerId,
      'managerName': managerName,
      'resources': resources.map((resource) => resource.toMap()).toList(),
      'capacity': capacity,
      'usedCapacity': usedCapacity,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        latitude,
        longitude,
        managerId,
        resources,
        capacity,
        usedCapacity,
        status,
        createdAt,
        lastUpdated,
      ];

  // Get remaining capacity
  int get remainingCapacity => capacity - usedCapacity;

  // Get resource by ID
  Resource? getResourceById(String resourceId) {
    try {
      return resources.firstWhere((resource) => resource.id == resourceId);
    } catch (e) {
      return null;
    }
  }

  // Check if has low stock resources
  bool get hasLowStockResources {
    return resources.any((resource) => resource.isLowStock);
  }

  // Get low stock resources
  List<Resource> get lowStockResources {
    return resources.where((resource) => resource.isLowStock).toList();
  }

  // Create a copy with optional updated fields
  Warehouse copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? managerId,
    String? managerName,
    List<Resource>? resources,
    int? capacity,
    int? usedCapacity,
    String? status,
  }) {
    return Warehouse(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      resources: resources ?? this.resources,
      capacity: capacity ?? this.capacity,
      usedCapacity: usedCapacity ?? this.usedCapacity,
      status: status ?? this.status,
      createdAt: createdAt,
      lastUpdated: DateTime.now(),
    );
  }
}