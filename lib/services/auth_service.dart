// auth_service.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_models;

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current Firebase user
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;
  
  // Stream of auth state changes
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();
  
  // Sign in with email and password
  Future<app_models.User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      
      if (user == null) {
        throw Exception('Sign in failed: No user returned');
      }
      
      // Update last login timestamp
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'lastLogin': DateTime.now().toIso8601String(),
      });
      
      // Get user data from Firestore
      final userData = await getUserData(user.uid);
      
      if (userData == null) {
        throw Exception('User data not found');
      }
      
      return userData;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email format');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled');
      } else {
        throw Exception('Sign in error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Sign in error: $e');
    }
  }
  
  // Register with email and password
  Future<app_models.User> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? address,
  }) async {
    try {
      // Register with Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      
      if (user == null) {
        throw Exception('Registration failed: No user returned');
      }
      
      // Update user profile
      await user.updateDisplayName(name);
      
      // Set default values for new user
      final newUser = app_models.User(
        id: user.uid,
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
      
      // Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(newUser.toMap());
      
      return newUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for that email');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email format');
      } else {
        throw Exception('Registration error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out error: $e');
    }
  }
  
  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email format');
      } else {
        throw Exception('Password reset error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Password reset error: $e');
    }
  }
  
  // Get user data from Firestore
  Future<app_models.User?> getUserData(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (!docSnapshot.exists) {
        return null;
      }
      
      final data = docSnapshot.data();
      if (data == null) {
        return null;
      }
      
      return app_models.User.fromMap({
        ...data,
        'id': userId,
      });
    } catch (e) {
      throw Exception('Get user data error: $e');
    }
  }
  
  // Update user profile
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
    try {
      // Get current user data
      final currentUserData = await getUserData(userId);
      
      if (currentUserData == null) {
        throw Exception('User data not found');
      }
      
      // Update Firebase Auth display name if provided
      if (name != null && currentUser != null) {
        await currentUser!.updateDisplayName(name);
      }
      
      // Create update data map
      final Map<String, dynamic> updateData = {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (preferences != null) 'preferences': preferences,
        if (subscriptions != null) 'subscriptions': subscriptions,
      };
      
      // Update Firestore document
      await _firestore
          .collection('users')
          .doc(userId)
          .update(updateData);
      
      // Get updated user data
      final updatedUserData = await getUserData(userId);
      
      if (updatedUserData == null) {
        throw Exception('Failed to retrieve updated user data');
      }
      
      return updatedUserData;
    } catch (e) {
      throw Exception('Update profile error: $e');
    }
  }
  
  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      
      if (user == null) {
        throw Exception('No user is signed in');
      }
      
      // Verify current password by re-authenticating
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Change password
      await user.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Current password is incorrect');
      } else if (e.code == 'weak-password') {
        throw Exception('The new password is too weak');
      } else {
        throw Exception('Change password error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Change password error: $e');
    }
  }
  
  // Verify user email
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      
      if (user == null) {
        throw Exception('No user is signed in');
      }
      
      await user.sendEmailVerification();
    } catch (e) {
      throw Exception('Email verification error: $e');
    }
  }
  
  // Check if user is verified
  Future<bool> isEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      
      if (user == null) {
        return false;
      }
      
      // Reload user to get latest verification status
      await user.reload();
      return user.emailVerified;
    } catch (e) {
      throw Exception('Email verification check error: $e');
    }
  }
  
  // Update user verification status in Firestore
  Future<void> updateVerificationStatus(String userId, bool isVerified) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'isVerified': isVerified,
      });
    } catch (e) {
      throw Exception('Update verification status error: $e');
    }
  }
  
  // Delete user account
  Future<void> deleteAccount({required String password}) async {
    try {
      final user = _firebaseAuth.currentUser;
      
      if (user == null) {
        throw Exception('No user is signed in');
      }
      
      // Re-authenticate before deleting
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Delete user data from Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .delete();
      
      // Delete Firebase Auth user
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Password is incorrect');
      } else if (e.code == 'requires-recent-login') {
        throw Exception('Please re-login and try again');
      } else {
        throw Exception('Delete account error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Delete account error: $e');
    }
  }
}