// mock_emergency_resource_service.dart
import '../models/emergency_resource.dart';

class MockEmergencyResourceService {
  // Get all emergency resources
  List<EmergencyResource> getAllResources() {
    return [
      // Medical Centers
      EmergencyResource(
        id: 'med-001',
        title: 'Central Hospital',
        description: 'Major trauma center with 24/7 emergency services',
        type: 'medical',
        latitude: 37.7850,
        longitude: -122.4330,
        address: '123 Medical Way, San Francisco',
        contactNumber: '(415) 555-0123',
        isOperational: true,
        services: ['Emergency Room', 'Trauma Center', 'ICU', 'Surgery'],
        additionalInfo: {
          'bedsAvailable': 42,
          'waitTime': '15 minutes',
          'specialties': ['Burns', 'Cardiac']
        },
      ),
      EmergencyResource(
        id: 'med-002',
        title: 'Community Health Center',
        description: 'Community clinic with basic emergency services',
        type: 'medical',
        latitude: 37.7741,
        longitude: -122.4214,
        address: '456 Health St, San Francisco',
        contactNumber: '(415) 555-0124',
        isOperational: true,
        services: ['Basic Emergency Care', 'Primary Care', 'Pharmacy'],
        additionalInfo: {
          'bedsAvailable': 15,
          'waitTime': '30 minutes',
        },
      ),
      
      // Fire Stations
      EmergencyResource(
        id: 'fire-001',
        title: 'Station 1 - Downtown',
        description: 'Main fire station with advanced equipment',
        type: 'fire',
        latitude: 37.7833,
        longitude: -122.4167,
        address: '789 Fire Blvd, San Francisco',
        contactNumber: '(415) 555-0125',
        isOperational: true,
        services: ['Fire Response', 'Rescue', 'Hazmat'],
        additionalInfo: {
          'unitsAvailable': 5,
          'responseTime': '4 minutes',
        },
      ),
      EmergencyResource(
        id: 'fire-002',
        title: 'Station 2 - Coastal',
        description: 'Secondary station with marine rescue capabilities',
        type: 'fire',
        latitude: 37.8083,
        longitude: -122.4156,
        address: '321 Coast Rd, San Francisco',
        contactNumber: '(415) 555-0126',
        isOperational: true,
        services: ['Fire Response', 'Marine Rescue', 'Medical First Response'],
        additionalInfo: {
          'unitsAvailable': 3,
          'responseTime': '5 minutes',
        },
      ),
      
      // Police Stations
      EmergencyResource(
        id: 'police-001',
        title: 'Central Police HQ',
        description: 'Main police headquarters with full capabilities',
        type: 'police',
        latitude: 37.7695,
        longitude: -122.4194,
        address: '555 Law Enforcement Ave, San Francisco',
        contactNumber: '(415) 555-0127',
        isOperational: true,
        services: ['Emergency Response', 'Investigations', 'Patrol'],
        additionalInfo: {
          'unitsAvailable': 12,
          'responseTime': '3 minutes',
        },
      ),
      EmergencyResource(
        id: 'police-002',
        title: 'Neighborhood Precinct',
        description: 'Local precinct serving residential areas',
        type: 'police',
        latitude: 37.7821,
        longitude: -122.4090,
        address: '222 Security St, San Francisco',
        contactNumber: '(415) 555-0128',
        isOperational: true,
        services: ['Community Policing', 'Patrol', 'Emergency Response'],
        additionalInfo: {
          'unitsAvailable': 5,
          'responseTime': '6 minutes',
        },
      ),
      
      // Relief Centers
      EmergencyResource(
        id: 'relief-001',
        title: 'Main Shelter',
        description: 'Primary disaster relief shelter with full services',
        type: 'relief',
        latitude: 37.7749,
        longitude: -122.4194,
        address: '888 Safety Drive, San Francisco',
        contactNumber: '(415) 555-0129',
        isOperational: true,
        services: ['Shelter', 'Food', 'Medical Aid', 'Family Reunification'],
        additionalInfo: {
          'capacity': 500,
          'currentOccupancy': 135,
          'supplies': ['Water', 'Food', 'Blankets', 'First Aid']
        },
      ),
      EmergencyResource(
        id: 'relief-002',
        title: 'Secondary Relief Center',
        description: 'Additional relief center for overflow support',
        type: 'relief',
        latitude: 37.7899,
        longitude: -122.4004,
        address: '777 Support Lane, San Francisco',
        contactNumber: '(415) 555-0130',
        isOperational: true,
        services: ['Shelter', 'Food', 'Distribution'],
        additionalInfo: {
          'capacity': 300,
          'currentOccupancy': 87,
          'supplies': ['Water', 'Food', 'Blankets']
        },
      ),
    ];
  }

  // Get resources by type
  List<EmergencyResource> getResourcesByType(String type) {
    return getAllResources().where((resource) => resource.type == type).toList();
  }
}