// lib/services/connectivity_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Interface for connectivity services.
/// 
/// This abstract class defines the contract that both real and mock
/// implementations must fulfill.
abstract class ConnectivityService {
  /// A stream of connectivity status updates.
  /// 
  /// This stream emits [ConnectivityResult] values when connectivity changes.
  Stream<ConnectivityResult> get connectivityStream;
  
  /// Checks the current connectivity status.
  /// 
  /// Returns a [ConnectivityResult] indicating the current network status.
  Future<ConnectivityResult> checkConnectivity();
  
  /// Checks if the device is currently connected to the internet.
  /// 
  /// Returns true if the device has an active internet connection.
  Future<bool> isConnected();
  
  /// Processes any operations that were queued while offline.
  /// 
  /// This is called when connectivity is restored to sync pending operations.
  Future<void> processOfflineQueue();
  
  /// Adds an operation to the offline queue for processing when connectivity is restored.
  /// 
  /// [operation] is a map containing the operation details.
  Future<void> addToOfflineQueue(Map<String, dynamic> operation);
}