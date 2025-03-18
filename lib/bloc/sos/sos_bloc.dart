// sos_bloc.dart
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:irescue/models/sos_request.dart';
import 'package:irescue/services/connectivity_service.dart';
import 'package:irescue/services/database_service.dart';
import 'package:irescue/services/location_service.dart';
part 'sos_event.dart';
part 'sos_state.dart';

class SosBloc extends Bloc<SosEvent, SosState> {
  final DatabaseService _databaseService;
  final LocationService _locationService;
  final ConnectivityService _connectivityService;

 SosBloc({
  required DatabaseService databaseService,
  required ConnectivityService connectivityService,
  required LocationService locationService,
}) : _databaseService = databaseService,
     _connectivityService = connectivityService,
     _locationService = locationService,
     super(SosInitial()) {
    on<SosSendRequest>(_onSosSendRequest);
    on<SosCancelRequest>(_onSosCancelRequest);
    on<SosLoadRequests>(_onSosLoadRequests);
    on<SosUpdateRequest>(_onSosUpdateRequest);
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

        requests = result.map((doc) => SosRequest.fromMap(doc)).toList();
      } else {
        // For regular users, only load their own requests
        final result = await _databaseService.getCollectionWhere(
          collection: 'sosRequests',
          field: 'userId',
          isEqualTo: event.userId,
        );

        requests = result.map((doc) => SosRequest.fromMap(doc)).toList();
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
            if (event.assignedToName != null)
              'assignedToName': event.assignedToName,
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
            if (event.assignedToName != null)
              'assignedToName': event.assignedToName,
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

  // Improvements to SosBloc in sos_bloc.dart

  Future<void> _onSosSendRequest(
    SosSendRequest event,
    Emitter<SosState> emit,
  ) async {
    try {
      emit(SosLoading());

      // Validate input parameters
      if (event.userId.isEmpty ||
          event.userName.isEmpty ||
          event.type.isEmpty ||
          event.description.isEmpty) {
        emit(
          const SosError(message: 'Please provide all required information'),
        );
        return;
      }

      // Get current location with timeout and retry
      Position position;
      try {
        position = await _locationService.getCurrentPosition().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Location request timed out');
          },
        );
      } catch (locationError) {
        // Retry once with best available
        try {
          emit(
            const SosError(
              message: 'Location accuracy may be limited. Retrying...',
            ),
          );
          position = await _locationService.getLastKnownPosition();
        } catch (finalError) {
          emit(
            SosError(
              message:
                  'Could not determine your location. Please try again or enter location manually. Error: ${finalError.toString()}',
            ),
          );
          return;
        }
      }

      // Create SOS request
      final String requestId = DateTime.now().millisecondsSinceEpoch.toString();
      final SosRequest request = SosRequest(
        id: requestId,
        userId: event.userId,
        userName: event.userName,
        type: event.type,
        description: event.description,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        status: 'pending',
        photoUrls: event.photoUrls ?? [],
      );

      // Check connectivity
      final isConnected = await _connectivityService.isConnected();

      try {
        if (isConnected) {
          // Save to database
          await _databaseService.setData(
            collection: 'sosRequests',
            documentId: request.id,
            data: request.toMap(),
          );

          // For a real app: trigger notification to emergency responders
          // For demo, we just output to console
          print('SOS REQUEST SENT: ${request.type} - ${request.description}');
          print('LOCATION: ${request.latitude}, ${request.longitude}');
        } else {
          // Flag this as a high-priority offline item
          final requestData = {
            'type': 'create',
            'collection': 'sosRequests',
            'documentId': request.id,
            'data': request.toMap(),
            'priority': 'high', // Mark as high priority
          };

          // Add to offline queue
          await _connectivityService.addToOfflineQueue(requestData);

          // Store locally for immediate display
          // (In a real app, we would store this in local device storage)
        }

        emit(SosSuccess(request: request));
      } catch (dbError) {
        emit(
          SosError(
            message:
                'SOS request created but may not have been sent to the server. ' +
                'Please try again when connected. Error: ${dbError.toString()}',
          ),
        );
      }
    } catch (e) {
      emit(SosError(message: 'Failed to send SOS request: ${e.toString()}'));
    }
  }
}
