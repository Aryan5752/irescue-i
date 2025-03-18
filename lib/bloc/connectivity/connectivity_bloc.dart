// connectivity_bloc.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../services/connectivity_service.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

// Improvements to connectivity_bloc.dart

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService _connectivityService;
  StreamSubscription? _connectivitySubscription;
  bool _isProcessing = false;
  Timer? _debounceTimer;

  ConnectivityBloc({required ConnectivityService connectivityService})
      : _connectivityService = connectivityService,
        super(const ConnectivityInitial()) {
    on<ConnectivityStarted>(_onConnectivityStarted);
    on<ConnectivityChanged>(_onConnectivityChanged);
  }

  Future<void> _onConnectivityStarted(
    ConnectivityStarted event,
    Emitter<ConnectivityState> emit,
  ) async {
    await _connectivitySubscription?.cancel();
    
    // Initial connectivity check
    try {
      final connectivityResult = await _connectivityService.checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;
      
      emit(isConnected 
          ? const ConnectivityConnected() 
          : const ConnectivityDisconnected());
      
      // Listen for connectivity changes with debouncing
      // This prevents rapid state changes when connectivity is unstable
      _connectivitySubscription = _connectivityService.connectivityStream.listen(
        (ConnectivityResult result) {
          // Cancel existing timer
          _debounceTimer?.cancel();
          
          // Debounce for 2 seconds to make sure the connection is stable
          _debounceTimer = Timer(const Duration(seconds: 2), () {
            add(ConnectivityChanged(result: result));
          });
        },
      );
    } catch (e) {
      // In case of error checking connectivity, assume disconnected
      emit(const ConnectivityDisconnected());
    }
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) async {
    final isConnected = event.result != ConnectivityResult.none;
    final currentState = state;
    
    // Only update state if it's different from current
    if (isConnected && currentState is ConnectivityDisconnected) {
      emit(const ConnectivityConnected());
      
      // Trigger offline queue processing when connection is restored
      _processOfflineQueue();
    } else if (!isConnected && currentState is ConnectivityConnected) {
      emit(const ConnectivityDisconnected());
    }
  }

  // Process offline queue with debouncing
  Future<void> _processOfflineQueue() async {
    // Prevent multiple concurrent processing attempts
    if (_isProcessing) {
      return;
    }
    
    _isProcessing = true;
    
    try {
      await _connectivityService.processOfflineQueue();
    } catch (e) {
      // Log error but don't emit state, as this is a background operation
      print('Error processing offline queue: $e');
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}