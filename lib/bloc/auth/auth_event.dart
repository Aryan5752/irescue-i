// Auth events
// ==================================================================
// bloc/auth/auth_event.dart
// ==================================================================

part of 'auth_bloc.dart';
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;
  final String? phone;
  final String? address;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [name, email, password, role, phone, address];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthProfileUpdateRequested extends AuthEvent {
  final String? name;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? preferences;
  final List<String>? subscriptions;

  const AuthProfileUpdateRequested({
    this.name,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.preferences,
    this.subscriptions,
  });

  @override
  List<Object?> get props => [
    name,
    phone,
    address,
    latitude,
    longitude,
    preferences,
    subscriptions,
  ];
}

class AuthPasswordChangeRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthPasswordChangeRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}