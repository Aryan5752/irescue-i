// sos_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../models/sos_request.dart';
import '../../../services/database_service.dart';
import '../../../services/location_service.dart';
import '../../../services/connectivity_service.dart';
part 'sos_event.dart';
part 'sos_state.dart';

class SosBloc extends Bloc<SosEvent, SosState> {
  final DatabaseService _databaseService;
  // final LocationService _locationService;
  final ConnectivityService _connectivityService;

  SosBloc({
    required DatabaseService databaseService,
    // required LocationService locationService,
    required ConnectivityService connectivityService,
  })  : _databaseService = databaseService,
        // _locationService = locationService,
        _connectivityService = connectivityService,
        super(SosInitial()) {
    on<SosSendRequest>(_onSosSendRequest);
    on<SosCancelRequest>(_onSosCancelRequest);
    on<SosLoadRequests>(_onSosLoadRequests);
    on<SosUpdateRequest>(_onSosUpdateRequest);
  }

  Future<void> _onSosSendRequest(
    SosSendRequest event,
    Emitter<SosState> emit,
  ) async {
    try {
      emit(SosLoading());
      
      // Get current location
      // final Position position = await _locationService.getCurrentPosition();
      
      // Create SOS request
      final SosRequest request = SosRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: event.userId,
        userName: event.userName,
        type: event.type,
        description: event.description,
        latitude: 00.0000, // position.latitude,
        longitude: 00.0000, // position.longitude,
        timestamp: DateTime.now(),
        status: 'pending',
        photoUrls: event.photoUrls ?? [],
      );
      
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        // Save to database
        await _databaseService.setData(
          collection: 'sosRequests',
          documentId: request.id,
          data: request.toMap(),
        );
      } else {
        // Add to offline queue
        await _connectivityService.addToOfflineQueue({
          'type': 'create',
          'collection': 'sosRequests',
          'documentId': request.id,
          'data': request.toMap(),
        });
        
        // Also save locally for immediate feedback
        // This would typically use a local database like Hive or SQLite
        // For simplicity in this demo, we're not implementing full local storage
      }
      
      emit(SosSuccess(request: request));
    } catch (e) {
      emit(SosError(message: 'Failed to send SOS request: ${e.toString()}'));
    }
  }

  Future<void> _onSosCancelRequest(
    SosCancelRequest event,
    Emitter<SosState> emit,
  ) async {
    try {
      emit(SosLoading());
      
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        // Update status to 'cancelled'
        await _databaseService.updateData(
          collection: 'sosRequests',
          documentId: event.requestId,
          data: {'status': 'cancelled'},
        );
      } else {
        // Add to offline queue
        await _connectivityService.addToOfflineQueue({
          'type': 'update',
          'collection': 'sosRequests',
          'documentId': event.requestId,
          'data': {'status': 'cancelled'},
        });
      }
      
      emit(SosOperationSuccess(message: 'SOS request cancelled'));
    } catch (e) {
      emit(SosError(message: 'Failed to cancel SOS request: ${e.toString()}'));
    }
  }

  Future<void> _onSosLoadRequests(
    SosLoadRequests event,
    Emitter<SosState> emit,
  ) async {
    try {
      emit(SosLoading());
      
      // Load requests based on user type (admin sees all, users see their own)
      List<SosRequest> requests = [];
      
      if (event.isAdmin) {
        // For admins, load all requests or filter by area if needed
        final result = await _databaseService.getCollection(
          collection: 'sosRequests',
        );
        
        requests = result
            .map((doc) => SosRequest.fromMap(doc))
            .toList();
      } else {
        // For regular users, only load their own requests
        final result = await _databaseService.getCollectionWhere(
          collection: 'sosRequests',
          field: 'userId',
          isEqualTo: event.userId,
        );
        
        requests = result
            .map((doc) => SosRequest.fromMap(doc))
            .toList();
      }
      
      // Sort by timestamp (newest first)
      requests.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      emit(SosRequestsLoaded(requests: requests));
    } catch (e) {
      emit(SosError(message: 'Failed to load SOS requests: ${e.toString()}'));
    }
  }

  Future<void> _onSosUpdateRequest(
    SosUpdateRequest event,
    Emitter<SosState> emit,
  ) async {
    try {
      emit(SosLoading());
      
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        // Update SOS request
        await _databaseService.updateData(
          collection: 'sosRequests',
          documentId: event.requestId,
          data: {
            if (event.status != null) 'status': event.status,
            if (event.assignedToId != null) 'assignedToId': event.assignedToId,
            if (event.assignedToName != null) 'assignedToName': event.assignedToName,
            if (event.notes != null) 'notes': event.notes,
            'lastUpdated': DateTime.now().toIso8601String(),
          },
        );
      } else {
        // Add to offline queue
        await _connectivityService.addToOfflineQueue({
          'type': 'update',
          'collection': 'sosRequests',
          'documentId': event.requestId,
          'data': {
            if (event.status != null) 'status': event.status,
            if (event.assignedToId != null) 'assignedToId': event.assignedToId,
            if (event.assignedToName != null) 'assignedToName': event.assignedToName,
            if (event.notes != null) 'notes': event.notes,
            'lastUpdated': DateTime.now().toIso8601String(),
          },
        });
      }
      
      emit(SosOperationSuccess(message: 'SOS request updated'));
    } catch (e) {
      emit(SosError(message: 'Failed to update SOS request: ${e.toString()}'));
    }
  }
}