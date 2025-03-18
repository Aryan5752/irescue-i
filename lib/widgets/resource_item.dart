// resource_item.dart
import 'package:flutter/material.dart';
import '../models/resource.dart';
import 'status_badge.dart';

class ResourceItem extends StatelessWidget {
  final Resource resource;
  final String warehouseId;
  final VoidCallback? onTap;
  final VoidCallback? onAllocate;
  final VoidCallback? onEdit;

  const ResourceItem({
    super.key,
    required this.resource,
    required this.warehouseId,
    this.onTap,
    this.onAllocate,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
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
        onTap: onTap,
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
                  if (onAllocate != null)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Allocate'),
                      onPressed: onAllocate,
                    ),
                  const SizedBox(width: 8),
                  
                  // Edit button
                  if (onEdit != null)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: onEdit,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}