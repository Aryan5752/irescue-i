// resource.dart
import 'package:equatable/equatable.dart';

class Resource extends Equatable {
  final String id;
  final String name;
  final String category; // food, medicine, equipment, etc.
  final int quantity;
  final String unit; // kg, liters, pieces, etc.
  final int minStockLevel;
  final DateTime expiryDate;
  final String status; // available, allocated, expired
  final DateTime? lastUpdated;

  const Resource({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minStockLevel,
    required this.expiryDate,
    required this.status,
    this.lastUpdated,
  });

  // Create from map (e.g., Firestore document)
  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      quantity: map['quantity'] as int,
      unit: map['unit'] as String,
      minStockLevel: map['minStockLevel'] as int,
      expiryDate: DateTime.parse(map['expiryDate'] as String),
      status: map['status'] as String,
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
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'minStockLevel': minStockLevel,
      'expiryDate': expiryDate.toIso8601String(),
      'status': status,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        quantity,
        unit,
        minStockLevel,
        expiryDate,
        status,
        lastUpdated,
      ];

  // Check if resource is low on stock
  bool get isLowStock => quantity <= minStockLevel;

  // Check if resource is expired
  bool get isExpired => expiryDate.isBefore(DateTime.now());

  // Check if resource is available
  bool get isAvailable => status == 'available' && !isExpired && quantity > 0;

  // Create a copy with optional updated fields
  Resource copyWith({
    String? name,
    String? category,
    int? quantity,
    String? unit,
    int? minStockLevel,
    DateTime? expiryDate,
    String? status,
  }) {
    return Resource(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      lastUpdated: DateTime.now(),
    );
  }
}