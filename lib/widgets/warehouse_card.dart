// warehouse_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/warehouse.dart';

class WarehouseCard extends StatelessWidget {
  final Warehouse warehouse;
  final VoidCallback? onTap;
  final VoidCallback? onViewMap;
  final VoidCallback? onManage;

  const WarehouseCard({
    super.key,
    required this.warehouse,
    this.onTap,
    this.onViewMap,
    this.onManage,
  });

  // Get color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'maintenance':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  // Get capacity utilization percentage
  double _getCapacityUtilization() {
    return warehouse.capacity > 0
        ? (warehouse.usedCapacity / warehouse.capacity) * 100
        : 0;
  }

  // Format date
  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  // Get top 3 categories of resources
  List<Map<String, dynamic>> _getTopCategories() {
    final Map<String, int> categories = {};
    
    // Count resources by category
    for (final resource in warehouse.resources) {
      final category = resource.category;
      categories[category] = (categories[category] ?? 0) + resource.quantity;
    }
    
    // Convert to list and sort
    final List<Map<String, dynamic>> result = categories.entries
        .map((entry) => {
          'category': entry.key,
          'quantity': entry.value,
        })
        .toList();
    
    result.sort((a, b) => b['quantity'].compareTo(a['quantity']));
    
    // Return top 3 (or less if fewer categories)
    return result.take(3).toList();
  }

  // Get category icon
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.fastfood;
      case 'water':
        return Icons.water_drop;
      case 'medicine':
        return Icons.medical_services;
      case 'clothing':
        return Icons.checkroom;
      case 'equipment':
        return Icons.handyman;
      case 'shelter':
        return Icons.home;
      case 'tools':
        return Icons.build;
      case 'fuel':
        return Icons.local_gas_station;
      default:
        return Icons.inventory_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate capacity utilization
    final capacityUtilization = _getCapacityUtilization();
    
    // Get color for capacity bar
    Color capacityColor;
    if (capacityUtilization > 90) {
      capacityColor = Colors.red;
    } else if (capacityUtilization > 70) {
      capacityColor = Colors.orange;
    } else {
      capacityColor = Colors.green;
    }
    
    // Get top categories
    final topCategories = _getTopCategories();
    
    // Count low stock items
    final lowStockItems = warehouse.resources.where((r) => r.isLowStock).length;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warehouse header with status
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      warehouse.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(warehouse.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      warehouse.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Warehouse content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          warehouse.address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Manager
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Manager: ${warehouse.managerName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Capacity utilization
                  Row(
                    children: [
                      const Text(
                        'Capacity: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${warehouse.usedCapacity} / ${warehouse.capacity}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        '${capacityUtilization.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: capacityColor,
                          fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 16),
                  
                  // Top categories
                  if (topCategories.isNotEmpty) ...[
                    const Text(
                      'Top Categories',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (int i = 0; i < topCategories.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _buildCategoryChip(
                              topCategories[i]['category'],
                              topCategories[i]['quantity'],
                            ),
                          ),
                        ],
                        // Add empty placeholders if less than 3 categories
                        for (int i = 0; i < 3 - topCategories.length; i++) ...[
                          const SizedBox(width: 8),
                          const Expanded(child: SizedBox()),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Resources count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoBox(
                        icon: Icons.inventory_2,
                        value: warehouse.resources.length.toString(),
                        label: 'Resources',
                      ),
                      _buildInfoBox(
                        icon: Icons.warning_amber,
                        value: lowStockItems.toString(),
                        label: 'Low Stock',
                        color: lowStockItems > 0 ? Colors.orange : null,
                      ),
                      _buildInfoBox(
                        icon: Icons.calendar_today,
                        value: _formatDate(warehouse.lastUpdated ?? warehouse.createdAt),
                        label: 'Updated',
                        valueStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onViewMap != null)
                    TextButton.icon(
                      icon: const Icon(Icons.map),
                      label: const Text('View on Map'),
                      onPressed: onViewMap,
                    ),
                  if (onManage != null) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Manage'),
                      onPressed: onManage,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build category chip
  Widget _buildCategoryChip(String category, int quantity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 16,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  quantity.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Build info box
  Widget _buildInfoBox({
    required IconData icon,
    required String value,
    required String label,
    Color? color,
    TextStyle? valueStyle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? Colors.grey[700],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: valueStyle ?? TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color ?? Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}