// lib/services/mock/mock_connectivity_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:irescue/services/connectivity_service.dart';
import '../../utils/offline_queue.dart';

class MockConnectivityService implements ConnectivityService {
  final OfflineQueue _offlineQueue;
  
  // Connectivity stream controller
  final _connectivityController = StreamController<ConnectivityResult>.broadcast();
  
  // Current connectivity status
  ConnectivityResult _currentConnectivity = ConnectivityResult.wifi;
  
  MockConnectivityService({required OfflineQueue offlineQueue}) 
      : _offlineQueue = offlineQueue {
    // Emit initial connectivity status
    Future.microtask(() {
      _connectivityController.add(_currentConnectivity);
    });
  }
  
  @override
  Stream<ConnectivityResult> get connectivityStream => _connectivityController.stream;
  
  @override
  Future<ConnectivityResult> checkConnectivity() async {
    return _currentConnectivity;
  }
  
  @override
  Future<bool> isConnected() async {
    return _currentConnectivity != ConnectivityResult.none;
  }
  
  @override
  Future<void> processOfflineQueue() async {
    if (_currentConnectivity != ConnectivityResult.none) {
      await _offlineQueue.processQueue();
    }
  }
  
  @override
  Future<void> addToOfflineQueue(Map<String, dynamic> operation) async {
    await _offlineQueue.addOperation(operation);
  }
  
  /// Simulate going offline
  void setOffline() {
    _currentConnectivity = ConnectivityResult.none;
    _connectivityController.add(_currentConnectivity);
  }
  
  /// Simulate becoming connected via WiFi
  void setOnlineWifi() {
    _currentConnectivity = ConnectivityResult.wifi;
    _connectivityController.add(_currentConnectivity);
    processOfflineQueue(); // Process pending operations
  }
  
  /// Simulate becoming connected via mobile data
  void setOnlineMobile() {
    _currentConnectivity = ConnectivityResult.mobile;
    _connectivityController.add(_currentConnectivity);
    processOfflineQueue(); // Process pending operations
  }
  
  /// Reset to default state (online via WiFi)
  void reset() {
    _currentConnectivity = ConnectivityResult.wifi;
    _connectivityController.add(_currentConnectivity);
  }
  
  /// Dispose resources
  void dispose() {
    _connectivityController.close();
  }
}