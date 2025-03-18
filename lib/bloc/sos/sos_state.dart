// ==================================================================
// bloc/sos/sos_state.dart
// ==================================================================

part of 'sos_bloc.dart';


abstract class SosState extends Equatable {
  const SosState();

  @override
  List<Object?> get props => [];
}

class SosInitial extends SosState {}

class SosLoading extends SosState {}

class SosSuccess extends SosState {
  final SosRequest request;

  const SosSuccess({required this.request});

  @override
  List<Object?> get props => [request];
}

class SosOperationSuccess extends SosState {
  final String message;

  const SosOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class SosRequestsLoaded extends SosState {
  final List<SosRequest> requests;

  const SosRequestsLoaded({required this.requests});

  @override
  List<Object?> get props => [requests];
}

class SosError extends SosState {
  final String message;

  const SosError({required this.message});

  @override
  List<Object?> get props => [message];
}