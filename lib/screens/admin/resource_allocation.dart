// resource_allocation.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../models/warehouse.dart';
import '../../models/resource.dart';
import '../../bloc/warehouse/warehouse_bloc.dart';
import '../../widgets/status_badge.dart';

class ResourceAllocationScreen extends StatefulWidget {
  final User currentUser;

  const ResourceAllocationScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<ResourceAllocationScreen> createState() => _ResourceAllocationScreenState();
}

class _ResourceAllocationScreenState extends State<ResourceAllocationScreen> {
  String _selectedWarehouseId = '';
  String _resourceFilter = 'All';
  String _sortBy = 'name';
  bool _ascending = true;
  bool _showLowStockOnly = false;
  
  @override
  void initState() {
    super.initState();
    
    // Load warehouses when screen initializes
    _loadWarehouses();
  }
  
  void _loadWarehouses() {
    context.read<WarehouseBloc>().add(const WarehousesStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Allocation'),
        actions: [
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
      body: BlocBuilder<WarehouseBloc, WarehouseState>(
        builder: (context, state) {
          if (state is WarehouseLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is WarehousesLoaded) {
            final warehouses = state.warehouses;
            
            if (warehouses.isEmpty) {
              return const Center(
                child: Text('No warehouses available'),
              );
            }
            
            // If no warehouse is selected, select the first one
            if (_selectedWarehouseId.isEmpty && warehouses.isNotEmpty) {
              _selectedWarehouseId = warehouses[0].id;
            }
            
            return Column(
              children: [
                // Warehouse selector
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Warehouse',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.store),
                    ),
                    value: _selectedWarehouseId,
                    items: warehouses.map((warehouse) {
                      return DropdownMenuItem<String>(
                        value: warehouse.id,
                        child: Text(warehouse.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedWarehouseId = value;
                        });
                      }
                    },
                  ),
                ),
                
                // Selected warehouse info
                if (_selectedWarehouseId.isNotEmpty)
                  _buildWarehouseInfo(
                    warehouses.firstWhere((w) => w.id == _selectedWarehouseId),
                  ),
                
                // Resources list
                Expanded(
                  child: _selectedWarehouseId.isNotEmpty
                      ? _buildResourcesList(
                          warehouses.firstWhere((w) => w.id == _selectedWarehouseId),
                        )
                      : const Center(
                          child: Text('Select a warehouse to view resources'),
                        ),
                ),
              ],
            );
          } else if (state is WarehouseError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadWarehouses,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('Failed to load warehouses'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showResourceActionsMenu();
        },
        icon: const Icon(Icons.add),
        label: const Text('Resource Actions'),
      ),
    );
  }
  
