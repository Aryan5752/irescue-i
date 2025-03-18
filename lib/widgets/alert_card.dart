// alert_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alert.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback? onTap;
  final VoidCallback? onViewMap;

  const AlertCard({
    Key? key,
    required this.alert,
    this.onTap,
    this.onViewMap,
  }) : super(key: key);

  // Get icon based on alert type
  IconData _getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'earthquake':
        return Icons.foundation;
      case 'flood':
        return Icons.water;
      case 'fire':
        return Icons.local_fire_department;
      case 'hurricane':
        return Icons.cyclone;
      case 'tornado':
        return Icons.tornado;
      case 'tsunami':
        return Icons.waves;
      case 'landslide':
        return Icons.landscape;
      case 'chemical':
        return Icons.science;
      case 'security':
        return Icons.security;
      default:
        return Icons.warning_amber;
    }
  }

  // Get color based on severity
  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 5: // Critical
        return Colors.purple[900]!;
      case 4: // Severe
        return Colors.red;
      case 3: // Moderate
        return Colors.orange;
      case 2: // Minor
        return Colors.amber;
      case 1: // Low
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  // Get text color based on severity background
  Color _getTextColor(int severity) {
    // For darker backgrounds, use white text
    if (severity >= 3) {
      return Colors.white;
    }
    // For lighter backgrounds, use dark text
    return Colors.black87;
  }

  // Get severity label
  String _getSeverityLabel(int severity) {
    switch (severity) {
      case 5:
        return 'CRITICAL';
      case 4:
        return 'SEVERE';
      case 3:
        return 'MODERATE';
      case 2:
        return 'MINOR';
      case 1:
        return 'LOW';
      default:
        return 'UNKNOWN';
    }
  }

  // Format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hrs ago';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getSeverityColor(alert.severity),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Alert header with severity
            Container(
              color: _getSeverityColor(alert.severity),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getAlertIcon(alert.type),
                        color: _getTextColor(alert.severity),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        alert.type.toString().toUpperCase(),
                        style: TextStyle(
                          color: _getTextColor(alert.severity),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getSeverityLabel(alert.severity),
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
            
            // Alert content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    alert.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    alert.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Location and radius info
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
                          'Affected area: ${alert.radius.toStringAsFixed(1)} km radius',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Timestamp
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(alert.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            if (onViewMap != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.map),
                      label: const Text('View on Map'),
                      onPressed: onViewMap,
                    ),
                    if (!alert.active)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'CLEARED',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}