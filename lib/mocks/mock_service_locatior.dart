// lib/services/mock/service_locator.dart

import 'package:irescue/services/auth_service.dart';
import 'package:irescue/services/connectivity_service.dart';
import 'package:irescue/services/database_service.dart';
import 'package:irescue/services/location_service.dart';
import 'mock_auth_service.dart';
import 'mock_database_service.dart';
import 'mock_connectivity_service.dart';
import 'mock_location_service.dart';
import '../../utils/offline_queue.dart';

/// A service locator for accessing mock service implementations
class ServiceLocator {
  // Singleton pattern
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  
  ServiceLocator._internal();
  
  // Service instances
  late AuthService authService;
  late DatabaseService databaseService;
  late LocationService locationService;
  late ConnectivityService connectivityService;
  late OfflineQueue offlineQueue;
  
  bool _initialized = false;
  
  /// Initialize all mock services
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Create instances of mock services
    databaseService = MockDatabaseService();
    locationService = MockLocationService();
    offlineQueue = OfflineQueue(databaseService: databaseService);
    connectivityService = MockConnectivityService(offlineQueue: offlineQueue);
    authService = MockAuthService();
    
    // Initialize mock services
    await (locationService as MockLocationService).initialize();
    await (databaseService as MockDatabaseService).initialize();
    
    _initialized = true;
  }
  
  /// Reset all mock services to initial state
  /// Useful for testing and demonstrations
  Future<void> reset() async {
    if (!_initialized) return;
    
    // Reset each service
    await (databaseService as MockDatabaseService).reset();
    await (authService as MockAuthService).reset();
    (locationService as MockLocationService).reset();
    (connectivityService as MockConnectivityService).reset();
  }
  
  /// Dispose all services
  void dispose() {
    if (!_initialized) return;
    
    (databaseService as MockDatabaseService).dispose();
    (authService as MockAuthService).dispose();
    (locationService as MockLocationService).dispose();
    (connectivityService as MockConnectivityService).dispose();
    
    _initialized = false;
  }
}

// Global instance for easy access throughout the app
final serviceLocator = ServiceLocator();