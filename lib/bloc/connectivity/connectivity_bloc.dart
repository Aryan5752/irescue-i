// connectivity_bloc.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../services/connectivity_service.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';


class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService _connectivityService;
  StreamSubscription? _connectivitySubscription;

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
    final connectivityResult = await _connectivityService.checkConnectivity();
    final isConnected = connectivityResult != ConnectivityResult.none;
    
    emit(isConnected 
        ? const ConnectivityConnected() 
        : const ConnectivityDisconnected());
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (ConnectivityResult result) {
        add(ConnectivityChanged(result: result));
      },
    );
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) async {
    final isConnected = event.result != ConnectivityResult.none;
    
    if (isConnected) {
      emit(const ConnectivityConnected());
      
      // Trigger offline queue processing when connection is restored
      _connectivityService.processOfflineQueue();
    } else {
      emit(const ConnectivityDisconnected());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}