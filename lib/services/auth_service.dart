// lib/services/auth_service.dart

import '../models/user.dart';

/// Abstract interface for authentication services
/// This can be implemented by both real Firebase Auth and mock implementations
abstract class AuthService {
  /// Get the current authenticated user ID
  String? get currentUser;
  
  /// Stream of authentication state changes
  Stream<String?> get authStateChanges;
  
  /// Sign in with email and password
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  /// Register a new user with email and password
  Future<User> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? address,
  });
  
  /// Sign out the current user
  Future<void> signOut();
  
  /// Get user data by ID
  Future<User?> getUserData(String userId);
  
  /// Update user profile
  Future<User> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? preferences,
    List<String>? subscriptions,
  });
  
  /// Change user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  
  /// Reset user password
  Future<void> resetPassword({required String email});
  
  /// Send email verification
  Future<void> sendEmailVerification();
  
  /// Check if user's email is verified
  Future<bool> isEmailVerified();
  
  /// Delete user account
  Future<void> deleteAccount({required String password});
}