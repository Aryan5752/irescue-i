// emergency_resource.dart
import 'package:flutter/material.dart';

class EmergencyResource {
  final String id;
  final String title;
  final String description;
  final String type; // medical, fire, police, relief
  final double latitude;
  final double longitude;
  final String address;
  final String contactNumber;
  final bool isOperational;
  final List<String> services;
  final Map<String, dynamic>? additionalInfo;

  const EmergencyResource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.contactNumber,
    required this.isOperational,
    required this.services,
    this.additionalInfo,
  });

  // Helper method to get the appropriate icon for the resource type
  IconData get icon {
    switch (type) {
      case 'medical':
        return Icons.medical_services;
      case 'fire':
        return Icons.local_fire_department;
      case 'police':
        return Icons.local_police;
      case 'relief':
        return Icons.store;
      default:
        return Icons.help;
    }
  }

  // Helper method to get the appropriate color for the resource type
  Color get color {
    switch (type) {
      case 'medical':
        return Colors.red;
      case 'fire':
        return Colors.orange;
      case 'police':
        return Colors.blue;
      case 'relief':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}