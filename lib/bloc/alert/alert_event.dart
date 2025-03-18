// ==================================================================
// bloc/alert/alert_event.dart
// ==================================================================


part of 'alert_bloc.dart';

abstract class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object?> get props => [];
}

class AlertsStarted extends AlertEvent {
  final bool isAdmin;
  
  const AlertsStarted({this.isAdmin = false});
  
  @override
  List<Object?> get props => [isAdmin];
}

class AlertsUpdated extends AlertEvent {
  final List<Alert> alerts;
  
  const AlertsUpdated({required this.alerts});
  
  @override
  List<Object?> get props => [alerts];
}

class AlertCreate extends AlertEvent {
  final String title;
  final String description;
  final String type;
  final int severity;
  final double latitude;
  final double longitude;
  final double radius;
  final String createdById;
  final String createdByName;
  
  const AlertCreate({
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.createdById,
    required this.createdByName,
  });
  
  @override
  List<Object?> get props => [
    title, 
    description, 
    type, 
    severity, 
    latitude, 
    longitude, 
    radius,
    createdById,
    createdByName,
  ];
}

class AlertUpdate extends AlertEvent {
  final String alertId;
  final String? title;
  final String? description;
  final int? severity;
  final bool? active;
  final double? radius;
  
  const AlertUpdate({
    required this.alertId,
    this.title,
    this.description,
    this.severity,
    this.active,
    this.radius,
  });
  
  @override
  List<Object?> get props => [
    alertId, 
    title, 
    description, 
    severity, 
    active,
    radius,
  ];
}

class AlertDelete extends AlertEvent {
  final String alertId;
  
  const AlertDelete({required this.alertId});
  
  @override
  List<Object?> get props => [alertId];
}
