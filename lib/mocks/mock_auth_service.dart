// lib/services/mock/mock_auth_service.dart

import 'dart:async';
import 'package:irescue/mocks/sample_data.dart';
import 'package:irescue/services/auth_service.dart';

import '../../models/user.dart' as app_models;

class MockAuthService implements AuthService {
  // In-memory storage for users
  final Map<String, app_models.User> _users = {};
  
  // Current authenticated user
  app_models.User? _currentUser;
  
  // Authentication state controller
  final _authStateController = StreamController<String?>.broadcast();
  
  MockAuthService() {
    // Add sample users from sample data
    _users.addAll(SampleData.users);
  }
  
  @override
  String? get currentUser => _currentUser?.id;
  
  @override
  Stream<String?> get authStateChanges => _authStateController.stream;

  @override
  Future<app_models.User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock login logic
    if (_users.containsKey(email)) {
      // For demo purposes, accept any password
      final user = _users[email]!;
      _currentUser = user;
      _authStateController.add(user.id);
      
      // Update last login
      final updatedUser = user.copyWith(
        lastLogin: DateTime.now(),
      );
      _users[email] = updatedUser;
      _currentUser = updatedUser;
      
      return updatedUser;
    }
    
    // Special case for demo logins
    if (email == 'admin@test.com' && password == 'password') {
      // Create admin user on-the-fly if demo login is used
      final user = SampleData.createAdminUser();
      _users[email] = user;
      _currentUser = user;
      _authStateController.add(user.id);
      return user;
    }
    
    if (email == 'user@test.com' && password == 'password') {
      // Create civilian user on-the-fly if demo login is used
      final user = SampleData.createCivilianUser();
      _users[email] = user;
      _currentUser = user;
      _authStateController.add(user.id);
      return user;
    }
    
    throw Exception('Invalid email or password');
  }

  @override
  Future<app_models.User> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? address,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Check if user already exists
    if (_users.containsKey(email)) {
      throw Exception('Email already in use');
    }
    
    // Create new user
    final newUser = app_models.User(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
      phone: phone,
      address: address,
      isVerified: false,
      isActive: true,
      createdAt: DateTime.now(),
      subscriptions: ['Earthquake', 'Flood', 'Fire'], // Default subscriptions
    );
    
    // Save user
    _users[email] = newUser;
    _currentUser = newUser;
    _authStateController.add(newUser.id);
    
    return newUser;
  }

  @override
  Future<void> signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<app_models.User?> getUserData(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      return _users.values.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<app_models.User> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? preferences,
    List<String>? subscriptions,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find user by ID
    try {
      final user = _users.values.firstWhere((user) => user.id == userId);
      
      // Create updated user
      final updatedUser = user.copyWith(
        name: name,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        preferences: preferences,
        subscriptions: subscriptions,
      );
      
      // Update in-memory storage
      _users[user.email] = updatedUser;
      
      // Update current user if this is the current user
      if (_currentUser?.id == userId) {
        _currentUser = updatedUser;
      }
      
      return updatedUser;
    } catch (e) {
      throw Exception('User not found');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentUser == null) {
      throw Exception('No user is signed in');
    }
    
    // For hackathon demo, just pretend it worked
    // In a real app, we would verify the current password
    return;
  }

  @override
  Future<void> resetPassword({required String email}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!_users.containsKey(email)) {
      throw Exception('No user found with that email');
    }
    
    // In a real app, would send password reset email
    // For demo, just pretend it worked
    return;
  }

  @override
  Future<void> sendEmailVerification() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_currentUser == null) {
      throw Exception('No user is signed in');
    }
    
    // In a real app, would send verification email
    // For demo, just pretend it worked
    return;
  }

  @override
  Future<bool> isEmailVerified() async {
    if (_currentUser == null) {
      return false;
    }
    
    return _currentUser!.isVerified;
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (_currentUser == null) {
      throw Exception('No user is signed in');
    }
    
    // Remove user from in-memory storage
    _users.remove(_currentUser!.email);
    
    // Sign out
    await signOut();
  }
  
  /// Reset the mock service to initial state
  Future<void> reset() async {
    _users.clear();
    _users.addAll(SampleData.users);
    _currentUser = null;
    _authStateController.add(null);
  }
  
  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}