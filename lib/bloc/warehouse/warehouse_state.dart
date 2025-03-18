// ==================================================================
// bloc/warehouse/warehouse_state.dart
// ==================================================================

part of 'warehouse_bloc.dart';

abstract class WarehouseState extends Equatable {
  const WarehouseState();

  @override
  List<Object?> get props => [];
}

class WarehouseInitial extends WarehouseState {
  const WarehouseInitial();
}

class WarehouseLoading extends WarehouseState {
  const WarehouseLoading();
}

class WarehousesLoaded extends WarehouseState {
  final List<Warehouse> warehouses;
  
  const WarehousesLoaded({required this.warehouses});
  
  @override
  List<Object?> get props => [warehouses];
}

class WarehouseOperationSuccess extends WarehouseState {
  final String message;
  
  const WarehouseOperationSuccess({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class WarehouseError extends WarehouseState {
  final String message;
  
  const WarehouseError({required this.message});
  
  @override
  List<Object?> get props => [message];
}