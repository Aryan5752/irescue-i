// ==================================================================
// bloc/connectivity/connectivity_state.dart
// ==================================================================

part of 'connectivity_bloc.dart';

abstract class ConnectivityState extends Equatable {
  const ConnectivityState();
  
  @override
  List<Object?> get props => [];
}

class ConnectivityInitial extends ConnectivityState {
  const ConnectivityInitial();
}

class ConnectivityConnected extends ConnectivityState {
  const ConnectivityConnected();
}

class ConnectivityDisconnected extends ConnectivityState {
  const ConnectivityDisconnected();
}