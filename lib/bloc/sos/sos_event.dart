
// ==================================================================
// bloc/sos/sos_event.dart
// ==================================================================

part of 'sos_bloc.dart';



abstract class SosEvent extends Equatable {
  const SosEvent();

  @override
  List<Object?> get props => [];
}

class SosSendRequest extends SosEvent {
  final String userId;
  final String userName;
  final String type;
  final String description;
  final List<String>? photoUrls;

  const SosSendRequest({
    required this.userId,
    required this.userName,
    required this.type,
    required this.description,
    this.photoUrls,
  });

  @override
  List<Object?> get props => [userId, type, description, photoUrls];
}

class SosCancelRequest extends SosEvent {
  final String requestId;

  const SosCancelRequest({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

class SosLoadRequests extends SosEvent {
  final String userId;
  final bool isAdmin;

  const SosLoadRequests({
    required this.userId,
    this.isAdmin = false,
  });

  @override
  List<Object?> get props => [userId, isAdmin];
}

class SosUpdateRequest extends SosEvent {
  final String requestId;
  final String? status;
  final String? assignedToId;
  final String? assignedToName;
  final String? notes;

  const SosUpdateRequest({
    required this.requestId,
    this.status,
    this.assignedToId,
    this.assignedToName,
    this.notes,
  });

  @override
  List<Object?> get props => [
    requestId, 
    status, 
    assignedToId,
    assignedToName,
    notes,
  ];
}