// auth_bloc.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../../models/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  StreamSubscription? _authSubscription;

  AuthBloc({
    required AuthService authService,
    required DatabaseService databaseService,
  })  : _authService = authService,
        super(const AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthProfileUpdateRequested>(_onAuthProfileUpdateRequested);
    on<AuthPasswordChangeRequested>(_onAuthPasswordChangeRequested);
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      
      // Check current authentication state
      final currentUser = _authService.currentUser;
      
      if (currentUser != null) {
        // User is logged in, get user data
        final userData = await _authService.getUserData(currentUser.uid);
        
        if (userData != null) {
          emit(AuthAuthenticated(user: userData));
        } else {
          // User exists in Firebase Auth but not in Firestore
          emit(const AuthUnauthenticated());
        }
      } else {
        // No user is logged in
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Authentication error: ${e.toString()}'));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      
      // Attempt to sign in
      final user = await _authService.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      
      // Attempt to register
      final user = await _authService.registerWithEmailAndPassword(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
        phone: event.phone,
        address: event.address,
      );
      
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      
      // Sign out
      await _authService.signOut();
      
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Logout error: ${e.toString()}'));
    }
  }

  Future<void> _onAuthProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      
      // Get current authenticated state
      final currentState = state;
      
      if (currentState is AuthAuthenticated) {
        // Update user profile
        final updatedUser = await _authService.updateUserProfile(
          userId: currentState.user.id,
          name: event.name,
          phone: event.phone,
          address: event.address,
          latitude: event.latitude,
          longitude: event.longitude,
          preferences: event.preferences,
          subscriptions: event.subscriptions,
        );
        
        emit(AuthAuthenticated(user: updatedUser));
      } else {
        emit(const AuthError(message: 'You must be logged in to update your profile'));
      }
    } catch (e) {
      emit(AuthError(message: 'Profile update error: ${e.toString()}'));
    }
  }

  Future<void> _onAuthPasswordChangeRequested(
    AuthPasswordChangeRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      
      // Change password
      await _authService.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      
      // Get current user data
      final currentUser = _authService.currentUser;
      
      if (currentUser != null) {
        final userData = await _authService.getUserData(currentUser.uid);
        
        if (userData != null) {
          emit(AuthAuthenticated(user: userData));
        } else {
          emit(const AuthError(message: 'Failed to retrieve user data after password change'));
        }
      } else {
        emit(const AuthError(message: 'User not found after password change'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}