// warehouse_management.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../models/warehouse.dart';
import '../../bloc/warehouse/warehouse_bloc.dart';
import '../../widgets/warehouse_card.dart';
import '../../services/location_service.dart';
import '../common/map_screen.dart';
import 'resource_allocation.dart';

class WarehouseManagementScreen extends StatefulWidget {
  final User currentUser;

  const WarehouseManagementScreen({super.key, required this.currentUser});

  @override
  State<WarehouseManagementScreen> createState() =>
      _WarehouseManagementScreenState();
}

class _WarehouseManagementScreenState extends State<WarehouseManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All';
  bool _isMapView = false;

  @override
  void initState() {
    super.initState();

    // Load warehouses when screen initializes
    _loadWarehouses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadWarehouses() {
    context.read<WarehouseBloc>().add(const WarehousesStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Management'),
        actions: [
          // Toggle view button
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
            tooltip: _isMapView ? 'List View' : 'Map View',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWarehouses,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Warehouses',
                hintText: 'Enter warehouse name or location',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                        : null,
              ),
              onChanged: (value) {
                // Trigger rebuild to update filter
                setState(() {});
              },
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', _filterStatus == 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('Active', _filterStatus == 'active'),
                const SizedBox(width: 8),
                _buildFilterChip('Inactive', _filterStatus == 'inactive'),
                const SizedBox(width: 8),
                _buildFilterChip('Maintenance', _filterStatus == 'maintenance'),
                const SizedBox(width: 8),
                _buildFilterChip('Low Stock', _filterStatus == 'lowStock'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Warehouse list or map
          Expanded(
            child: BlocConsumer<WarehouseBloc, WarehouseState>(
              listener: (context, state) {
                if (state is WarehouseError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is WarehouseOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Reload warehouses after successful operation
                  _loadWarehouses();
                }
              },
              builder: (context, state) {
                if (state is WarehouseLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is WarehousesLoaded) {
                  final warehouses = _filterWarehouses(state.warehouses);

                  if (warehouses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.store_mall_directory,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'No warehouses found for "${_searchController.text}"'
                                : _filterStatus != 'All'
                                ? 'No warehouses with status: $_filterStatus'
                                : 'No warehouses available',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showAddWarehouseDialog();
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Warehouse'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Map view
                  if (_isMapView) {
                    return _buildMapView(warehouses);
                  }

                  // List view
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80), // For FAB
                    itemCount: warehouses.length,
                    itemBuilder: (context, index) {
                      final warehouse = warehouses[index];

                      return WarehouseCard(
                        warehouse: warehouse,
                        onTap: () {
                          // Navigate to warehouse details
                          _navigateToResourceAllocation(warehouse);
                        },
                        onViewMap: () {
                          // Show warehouse on map
                          _showWarehouseOnMap(warehouse);
                        },
                        onManage: () {
                          // Show warehouse management options
                          _showWarehouseManagementOptions(warehouse);
                        },
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text('Failed to load warehouses'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadWarehouses,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddWarehouseDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Warehouse'),
      ),
    );
  }

  // Build filter chip
  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? label.toLowerCase() : 'All';
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  // Filter warehouses based on search text and status
  List<Warehouse> _filterWarehouses(List<Warehouse> warehouses) {
    final searchQuery = _searchController.text.toLowerCase();

    return warehouses.where((warehouse) {
      // Filter by search query
      if (searchQuery.isNotEmpty) {
        final matchesName = warehouse.name.toLowerCase().contains(searchQuery);
        final matchesAddress = warehouse.address.toLowerCase().contains(
          searchQuery,
        );
        final matchesManager = warehouse.managerName.toLowerCase().contains(
          searchQuery,
        );

        if (!matchesName && !matchesAddress && !matchesManager) {
          return false;
        }
      }

      // Filter by status
      if (_filterStatus == 'All') {
        return true;
      } else if (_filterStatus == 'lowStock') {
        return warehouse.hasLowStockResources;
      } else {
        return warehouse.status.toLowerCase() == _filterStatus.toLowerCase();
      }
    }).toList();
  }

  // Build map view
  Widget _buildMapView(List<Warehouse> warehouses) {
    // Prepare markers for map
    final markers = <String, Map<String, dynamic>>{};

    for (final warehouse in warehouses) {
      markers[warehouse.id] = {
        'latitude': warehouse.latitude,
        'longitude': warehouse.longitude,
        'title': warehouse.name,
        'snippet': '${warehouse.resources.length} resources',
        'type': 'warehouse',
      };
    }

    // Default to first warehouse location, or use a fallback
    double initialLatitude = 37.7749;
    double initialLongitude = -122.4194;

    if (warehouses.isNotEmpty) {
      initialLatitude = warehouses.first.latitude;
      initialLongitude = warehouses.first.longitude;
    }

    return MapScreen(
      initialLatitude: initialLatitude,
      initialLongitude: initialLongitude,
      initialZoom: 10.0,
      markers: markers,
      showUserLocation: true,
      onMapTap: (latLng) {
        // Show add warehouse dialog at tapped location
        _showAddWarehouseDialog(
          latitude: latLng.latitude,
          longitude: latLng.longitude,
        );
      },
    );
  }

  // Show filter dialog
  void _showFilterDialog() {
    // Create local variables
    String filterStatus = _filterStatus;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Warehouses'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Filter by Status',
                    border: OutlineInputBorder(),
                  ),
                  value: filterStatus,
                  items: const [
                    DropdownMenuItem<String>(value: 'All', child: Text('All')),
                    DropdownMenuItem<String>(
                      value: 'active',
                      child: Text('Active'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'maintenance',
                      child: Text('Maintenance'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'lowStock',
                      child: Text('Low Stock'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      filterStatus = value;
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _filterStatus = filterStatus;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
    );
  }

  // Navigate to resource allocation screen
  void _navigateToResourceAllocation(Warehouse warehouse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                ResourceAllocationScreen(currentUser: widget.currentUser),
      ),
    );
  }

  // Show warehouse on map
  void _showWarehouseOnMap(Warehouse warehouse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MapScreen(
              initialLatitude: warehouse.latitude,
              initialLongitude: warehouse.longitude,
              initialZoom: 15.0,
              markers: {
                warehouse.id: {
                  'latitude': warehouse.latitude,
                  'longitude': warehouse.longitude,
                  'title': warehouse.name,
                  'snippet': warehouse.address,
                  'type': 'warehouse',
                },
              },
              showUserLocation: true,
            ),
      ),
    );
  }

  // Show warehouse management options
  void _showWarehouseManagementOptions(Warehouse warehouse) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text('Manage Resources'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToResourceAllocation(warehouse);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Warehouse'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditWarehouseDialog(warehouse);
                },
              ),
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('View on Map'),
                onTap: () {
                  Navigator.pop(context);
                  _showWarehouseOnMap(warehouse);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Warehouse'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteWarehouseDialog(warehouse);
                },
              ),
            ],
          ),
    );
  }

  // Show add warehouse dialog
  void _showAddWarehouseDialog({double? latitude, double? longitude}) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController latitudeController = TextEditingController(
      text: latitude?.toString() ?? '',
    );
    final TextEditingController longitudeController = TextEditingController(
      text: longitude?.toString() ?? '',
    );
    final TextEditingController capacityController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Warehouse'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Warehouse Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: latitudeController,
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: longitudeController,
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.my_location, size: 16),
                      label: const Text('Get Current Location'),
                      onPressed: () async {
                        try {
                          final LocationService locationService =
                              context.read<LocationService>();
                          final position =
                              await locationService.getCurrentPosition();

                          latitudeController.text =
                              position.latitude.toString();
                          longitudeController.text =
                              position.longitude.toString();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to get location: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Validate input
                  if (nameController.text.isEmpty ||
                      addressController.text.isEmpty ||
                      latitudeController.text.isEmpty ||
                      longitudeController.text.isEmpty ||
                      capacityController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Parse coordinates and capacity
                  final double? lat = double.tryParse(latitudeController.text);
                  final double? lng = double.tryParse(longitudeController.text);
                  final int? capacity = int.tryParse(capacityController.text);

                  if (lat == null || lng == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid coordinates'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (capacity == null || capacity <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Capacity must be a positive number'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  // Create warehouse
                  context.read<WarehouseBloc>().add(
                    WarehouseCreate(
                      name: nameController.text,
                      address: addressController.text,
                      latitude: lat,
                      longitude: lng,
                      managerId: widget.currentUser.id,
                      managerName: widget.currentUser.name,
                      capacity: capacity,
                    ),
                  );
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  // Show edit warehouse dialog
  void _showEditWarehouseDialog(Warehouse warehouse) {
    final TextEditingController nameController = TextEditingController(
      text: warehouse.name,
    );
    final TextEditingController addressController = TextEditingController(
      text: warehouse.address,
    );
    final TextEditingController latitudeController = TextEditingController(
      text: warehouse.latitude.toString(),
    );
    final TextEditingController longitudeController = TextEditingController(
      text: warehouse.longitude.toString(),
    );
    String status = warehouse.status;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Edit Warehouse'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Warehouse Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: latitudeController,
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: longitudeController,
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.my_location, size: 16),
                          label: const Text('Get Current Location'),
                          onPressed: () async {
                            try {
                              final LocationService locationService =
                                  context.read<LocationService>();
                              final position =
                                  await locationService.getCurrentPosition();

                              latitudeController.text =
                                  position.latitude.toString();
                              longitudeController.text =
                                  position.longitude.toString();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to get location: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        value: status,
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'active',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'inactive',
                            child: Text('Inactive'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'maintenance',
                            child: Text('Maintenance'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              status = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Validate input
                      if (nameController.text.isEmpty ||
                          addressController.text.isEmpty ||
                          latitudeController.text.isEmpty ||
                          longitudeController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all required fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Parse coordinates
                      final double? lat = double.tryParse(
                        latitudeController.text,
                      );
                      final double? lng = double.tryParse(
                        longitudeController.text,
                      );

                      if (lat == null || lng == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid coordinates'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(context);

                      // Update warehouse
                      context.read<WarehouseBloc>().add(
                        WarehouseUpdate(
                          warehouseId: warehouse.id,
                          name: nameController.text,
                          address: addressController.text,
                          latitude: lat,
                          longitude: lng,
                          status: status,
                        ),
                      );
                    },
                    child: const Text('Update'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // Show delete warehouse dialog
  void _showDeleteWarehouseDialog(Warehouse warehouse) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Warehouse'),
            content: Text(
              'Are you sure you want to delete "${warehouse.name}"? '
              'This will also delete all resources in this warehouse. '
              'This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);

                  // For hackathon purposes, we'll just show a snackbar
                  // since we haven't implemented a delete warehouse event
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Delete warehouse functionality would be here',
                      ),
                    ),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
