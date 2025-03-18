// alert_bloc.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irescue/models/alert.dart';
import 'package:irescue/services/connectivity_service.dart';
import 'package:irescue/services/database_service.dart';
import 'package:irescue/services/location_service.dart';

part 'alert_event.dart';
part 'alert_state.dart';


class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final DatabaseService _databaseService;
  final LocationService _locationService = LocationService();
  final ConnectivityService _connectivityService;
  StreamSubscription? _alertsSubscription;

  AlertBloc({
    required DatabaseService databaseService,
    required ConnectivityService connectivityService,
  })  : _databaseService = databaseService,
        _connectivityService = connectivityService,
        super(const AlertInitial()) {
    on<AlertsStarted>(_onAlertsStarted);
    on<AlertsUpdated>(_onAlertsUpdated);
    on<AlertCreate>(_onAlertCreate);
    on<AlertUpdate>(_onAlertUpdate);
    on<AlertDelete>(_onAlertDelete);
  }

  Future<void> _onAlertsStarted(
    AlertsStarted event,
    Emitter<AlertState> emit,
  ) async {
    try {
      emit(const AlertLoading());
      
      // Cancel existing subscription if any
      await _alertsSubscription?.cancel();
      
      // Check if user is admin or civilian
      if (event.isAdmin) {
        // For admins, listen to all alerts
        _alertsSubscription = _databaseService
            .streamCollection(collection: 'alerts')
            .listen((alertsData) {
          final alerts = alertsData
              .map((alertData) => Alert.fromMap(alertData))
              .toList();
          
          add(AlertsUpdated(alerts: alerts));
        });
      } else {
        // For civilians, we need to filter alerts by location
        // First get user's location
        final position = await _locationService.getCurrentPosition();
        
        // Then listen to alerts and filter by radius
        _alertsSubscription = _databaseService
            .streamCollection(collection: 'alerts')
            .listen((alertsData) {
          final allAlerts = alertsData
              .map((alertData) => Alert.fromMap(alertData))
              .toList();
              
          // Filter alerts by location and radius
          final relevantAlerts = allAlerts.where((alert) {
            // Calculate distance between user and alert
            final distance = _locationService.calculateDistance(
              position.latitude,
              position.longitude,
              alert.latitude, 
              alert.longitude,
            );
            
            // Check if user is within alert radius
            return distance <= alert.radius;
          }).toList();
          
          add(AlertsUpdated(alerts: relevantAlerts));
        });
      }
    } catch (e) {
      emit(AlertError(message: 'Failed to load alerts: ${e.toString()}'));
    }
  }

  void _onAlertsUpdated(
    AlertsUpdated event,
    Emitter<AlertState> emit,
  ) {
    // Sort alerts by timestamp, newest first
    final sortedAlerts = List<Alert>.from(event.alerts)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
    emit(AlertsLoaded(alerts: sortedAlerts));
  }

  Future<void> _onAlertCreate(
    AlertCreate event,
    Emitter<AlertState> emit,
  ) async {
    try {
      emit(const AlertLoading());
      
      // Generate an ID for the alert
      final String alertId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create alert object
      final Alert alert = Alert(
        id: alertId,
        title: event.title,
        description: event.description,
        type: event.type,
        severity: event.severity,
        latitude: event.latitude,
        longitude: event.longitude,
        radius: event.radius,
        timestamp: DateTime.now(),
        active: true,
        createdById: event.createdById,
        createdByName: event.createdByName,
      );
      
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        // Save alert to database
        await _databaseService.setData(
          collection: 'alerts',
          documentId: alertId,
          data: alert.toMap(),
        );
      } else {
        // Add to offline queue
        await _connectivityService.addToOfflineQueue({
          'type': 'create',
          'collection': 'alerts',
          'documentId': alertId,
          'data': alert.toMap(),
        });
      }
      
      emit(const AlertOperationSuccess(message: 'Alert created successfully'));
    } catch (e) {
      emit(AlertError(message: 'Failed to create alert: ${e.toString()}'));
    }
  }

  Future<void> _onAlertUpdate(
    AlertUpdate event,
    Emitter<AlertState> emit,
  ) async {
    try {
      emit(const AlertLoading());
      
      // Prepare update data
      final Map<String, dynamic> updateData = {
        if (event.title != null) 'title': event.title,
        if (event.description != null) 'description': event.description,
        if (event.severity != null) 'severity': event.severity,
        if (event.active != null) 'active': event.active,
        if (event.radius != null) 'radius': event.radius,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        // Update alert in database
        await _databaseService.updateData(
          collection: 'alerts',
          documentId: event.alertId,
          data: updateData,
        );
      } else {
        // Add to offline queue
        await _connectivityService.addToOfflineQueue({
          'type': 'update',
          'collection': 'alerts',
          'documentId': event.alertId,
          'data': updateData,
        });
      }
      
      emit(const AlertOperationSuccess(message: 'Alert updated successfully'));
    } catch (e) {
      emit(AlertError(message: 'Failed to update alert: ${e.toString()}'));
    }
  }

  Future<void> _onAlertDelete(
    AlertDelete event,
    Emitter<AlertState> emit,
  ) async {
    try {
      emit(const AlertLoading());
      
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        // Delete alert from database
        await _databaseService.deleteData(
          collection: 'alerts',
          documentId: event.alertId,
        );
      } else {
        // Add to offline queue
        await _connectivityService.addToOfflineQueue({
          'type': 'delete',
          'collection': 'alerts',
          'documentId': event.alertId,
          'data': {},
        });
      }
      
      emit(const AlertOperationSuccess(message: 'Alert deleted successfully'));
    } catch (e) {
      emit(AlertError(message: 'Failed to delete alert: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _alertsSubscription?.cancel();
    return super.close();
  }
}