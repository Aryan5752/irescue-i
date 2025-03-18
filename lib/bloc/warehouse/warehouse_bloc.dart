// warehouse_bloc.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/warehouse.dart';
import '../../../models/resource.dart';
import '../../../services/database_service.dart';
import '../../../services/connectivity_service.dart';

part 'warehouse_event.dart';
part 'warehouse_state.dart';


class WarehouseBloc extends Bloc<WarehouseEvent, WarehouseState> {
  final DatabaseService _databaseService;
  final ConnectivityService _connectivityService;
  StreamSubscription? _warehousesSubscription;

  WarehouseBloc({
    required DatabaseService databaseService,
    required ConnectivityService connectivityService,
  })  : _databaseService = databaseService,
        _connectivityService = connectivityService,
        super(const WarehouseInitial()) {
    on<WarehousesStarted>(_onWarehousesStarted);
    on<WarehousesUpdated>(_onWarehousesUpdated);
    on<WarehouseCreate>(_onWarehouseCreate);
    on<WarehouseUpdate>(_onWarehouseUpdate);
    on<ResourceAdd>(_onResourceAdd);
    on<ResourceUpdate>(_onResourceUpdate);
    on<ResourceAllocate>(_onResourceAllocate);
    on<ResourceTransfer>(_onResourceTransfer);
  }

  Future<void> _onWarehousesStarted(
    WarehousesStarted event,
    Emitter<WarehouseState> emit,
  ) async {
    try {
      emit(const WarehouseLoading());
      
      // Cancel existing subscription if any
      await _warehousesSubscription?.cancel();
      
      // Listen to warehouses collection
      _warehousesSubscription = _databaseService
          .streamCollection(collection: 'warehouses')
          .listen((warehousesData) {
        final warehouses = warehousesData
            .map((warehouseData) => Warehouse.fromMap(warehouseData))
            .toList();
        
        add(WarehousesUpdated(warehouses: warehouses));
      });
    } catch (e) {
      emit(WarehouseError(message: 'Failed to load warehouses: ${e.toString()}'));
    }
  }

  void _onWarehousesUpdated(
    WarehousesUpdated event,
    Emitter<WarehouseState> emit,
  ) {
    emit(WarehousesLoaded(warehouses: event.warehouses));
  }

