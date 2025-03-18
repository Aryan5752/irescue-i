// Warehouse events
// ==================================================================
// bloc/warehouse/warehouse_event.dart
// ==================================================================
part of 'warehouse_bloc.dart';
abstract class WarehouseEvent extends Equatable {
  const WarehouseEvent();

  @override
  List<Object?> get props => [];
}

class WarehousesStarted extends WarehouseEvent {
  const WarehousesStarted();
}

class WarehousesUpdated extends WarehouseEvent {
  final List<Warehouse> warehouses;
  
  const WarehousesUpdated({required this.warehouses});
  
  @override
  List<Object?> get props => [warehouses];
}

class WarehouseCreate extends WarehouseEvent {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String managerId;
  final String managerName;
  final int capacity;
  
  const WarehouseCreate({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.managerId,
    required this.managerName,
    required this.capacity,
  });
  
  @override
  List<Object?> get props => [
    name, 
    address, 
    latitude, 
    longitude, 
    managerId,
    managerName,
    capacity,
  ];
}

class WarehouseUpdate extends WarehouseEvent {
  final String warehouseId;
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? managerId;
  final String? managerName;
  final String? status;
  
  const WarehouseUpdate({
    required this.warehouseId,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.managerId,
    this.managerName,
    this.status,
  });
  
  @override
  List<Object?> get props => [
    warehouseId,
    name,
    address,
    latitude,
    longitude,
    managerId,
    managerName,
    status,
  ];
}

class ResourceAdd extends WarehouseEvent {
  final String warehouseId;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final int minStockLevel;
  final DateTime expiryDate;
  
  const ResourceAdd({
    required this.warehouseId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minStockLevel,
    required this.expiryDate,
  });
  
  @override
  List<Object?> get props => [
    warehouseId,
    name,
    category,
    quantity,
    unit,
    minStockLevel,
    expiryDate,
  ];
}

class ResourceUpdate extends WarehouseEvent {
  final String warehouseId;
  final String resourceId;
  final String? name;
  final String? category;
  final int? quantity;
  final String? unit;
  final int? minStockLevel;
  final DateTime? expiryDate;
  final String? status;
  
  const ResourceUpdate({
    required this.warehouseId,
    required this.resourceId,
    this.name,
    this.category,
    this.quantity,
    this.unit,
    this.minStockLevel,
    this.expiryDate,
    this.status,
  });
  
  @override
  List<Object?> get props => [
    warehouseId,
    resourceId,
    name,
    category,
    quantity,
    unit,
    minStockLevel,
    expiryDate,
    status,
  ];
}

class ResourceAllocate extends WarehouseEvent {
  final String warehouseId;
  final String resourceId;
  final int quantity;
  final String allocatedById;
  final String allocatedByName;
  final String destinationId;
  final String destinationType; // SOS, emergency, community
  final String? notes;
  
  const ResourceAllocate({
    required this.warehouseId,
    required this.resourceId,
    required this.quantity,
    required this.allocatedById,
    required this.allocatedByName,
    required this.destinationId,
    required this.destinationType,
    this.notes,
  });
  
  @override
  List<Object?> get props => [
    warehouseId,
    resourceId,
    quantity,
    allocatedById,
    allocatedByName,
    destinationId,
    destinationType,
    notes,
  ];
}

class ResourceTransfer extends WarehouseEvent {
  final String sourceWarehouseId;
  final String destinationWarehouseId;
  final String resourceId;
  final int quantity;
  final String transferById;
  final String transferByName;
  final String? notes;
  
  const ResourceTransfer({
    required this.sourceWarehouseId,
    required this.destinationWarehouseId,
    required this.resourceId,
    required this.quantity,
    required this.transferById,
    required this.transferByName,
    this.notes,
  });
  
  @override
  List<Object?> get props => [
    sourceWarehouseId,
    destinationWarehouseId,
    resourceId,
    quantity,
    transferById,
    transferByName,
    notes,
  ];
}