  // Build warehouse info card
  Widget _buildWarehouseInfo(Warehouse warehouse) {
    // Calculate capacity utilization percentage
    final capacityUtilization = warehouse.capacity > 0
        ? (warehouse.usedCapacity / warehouse.capacity) * 100
        : 0.0;
    
    // Get color for capacity bar
    Color capacityColor;
    if (capacityUtilization > 90) {
      capacityColor = Colors.red;
    } else if (capacityUtilization > 70) {
      capacityColor = Colors.orange;
    } else {
      capacityColor = Colors.green;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.store, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    warehouse.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusBadge(
                  status: warehouse.status,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              warehouse.address,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            
            // Capacity
            Row(
              children: [
                const Text(
                  'Capacity: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${warehouse.usedCapacity} / ${warehouse.capacity}',
                ),
                const Spacer(),
                Text(
                  '${capacityUtilization.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: capacityColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            
            // Capacity progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: warehouse.capacity > 0
                    ? warehouse.usedCapacity / warehouse.capacity
                    : 0,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(capacityColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build resources list
  Widget _buildResourcesList(Warehouse warehouse) {
    // Get filtered and sorted resources
    List<Resource> resources = _getFilteredResources(warehouse.resources);
    
    if (resources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _showLowStockOnly
                  ? 'No low stock resources found'
                  : _resourceFilter != 'All'
                      ? 'No resources found for category: $_resourceFilter'
                      : 'No resources available in this warehouse',
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Add new resource
                _showAddResourceDialog(warehouse.id);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Resource'),
            ),
          ],
        ),
      );
    }
    
    // Sort resources
    resources = _getSortedResources(resources);
    
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Bottom padding for FAB
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return _buildResourceCard(resource, warehouse.id);
      },
    );
  }
  
  // Get filtered resources
  List<Resource> _getFilteredResources(List<Resource> resources) {
    return resources.where((resource) {
      // Filter by category
      if (_resourceFilter != 'All' && resource.category != _resourceFilter) {
        return false;
      }
      
      // Filter by low stock
      if (_showLowStockOnly && !resource.isLowStock) {
        return false;
      }
      
      return true;
    }).toList();
  }
  
  // Get sorted resources
  List<Resource> _getSortedResources(List<Resource> resources) {
    switch (_sortBy) {
      case 'name':
        resources.sort((a, b) => _ascending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case 'category':
        resources.sort((a, b) => _ascending
            ? a.category.compareTo(b.category)
            : b.category.compareTo(a.category));
        break;
      case 'quantity':
        resources.sort((a, b) => _ascending
            ? a.quantity.compareTo(b.quantity)
            : b.quantity.compareTo(a.quantity));
        break;
      case 'expiry':
        resources.sort((a, b) => _ascending
            ? a.expiryDate.compareTo(b.expiryDate)
            : b.expiryDate.compareTo(a.expiryDate));
        break;
      default:
        resources.sort((a, b) => a.name.compareTo(b.name));
    }
    
    return resources;
  }
  
  // Build resource card
  Widget _buildResourceCard(Resource resource, String warehouseId) {
    // Check if stock is low
    final isLowStock = resource.isLowStock;
    
    // Check if expired
    final isExpired = resource.isExpired;
    
    // Get appropriate status color
    Color statusColor;
    if (isExpired) {
      statusColor = Colors.red;
    } else if (isLowStock) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: statusColor,
          width: isLowStock || isExpired ? 1 : 0,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Show resource details
          _showResourceDetailsDialog(resource, warehouseId);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Category: ${resource.category}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge.stock(
                    resource.quantity,
                    resource.minStockLevel,
                    fontSize: 10,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Quantity
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${resource.quantity} ${resource.unit}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  // Min Stock Level
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Min Stock',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${resource.minStockLevel} ${resource.unit}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  // Expiry
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expires',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${resource.expiryDate.day}/${resource.expiryDate.month}/${resource.expiryDate.year}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isExpired ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Allocate button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Allocate'),
                    onPressed: () {
                      // Show allocate dialog
                      _showAllocateResourceDialog(resource, warehouseId);
                    },
                  ),
                  const SizedBox(width: 8),
                  
                  // Edit button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () {
                      // Show edit dialog
                      _showEditResourceDialog(resource, warehouseId);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // Get all resource categories
        final List<String> categories = ['All'];
        
        // Get current warehouse
        final state = context.read<WarehouseBloc>().state;
        if (state is WarehousesLoaded) {
          final warehouses = state.warehouses;
          if (warehouses.isNotEmpty && _selectedWarehouseId.isNotEmpty) {
            final warehouse = warehouses.firstWhere(
              (w) => w.id == _selectedWarehouseId,
              orElse: () => warehouses[0],
            );
            
            // Extract unique categories
            for (final resource in warehouse.resources) {
              if (!categories.contains(resource.category)) {
                categories.add(resource.category);
              }
            }
          }
        }
        
        // Create local variables for the dialog
        String resourceFilter = _resourceFilter;
        String sortBy = _sortBy;
        bool ascending = _ascending;
        bool showLowStockOnly = _showLowStockOnly;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Resources'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category filter
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Filter by Category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    value: resourceFilter,
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          resourceFilter = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Sort options
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Sort By',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          value: sortBy,
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'name',
                              child: Text('Name'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'category',
                              child: Text('Category'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'quantity',
                              child: Text('Quantity'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'expiry',
                              child: Text('Expiry Date'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                sortBy = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          ascending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                        ),
                        onPressed: () {
                          setState(() {
                            ascending = !ascending;
                          });
                        },
                        tooltip: ascending ? 'Ascending' : 'Descending',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Show low stock only
                  CheckboxListTile(
                    title: const Text('Show Low Stock Only'),
                    value: showLowStockOnly,
                    onChanged: (value) {
                      setState(() {
                        showLowStockOnly = value ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
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
                      _resourceFilter = resourceFilter;
                      _sortBy = sortBy;
                      _ascending = ascending;
                      _showLowStockOnly = showLowStockOnly;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // Show resource actions menu
  void _showResourceActionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add Resource'),
            onTap: () {
              Navigator.pop(context);
              _showAddResourceDialog(_selectedWarehouseId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Transfer Resources'),
            onTap: () {
              Navigator.pop(context);
              _showTransferResourceDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Print Inventory Report'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Print functionality would be here'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  // Show resource details dialog
  void _showResourceDetailsDialog(Resource resource, String warehouseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(resource.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${resource.category}'),
            Text('Quantity: ${resource.quantity} ${resource.unit}'),
            Text('Min Stock Level: ${resource.minStockLevel} ${resource.unit}'),
            Text('Status: ${resource.status}'),
            Text('Expiry Date: ${resource.expiryDate.day}/${resource.expiryDate.month}/${resource.expiryDate.year}'),
            if (resource.isLowStock)
              const Text(
                'This resource is low on stock!',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (resource.isExpired)
              const Text(
                'This resource has expired!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditResourceDialog(resource, warehouseId);
            },
            child: const Text('Edit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAllocateResourceDialog(resource, warehouseId);
            },
            child: const Text('Allocate'),
          ),
        ],
      ),
    );
  }
  
  // Show add resource dialog
  void _showAddResourceDialog(String warehouseId) {
    // For hackathon purposes, we'll show a simplified dialog
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController minStockController = TextEditingController();
    String category = 'Food';
    String unit = 'kg';
    DateTime expiryDate = DateTime.now().add(const Duration(days: 365));
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Resource'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    value: category,
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'Food',
                        child: Text('Food'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Water',
                        child: Text('Water'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Medicine',
                        child: Text('Medicine'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Clothing',
                        child: Text('Clothing'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Equipment',
                        child: Text('Equipment'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Tools',
                        child: Text('Tools'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Fuel',
                        child: Text('Fuel'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Other',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          category = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Quantity and Unit
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                          ),
                          value: unit,
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'kg',
                              child: Text('kg'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'liters',
                              child: Text('liters'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'units',
                              child: Text('units'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'boxes',
                              child: Text('boxes'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'packs',
                              child: Text('packs'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                unit = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Min Stock Level
                  TextField(
                    controller: minStockController,
                    decoration: const InputDecoration(
                      labelText: 'Min Stock Level',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  
                  // Expiry Date
                  Row(
                    children: [
                      const Text('Expiry Date: '),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          '${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
                        ),
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: expiryDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 5),
                            ),
                          );
                          
                          if (selectedDate != null) {
                            setState(() {
                              expiryDate = selectedDate;
                            });
                          }
                        },
                      ),
                    ],
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
                      quantityController.text.isEmpty ||
                      minStockController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  // Parse quantity and min stock
                  final quantity = int.tryParse(quantityController.text);
                  final minStock = int.tryParse(minStockController.text);
                  
                  if (quantity == null || minStock == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quantity and min stock must be numbers'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  Navigator.pop(context);
                  
                  // Add resource
                  context.read<WarehouseBloc>().add(
                    ResourceAdd(
                      warehouseId: warehouseId,
                      name: nameController.text,
                      category: category,
                      quantity: quantity,
                      unit: unit,
                      minStockLevel: minStock,
                      expiryDate: expiryDate,
                    ),
                  );
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  // Show edit resource dialog
  void _showEditResourceDialog(Resource resource, String warehouseId) {
    // For hackathon purposes, we'll show a simplified dialog
    final TextEditingController nameController = TextEditingController(text: resource.name);
    final TextEditingController quantityController = TextEditingController(text: resource.quantity.toString());
    final TextEditingController minStockController = TextEditingController(text: resource.minStockLevel.toString());
    String category = resource.category;
    String unit = resource.unit;
    DateTime expiryDate = resource.expiryDate;
    String status = resource.status;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Resource'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    value: category,
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'Food',
                        child: Text('Food'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Water',
                        child: Text('Water'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Medicine',
                        child: Text('Medicine'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Clothing',
                        child: Text('Clothing'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Equipment',
                        child: Text('Equipment'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Tools',
                        child: Text('Tools'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Fuel',
                        child: Text('Fuel'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Other',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          category = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Quantity and Unit
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                          ),
                          value: unit,
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'kg',
                              child: Text('kg'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'liters',
                              child: Text('liters'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'units',
                              child: Text('units'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'boxes',
                              child: Text('boxes'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'packs',
                              child: Text('packs'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                unit = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Min Stock Level
                  TextField(
                    controller: minStockController,
                    decoration: const InputDecoration(
                      labelText: 'Min Stock Level',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  
                  // Status
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    value: status,
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'available',
                        child: Text('Available'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'allocated',
                        child: Text('Allocated'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'expired',
                        child: Text('Expired'),
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
                  const SizedBox(height: 16),
                  
                  // Expiry Date
                  Row(
                    children: [
                      const Text('Expiry Date: '),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          '${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
                        ),
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: expiryDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 5),
                            ),
                          );
                          
                          if (selectedDate != null) {
                            setState(() {
                              expiryDate = selectedDate;
                            });
                          }
                        },
                      ),
                    ],
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
                      quantityController.text.isEmpty ||
                      minStockController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  // Parse quantity and min stock
                  final quantity = int.tryParse(quantityController.text);
                  final minStock = int.tryParse(minStockController.text);
                  
                  if (quantity == null || minStock == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quantity and min stock must be numbers'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  Navigator.pop(context);
                  
                  // Update resource
                  context.read<WarehouseBloc>().add(
                    ResourceUpdate(
                      warehouseId: warehouseId,
                      resourceId: resource.id,
                      name: nameController.text,
                      category: category,
                      quantity: quantity,
                      unit: unit,
                      minStockLevel: minStock,
                      expiryDate: expiryDate,
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
  
  // Show allocate resource dialog
  void _showAllocateResourceDialog(Resource resource, String warehouseId) {
    // For hackathon purposes, we'll show a simplified dialog
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController destinationController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    String destinationType = 'SOS';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Allocate Resource'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resource info
                  Text(
                    'Resource: ${resource.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Available: ${resource.quantity} ${resource.unit}'),
                  const SizedBox(height: 16),
                  
                  // Quantity to allocate
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity to Allocate (${resource.unit})',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  
                  // Destination type
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Allocation Type',
                      border: OutlineInputBorder(),
                    ),
                    value: destinationType,
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'SOS',
                        child: Text('SOS Request'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Community',
                        child: Text('Community Distribution'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Emergency',
                        child: Text('Emergency Response'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          destinationType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Destination ID
                  TextField(
                    controller: destinationController,
                    decoration: const InputDecoration(
                      labelText: 'Destination ID / Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
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
                  if (quantityController.text.isEmpty ||
                      destinationController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  // Parse quantity
                  final quantity = int.tryParse(quantityController.text);
                  
                  if (quantity == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quantity must be a number'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  // Check if quantity is available
                  if (quantity > resource.quantity) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Not enough quantity available'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  Navigator.pop(context);
                  
                  // Allocate resource
                  context.read<WarehouseBloc>().add(
                    ResourceAllocate(
                      warehouseId: warehouseId,
                      resourceId: resource.id,
                      quantity: quantity,
                      allocatedById: widget.currentUser.id,
                      allocatedByName: widget.currentUser.name,
                      destinationId: destinationController.text,
                      destinationType: destinationType,
                      notes: notesController.text,
                    ),
                  );
                },
                child: const Text('Allocate'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  // Show transfer resource dialog
  void _showTransferResourceDialog() {
    // For hackathon purposes, we'll show a simplified dialog
    String sourceWarehouseId = _selectedWarehouseId;
    String destinationWarehouseId = '';
    String resourceId = '';
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    
    // Get warehouses and resources
    final state = context.read<WarehouseBloc>().state;
    List<Warehouse> warehouses = [];
    List<Resource> resources = [];
    
    if (state is WarehousesLoaded) {
      warehouses = state.warehouses;
      
      // Set default values
      if (warehouses.isNotEmpty) {
        // Source warehouse
        if (sourceWarehouseId.isEmpty) {
          sourceWarehouseId = warehouses[0].id;
        }
        
        // Find source warehouse
        final sourceWarehouse = warehouses.firstWhere(
          (w) => w.id == sourceWarehouseId,
          orElse: () => warehouses[0],
        );
        
        // Get resources from source warehouse
        resources = sourceWarehouse.resources;
        
        // Set default resource if available
        if (resources.isNotEmpty) {
          resourceId = resources[0].id;
        }
        
        // Set default destination warehouse (first one that isn't the source)
        final destinationWarehouses = warehouses
            .where((w) => w.id != sourceWarehouseId)
            .toList();
        
        if (destinationWarehouses.isNotEmpty) {
          destinationWarehouseId = destinationWarehouses[0].id;
        }
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Update resources when source warehouse changes
          void updateResources() {
            if (state is WarehousesLoaded) {
              final sourceWarehouse = warehouses.firstWhere(
                (w) => w.id == sourceWarehouseId,
                orElse: () => warehouses[0],
              );
              
              setState(() {
                resources = sourceWarehouse.resources;
                if (resources.isNotEmpty) {
                  resourceId = resources[0].id;
                } else {
                  resourceId = '';
                }
              });
            }
          }
          
          return AlertDialog(
            title: const Text('Transfer Resource'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source warehouse
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'From Warehouse',
                      border: OutlineInputBorder(),
                    ),
                    value: sourceWarehouseId,
                    items: warehouses.map((warehouse) {
                      return DropdownMenuItem<String>(
                        value: warehouse.id,
                        child: Text(warehouse.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          sourceWarehouseId = value;
                          // Update destination warehouse list
                          final destinationWarehouses = warehouses
                              .where((w) => w.id != value)
                              .toList();
                          
                          if (destinationWarehouses.isNotEmpty) {
                            destinationWarehouseId = destinationWarehouses[0].id;
                          } else {
                            destinationWarehouseId = '';
                          }
                        });
                        
                        // Update resources
                        updateResources();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Resource
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Resource',
                      border: OutlineInputBorder(),
                    ),
                    value: resourceId.isNotEmpty && resources.any((r) => r.id == resourceId)
                        ? resourceId
                        : null,
                    items: resources.map((resource) {
                      return DropdownMenuItem<String>(
                        value: resource.id,
                        child: Text('${resource.name} (${resource.quantity} ${resource.unit})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          resourceId = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Destination warehouse
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'To Warehouse',
                      border: OutlineInputBorder(),
                    ),
                    value: destinationWarehouseId.isNotEmpty && 
                           warehouses.any((w) => w.id == destinationWarehouseId)
                        ? destinationWarehouseId
                        : null,
                    items: warehouses
                        .where((w) => w.id != sourceWarehouseId)
                        .map((warehouse) {
                          return DropdownMenuItem<String>(
                            value: warehouse.id,
                            child: Text(warehouse.name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          destinationWarehouseId = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Quantity
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity to Transfer',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
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
                  if (sourceWarehouseId.isEmpty ||
                      destinationWarehouseId.isEmpty ||
                      resourceId.isEmpty ||
                      quantityController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  // Parse quantity
                  final quantity = int.tryParse(quantityController.text);
                  
                  if (quantity == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quantity must be a number'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  // Check if quantity is available
                  if (resources.isNotEmpty) {
                    final resource = resources.firstWhere(
                      (r) => r.id == resourceId,
                      orElse: () => resources[0],
                    );
                    
                    if (quantity > resource.quantity) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Not enough quantity available'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                  }
                  
                  Navigator.pop(context);
                  
                  // Transfer resource
                  context.read<WarehouseBloc>().add(
                    ResourceTransfer(
                      sourceWarehouseId: sourceWarehouseId,
                      destinationWarehouseId: destinationWarehouseId,
                      resourceId: resourceId,
                      quantity: quantity,
                      transferById: widget.currentUser.id,
                      transferByName: widget.currentUser.name,
                      notes: notesController.text,
                    ),
                  );
                },
                child: const Text('Transfer'),
              ),
            ],
          );
        },
      ),
    );
  }
}