  Future<void> _onWarehouseCreate(
    WarehouseCreate event,
    Emitter<WarehouseState> emit,
  ) async {
    try {
      emit(const WarehouseLoading());
      
      // Generate an ID for the warehouse
      final String warehouseId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create warehouse object
      final Warehouse warehouse = Warehouse(
        id: warehouseId,
        name: event.name,
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
        managerId: event.managerId,
        managerName: event.managerName,
        resources: const [], // Start with empty resources
        capacity: event.capacity,
        usedCapacity: 0, // Start with zero used capacity
        status: 'active',
        createdAt: DateTime.now(),
      );
      
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        // Save warehouse to database
        await _databaseService.setData(
          collection: 'warehouses',
          documentId: warehouseId,
          data: warehouse.toMap(),
        );
      } else {
        // Add to offline queue
        await _connectivityService.addToOfflineQueue({
          'type': 'create',
          'collection': 'warehouses',
          'documentId': warehouseId,
          'data': warehouse.toMap(),
        });
      }
      
      emit(const WarehouseOperationSuccess(message: 'Warehouse created successfully'));
    } catch (e) {
      emit(WarehouseError(message: 'Failed to create warehouse: ${e.toString()}'));
    }
  }

  Future<void> _onWarehouseUpdate(
    WarehouseUpdate event,
    Emitter<WarehouseState> emit,
  ) async {
    try {
      emit(const WarehouseLoading());
      
      // Prepare update data
      final Map<String, dynamic> updateData = {
        if (event.name != null) 'name': event.name,
        if (event.address != null) 'address': event.address,
        if (event.latitude != null) 'latitude': event.latitude,
        if (event.longitude != null) 'longitude': event.longitude,
        if (event.managerId != null) 'managerId': event.managerId,
        if (event.managerName != null) 'managerName': event.managerName,
        if (event.status != null) 'status': event.status,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        // Update warehouse in database
        await _databaseService.updateData(
          collection: 'warehouses',
          documentId: event.warehouseId,
          data: updateData,
        );
      } else {
        // Add to offline queue
        await _connectivityService.addToOfflineQueue({
          'type': 'update',
          'collection': 'warehouses',
          'documentId': event.warehouseId,
          'data': updateData,
        });
      }
      
      emit(const WarehouseOperationSuccess(message: 'Warehouse updated successfully'));
    } catch (e) {
      emit(WarehouseError(message: 'Failed to update warehouse: ${e.toString()}'));
    }
  }

   Future<void> _onResourceUpdate(
    ResourceUpdate event,
    Emitter<WarehouseState> emit,
  ) async {
    try {
      emit(const WarehouseLoading());
      
      // First get the current warehouse
      final warehouseData = await _databaseService.getData(
        collection: 'warehouses',
        documentId: event.warehouseId,
      );
      
      if (warehouseData == null) {
        emit(WarehouseError(message: 'Warehouse not found'));
        return;
      }
      
      final warehouse = Warehouse.fromMap(warehouseData);
      
      // Find the resource
      final resourceIndex = warehouse.resources.indexWhere(
        (r) => r.id == event.resourceId
      );
      
      if (resourceIndex == -1) {
        emit(WarehouseError(message: 'Resource not found'));
        return;
      }
      
      final oldResource = warehouse.resources[resourceIndex];
      
      // Calculate capacity change
      final int quantityChange = (event.quantity ?? oldResource.quantity) - oldResource.quantity;
      final int newUsedCapacity = warehouse.usedCapacity + quantityChange;
      
      // Check if warehouse has enough capacity for increase
      if (quantityChange > 0 && newUsedCapacity > warehouse.capacity) {
        emit(WarehouseError(message: 'Warehouse does not have enough capacity'));
        return;
      }
      
      // Update resource
      final Resource updatedResource = oldResource.copyWith(
        name: event.name,
        category: event.category,
        quantity: event.quantity,
        unit: event.unit,
        minStockLevel: event.minStockLevel,
        expiryDate: event.expiryDate,
        status: event.status,
      );
      
      // Update resources list
      final List<Resource> updatedResources = List.from(warehouse.resources);
      updatedResources[resourceIndex] = updatedResource;
      
      // Update warehouse
      final Map<String, dynamic> updateData = {
        'resources': updatedResources.map((r) => r.toMap()).toList(),
        'usedCapacity': newUsedCapacity,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        // Update warehouse in database
        await _databaseService.updateData(
          collection: 'warehouses',
          documentId: event.warehouseId,
          data: updateData,
        );
      } else {
        // Add to offline queue
        await _connectivityService.addToOfflineQueue({
          'type': 'update',
          'collection': 'warehouses',
          'documentId': event.warehouseId,
          'data': updateData,
        });
      }
      
      emit(const WarehouseOperationSuccess(message: 'Resource updated successfully'));
    } catch (e) {
      emit(WarehouseError(message: 'Failed to update resource: ${e.toString()}'));
    }
  }

  Future<void> _onResourceAllocate(
    ResourceAllocate event,
    Emitter<WarehouseState> emit,
  ) async {
    try {
      emit(const WarehouseLoading());
      
      // First get the current warehouse
      final warehouseData = await _databaseService.getData(
        collection: 'warehouses',
        documentId: event.warehouseId,
      );
      
      if (warehouseData == null) {
        emit(WarehouseError(message: 'Warehouse not found'));
        return;
      }
      
      final warehouse = Warehouse.fromMap(warehouseData);
      
      // Find the resource
      final resourceIndex = warehouse.resources.indexWhere(
        (r) => r.id == event.resourceId
      );
      
      if (resourceIndex == -1) {
        emit(WarehouseError(message: 'Resource not found'));
        return;
      }
      
      final resource = warehouse.resources[resourceIndex];
      
      // Check if there's enough quantity
      if (resource.quantity < event.quantity) {
        emit(WarehouseError(message: 'Not enough resources available'));
        return;
      }
      
      // Calculate new quantity
      final int newQuantity = resource.quantity - event.quantity;
      
      // Update resource
      final Resource updatedResource = resource.copyWith(
        quantity: newQuantity,
        status: newQuantity > 0 ? 'available' : 'allocated',
      );
      
      // Update resources list
      final List<Resource> updatedResources = List.from(warehouse.resources);
      updatedResources[resourceIndex] = updatedResource;
      
      // Calculate new used capacity
      final int newUsedCapacity = warehouse.usedCapacity - event.quantity;
      
      // Update warehouse
      final Map<String, dynamic> updateData = {
        'resources': updatedResources.map((r) => r.toMap()).toList(),
        'usedCapacity': newUsedCapacity,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        // Update warehouse in database
        await _databaseService.updateData(
          collection: 'warehouses',
          documentId: event.warehouseId,
          data: updateData,
        );
        
        // Optionally, you could log the allocation in a separate collection
        // This would track who allocated resources and where they went
        await _databaseService.addData(
          collection: 'resourceAllocations',
          data: {
            'warehouseId': event.warehouseId,
            'resourceId': event.resourceId,
            'resourceName': resource.name,
            'quantity': event.quantity,
            'allocatedById': event.allocatedById,
            'allocatedByName': event.allocatedByName,
            'destinationId': event.destinationId,
            'destinationType': event.destinationType,
            'notes': event.notes,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } else {
        // Add to offline queue
        await _connectivityService.addToOfflineQueue({
          'type': 'update',
          'collection': 'warehouses',
          'documentId': event.warehouseId,
          'data': updateData,
        });
        
        // Add allocation to offline queue
        await _connectivityService.addToOfflineQueue({
          'type': 'create',
          'collection': 'resourceAllocations',
          'data': {
            'warehouseId': event.warehouseId,
            'resourceId': event.resourceId,
            'resourceName': resource.name,
            'quantity': event.quantity,
            'allocatedById': event.allocatedById,
            'allocatedByName': event.allocatedByName,
            'destinationId': event.destinationId,
            'destinationType': event.destinationType,
            'notes': event.notes,
            'timestamp': DateTime.now().toIso8601String(),
          },
        });
      }
      
      emit(const WarehouseOperationSuccess(message: 'Resource allocated successfully'));
    } catch (e) {
      emit(WarehouseError(message: 'Failed to allocate resource: ${e.toString()}'));
    }
  }

 Future<void> _onResourceTransfer(
  ResourceTransfer event,
  Emitter<WarehouseState> emit,
) async {
  try {
    emit(const WarehouseLoading());
    
    // Validate input parameters
    if (event.sourceWarehouseId.isEmpty || event.destinationWarehouseId.isEmpty || 
        event.resourceId.isEmpty || event.quantity <= 0) {
      emit(const WarehouseError(message: 'Invalid transfer parameters'));
      return;
    }
    
    // Check if source and destination are the same
    if (event.sourceWarehouseId == event.destinationWarehouseId) {
      emit(const WarehouseError(message: 'Source and destination warehouses cannot be the same'));
      return;
    }
    
    // First get the source warehouse
    final sourceWarehouseData = await _databaseService.getData(
      collection: 'warehouses',
      documentId: event.sourceWarehouseId,
    );
    
    if (sourceWarehouseData == null) {
      emit(const WarehouseError(message: 'Source warehouse not found'));
      return;
    }
    
    final sourceWarehouse = Warehouse.fromMap(sourceWarehouseData);
    
    // Find the resource in source warehouse
    final sourceResourceIndex = sourceWarehouse.resources.indexWhere(
      (r) => r.id == event.resourceId
    );
    
    if (sourceResourceIndex == -1) {
      emit(const WarehouseError(message: 'Resource not found in source warehouse'));
      return;
    }
    
    final sourceResource = sourceWarehouse.resources[sourceResourceIndex];
    
    // Check if there's enough quantity
    if (sourceResource.quantity < event.quantity) {
      emit(WarehouseError(
        message: 'Not enough resources available for transfer. Available: ${sourceResource.quantity}, Requested: ${event.quantity}'
      ));
      return;
    }
    
    // Get the destination warehouse
    final destWarehouseData = await _databaseService.getData(
      collection: 'warehouses',
      documentId: event.destinationWarehouseId,
    );
    
    if (destWarehouseData == null) {
      emit(const WarehouseError(message: 'Destination warehouse not found'));
      return;
    }
    
    final destWarehouse = Warehouse.fromMap(destWarehouseData);
    
    // Check if destination warehouse has enough capacity
    final int newDestUsedCapacity = destWarehouse.usedCapacity + event.quantity;
    
    if (newDestUsedCapacity > destWarehouse.capacity) {
      emit(WarehouseError(
        message: 'Destination warehouse does not have enough capacity. ' +
                'Available: ${destWarehouse.capacity - destWarehouse.usedCapacity}, Needed: ${event.quantity}'
      ));
      return;
    }
    
    // Check if the resource already exists in destination warehouse
    final destResourceIndex = destWarehouse.resources.indexWhere(
      (r) => r.name == sourceResource.name && r.category == sourceResource.category
    );
    
    List<Resource> updatedDestResources;
    
    if (destResourceIndex != -1) {
      // Resource exists, update quantity
      final destResource = destWarehouse.resources[destResourceIndex];
      final updatedDestResource = destResource.copyWith(
        quantity: destResource.quantity + event.quantity,
      );
      
      updatedDestResources = List.from(destWarehouse.resources);
      updatedDestResources[destResourceIndex] = updatedDestResource;
    } else {
      // Resource doesn't exist, create new one
      final newResource = Resource(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: sourceResource.name,
        category: sourceResource.category,
        quantity: event.quantity,
        unit: sourceResource.unit,
        minStockLevel: sourceResource.minStockLevel,
        expiryDate: sourceResource.expiryDate,
        status: 'available',
      );
      
      updatedDestResources = List.from(destWarehouse.resources)..add(newResource);
    }
    
    // Update source resource
    final int newSourceQuantity = sourceResource.quantity - event.quantity;
    final Resource updatedSourceResource = sourceResource.copyWith(
      quantity: newSourceQuantity,
      status: newSourceQuantity > 0 ? 'available' : 'allocated',
    );
    
    final List<Resource> updatedSourceResources = List.from(sourceWarehouse.resources);
    updatedSourceResources[sourceResourceIndex] = updatedSourceResource;
    
    // Calculate new used capacities
    final int newSourceUsedCapacity = sourceWarehouse.usedCapacity - event.quantity;
    
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    
    try {
      if (isConnected) {
        // Begin transaction - ideally this would be an atomic operation
        // Update source warehouse
        await _databaseService.updateData(
          collection: 'warehouses',
          documentId: event.sourceWarehouseId,
          data: {
            'resources': updatedSourceResources.map((r) => r.toMap()).toList(),
            'usedCapacity': newSourceUsedCapacity,
            'lastUpdated': DateTime.now().toIso8601String(),
          },
        );
        
        // Update destination warehouse
        await _databaseService.updateData(
          collection: 'warehouses',
          documentId: event.destinationWarehouseId,
          data: {
            'resources': updatedDestResources.map((r) => r.toMap()).toList(),
            'usedCapacity': newDestUsedCapacity,
            'lastUpdated': DateTime.now().toIso8601String(),
          },
        );
        
        // Log the transfer
        await _databaseService.addData(
          collection: 'resourceTransfers',
          data: {
            'sourceWarehouseId': event.sourceWarehouseId,
            'destinationWarehouseId': event.destinationWarehouseId,
            'resourceId': event.resourceId,
            'resourceName': sourceResource.name,
            'quantity': event.quantity,
            'transferById': event.transferById,
            'transferByName': event.transferByName,
            'notes': event.notes,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } else {
        // Add to offline queue in correct order for when connectivity returns
        
        // Source warehouse update
        await _connectivityService.addToOfflineQueue({
          'type': 'update',
          'collection': 'warehouses',
          'documentId': event.sourceWarehouseId,
          'data': {
            'resources': updatedSourceResources.map((r) => r.toMap()).toList(),
            'usedCapacity': newSourceUsedCapacity,
            'lastUpdated': DateTime.now().toIso8601String(),
          },
        });
        
        // Destination warehouse update
        await _connectivityService.addToOfflineQueue({
          'type': 'update',
          'collection': 'warehouses',
          'documentId': event.destinationWarehouseId,
          'data': {
            'resources': updatedDestResources.map((r) => r.toMap()).toList(),
            'usedCapacity': newDestUsedCapacity,
            'lastUpdated': DateTime.now().toIso8601String(),
          },
        });
        
        // Transfer log
        await _connectivityService.addToOfflineQueue({
          'type': 'create',
          'collection': 'resourceTransfers',
          'data': {
            'sourceWarehouseId': event.sourceWarehouseId,
            'destinationWarehouseId': event.destinationWarehouseId,
            'resourceId': event.resourceId,
            'resourceName': sourceResource.name,
            'quantity': event.quantity,
            'transferById': event.transferById,
            'transferByName': event.transferByName,
            'notes': event.notes,
            'timestamp': DateTime.now().toIso8601String(),
          },
        });
      }
      
      emit(const WarehouseOperationSuccess(
        message: 'Resource transferred successfully'
      ));
    } catch (transferError) {
      // Handle database update errors specifically
      emit(WarehouseError(
        message: 'Failed to complete transfer: ${transferError.toString()}. ' +
                'Please try again or contact support if the issue persists.'
      ));
    }
  } catch (e) {
    // Handle any unexpected errors
    emit(WarehouseError(
      message: 'Failed to transfer resource: ${e.toString()}'
    ));
  }
}

// Also improve the _onResourceAdd method:
Future<void> _onResourceAdd(
  ResourceAdd event,
  Emitter<WarehouseState> emit,
) async {
  try {
    emit(const WarehouseLoading());
    
    // Validate input parameters
    if (event.warehouseId.isEmpty || event.name.isEmpty || 
        event.category.isEmpty || event.quantity <= 0) {
      emit(const WarehouseError(message: 'Invalid resource parameters'));
      return;
    }
    
    // First get the current warehouse
    final warehouseData = await _databaseService.getData(
      collection: 'warehouses',
      documentId: event.warehouseId,
    );
    
    if (warehouseData == null) {
      emit(const WarehouseError(message: 'Warehouse not found'));
      return;
    }
    
    final warehouse = Warehouse.fromMap(warehouseData);
    
    // Check for duplicate resource names in the same category
    final hasDuplicate = warehouse.resources.any((r) => 
      r.name.toLowerCase() == event.name.toLowerCase() && 
      r.category.toLowerCase() == event.category.toLowerCase()
    );
    
    if (hasDuplicate) {
      emit(const WarehouseError(
        message: 'A resource with this name and category already exists'
      ));
      return;
    }
    
    // Calculate new used capacity
    final int newUsedCapacity = warehouse.usedCapacity + event.quantity;
    
    // Check if warehouse has enough capacity
    if (newUsedCapacity > warehouse.capacity) {
      emit(WarehouseError(
        message: 'Warehouse does not have enough capacity. ' +
                'Available: ${warehouse.capacity - warehouse.usedCapacity}, Needed: ${event.quantity}'
      ));
      return;
    }
    
    // Generate resource ID
    final String resourceId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Create resource object
    final Resource resource = Resource(
      id: resourceId,
      name: event.name,
      category: event.category,
      quantity: event.quantity,
      unit: event.unit,
      minStockLevel: event.minStockLevel,
      expiryDate: event.expiryDate,
      status: 'available',
    );
    
    // Add resource to warehouse resources
    final List<Resource> updatedResources = List.from(warehouse.resources)..add(resource);
    
    // Update warehouse
    final Map<String, dynamic> updateData = {
      'resources': updatedResources.map((r) => r.toMap()).toList(),
      'usedCapacity': newUsedCapacity,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    
    try {
      if (isConnected) {
        // Update warehouse in database
        await _databaseService.updateData(
          collection: 'warehouses',
          documentId: event.warehouseId,
          data: updateData,
        );
      } else {
        // Add to offline queue
        await _connectivityService.addToOfflineQueue({
          'type': 'update',
          'collection': 'warehouses',
          'documentId': event.warehouseId,
          'data': updateData,
        });
      }
      
      emit(const WarehouseOperationSuccess(message: 'Resource added successfully'));
    } catch (updateError) {
      emit(WarehouseError(
        message: 'Failed to save resource: ${updateError.toString()}'
      ));
    }
  } catch (e) {
    emit(WarehouseError(message: 'Failed to add resource: ${e.toString()}'));
  }
}

// Improve dispose to properly cancel subscriptions
@override
Future<void> close() {
  _warehousesSubscription?.cancel();
  return super.close();
}
}