// ==================================================================
// bloc/alert/alert_state.dart
// ==================================================================

part of 'alert_bloc.dart';
abstract class AlertState extends Equatable {
  const AlertState();

  @override
  List<Object?> get props => [];
}

class AlertInitial extends AlertState {
  const AlertInitial();
}

class AlertLoading extends AlertState {
  const AlertLoading();
}

class AlertsLoaded extends AlertState {
  final List<Alert> alerts;
  
  const AlertsLoaded({required this.alerts});
  
  @override
  List<Object?> get props => [alerts];
}

class AlertOperationSuccess extends AlertState {
  final String message;
  
  const AlertOperationSuccess({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class AlertError extends AlertState {
  final String message;
  
  const AlertError({required this.message});
  
  @override
  List<Object?> get props => [message];
}