// user.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role; // admin, government, field_worker, civilian
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final Map<String, dynamic>? preferences;
  final List<String>? subscriptions; // Alert types subscribed to

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
    this.preferences,
    this.subscriptions,
  });

  // Create from map (e.g., Firestore document)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      isVerified: map['isVerified'] as bool,
      isActive: map['isActive'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastLogin: map['lastLogin'] != null
          ? DateTime.parse(map['lastLogin'] as String)
          : null,
      preferences: map['preferences'] as Map<String, dynamic>?,
      subscriptions: map['subscriptions'] != null
          ? List<String>.from(map['subscriptions'] as List)
          : null,
    );
  }

  // Convert to map (e.g., for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'preferences': preferences,
      'subscriptions': subscriptions,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        phone,
        address,
        latitude,
        longitude,
        isVerified,
        isActive,
        createdAt,
        lastLogin,
        preferences,
        subscriptions,
      ];

  // Check if user is admin
  bool get isAdmin => role == 'admin';

  // Check if user is government
  bool get isGovernment => role == 'government';

  // Check if user is field worker
  bool get isFieldWorker => role == 'field_worker';

  // Check if user is civilian
  bool get isCivilian => role == 'civilian';

  // Check if user has location data
  bool get hasLocation => latitude != null && longitude != null;

  // Create a copy with optional updated fields
  User copyWith({
    String? name,
    String? email,
    String? role,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    bool? isVerified,
    bool? isActive,
    DateTime? lastLogin,
    Map<String, dynamic>? preferences,
    List<String>? subscriptions,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      preferences: preferences ?? this.preferences,
      subscriptions: subscriptions ?? this.subscriptions,
    );
  }
}