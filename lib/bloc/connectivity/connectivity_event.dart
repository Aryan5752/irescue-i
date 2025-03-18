// ==================================================================
// bloc/connectivity/connectivity_event.dart
// ==================================================================
part of 'connectivity_bloc.dart';

abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object?> get props => [];
}

class ConnectivityStarted extends ConnectivityEvent {
  const ConnectivityStarted();
}

class ConnectivityChanged extends ConnectivityEvent {
  final ConnectivityResult result;
  
  const ConnectivityChanged({required this.result});
  
  @override
  List<Object?> get props => [result];
}