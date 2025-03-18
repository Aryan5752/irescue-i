// connectivity_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:irescue/utils/offline_queue.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final OfflineQueue _offlineQueue;
  
  ConnectivityService({required OfflineQueue offlineQueue}) 
      : _offlineQueue = offlineQueue;

  // Stream of connectivity changes
  Stream<ConnectivityResult> get connectivityStream => 
      _connectivity.onConnectivityChanged;

  // Check current connectivity status
  Future<ConnectivityResult> checkConnectivity() async {
    return await _connectivity.checkConnectivity();
  }

  // Check if device is currently connected
  Future<bool> isConnected() async {
    final result = await checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Process any operations that were queued while offline
  Future<void> processOfflineQueue() async {
    if (await isConnected()) {
      await _offlineQueue.processQueue();
    }
  }

  // Add an operation to the offline queue
  Future<void> addToOfflineQueue(Map<String, dynamic> operation) async {
    await _offlineQueue.addOperation(operation);
  }
}