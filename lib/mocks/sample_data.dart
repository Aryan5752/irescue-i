// lib/services/mock/sample_data.dart

import '../../models/user.dart';
import '../../models/warehouse.dart';
import '../../models/resource.dart';
import '../../models/alert.dart';
import '../../models/sos_request.dart';

/// Provides sample data for mock services
class SampleData {
  // Sample users
  static final Map<String, User> users = {
    'admin@example.com': createAdminUser(
      id: 'admin-1',
      email: 'admin@example.com'
    ),
    'john@example.com': createCivilianUser(
      id: 'civilian-1',
      name: 'John Doe',
      email: 'john@example.com'
    ),
    'jane@example.com': User(
      id: 'civilian-2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      role: 'civilian',
      phone: '555-789-1234',
      address: '789 Oak St, Anytown',
      latitude: 37.7635,
      longitude: -122.4216,
      isVerified: true,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      subscriptions: ['Earthquake', 'Flood'],
    ),
    'fieldworker@example.com': User(
      id: 'field-1',
      name: 'Sam Field',
      email: 'fieldworker@example.com',
      role: 'field_worker',
      phone: '555-456-7890',
      address: '456 Field St, Anytown',
      latitude: 37.7834,
      longitude: -122.4071,
      isVerified: true,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
  };
  
  // Create admin user (for demo login)
  static User createAdminUser({
    String id = 'admin-demo',
    String email = 'admin@test.com',
  }) {
    return User(
      id: id,
      name: 'Admin Demo',
      email: email,
      role: 'admin',
      phone: '555-123-4567',
      address: '123 Admin St, Anytown',
      latitude: 37.7749,
      longitude: -122.4194,
      isVerified: true,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    );
  }
  
  // Create civilian user (for demo login)
  static User createCivilianUser({
    String id = 'civilian-demo',
    String name = 'Civilian Demo',
    String email = 'user@test.com',
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      role: 'civilian',
      phone: '555-789-1234',
      address: '456 Main St, Anytown',
      latitude: 37.7854,
      longitude: -122.4005,
      isVerified: true,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      subscriptions: ['Earthquake', 'Flood', 'Fire'],
    );
  }
  
  // Sample warehouses with resources
  static final List<Map<String, dynamic>> warehouses = [
    _createWarehouse(
      id: 'warehouse-1',
      name: 'Central Warehouse',
      latitude: 37.7749,
      longitude: -122.4194,
      managerId: 'admin-1',
      managerName: 'Admin Demo',
    ),
    _createWarehouse(
      id: 'warehouse-2',
      name: 'East Bay Depot',
      latitude: 37.8044,
      longitude: -122.2712,
      managerId: 'admin-1',
      managerName: 'Admin Demo',
      status: 'active',
    ),
    _createWarehouse(
      id: 'warehouse-3',
      name: 'South Bay Facility',
      latitude: 37.3382,
      longitude: -121.8863,
      managerId: 'admin-1',
      managerName: 'Admin Demo',
      status: 'maintenance',
    ),
  ];
  
  // Sample alerts
  static final List<Map<String, dynamic>> alerts = [
    Alert(
      id: 'alert-1',
      title: 'Flooding in Downtown',
      description: 'Heavy rainfall has caused flooding in downtown areas. Avoid low-lying streets.',
      type: 'Flood',
      severity: 4,
      latitude: 37.7749,
      longitude: -122.4194,
      radius: 5.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      active: true,
      createdById: 'admin-1',
      createdByName: 'Admin Demo',
    ).toMap(),
    
    Alert(
      id: 'alert-2',
      title: 'Minor Earthquake Reported',
      description: 'A 3.5 magnitude earthquake was recorded. No damage reported.',
      type: 'Earthquake',
      severity: 2,
      latitude: 37.8044,
      longitude: -122.2712,
      radius: 10.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      active: true,
      createdById: 'admin-1',
      createdByName: 'Admin Demo',
    ).toMap(),
    
    Alert(
      id: 'alert-3',
      title: 'Wildfire Warning',
      description: 'Wildfire reported in northern hills. Stay clear of the area.',
      type: 'Fire',
      severity: 5,
      latitude: 37.7590,
      longitude: -122.5150,
      radius: 8.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      active: true,
      createdById: 'admin-1',
      createdByName: 'Admin Demo',
    ).toMap(),
    
    Alert(
      id: 'alert-4',
      title: 'Power Outage',
      description: 'Power outage affecting downtown area. Crews working to restore power.',
      type: 'Other',
      severity: 3,
      latitude: 37.7790,
      longitude: -122.4290,
      radius: 3.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      active: true,
      createdById: 'admin-1',
      createdByName: 'Admin Demo',
    ).toMap(),
    
    Alert(
      id: 'alert-5',
      title: 'Wind Advisory',
      description: 'Strong winds expected. Secure loose objects and be cautious while driving.',
      type: 'Other',
      severity: 2,
      latitude: 37.7983,
      longitude: -122.4360,
      radius: 15.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      active: false,
      createdById: 'admin-1',
      createdByName: 'Admin Demo',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
    ).toMap(),
  ];
  
  // Sample SOS requests
  static final List<Map<String, dynamic>> sosRequests = [
    SosRequest(
      id: 'sos-1',
      userId: 'civilian-1',
      userName: 'John Doe',
      type: 'Medical',
      description: 'Need medical assistance. Having chest pain.',
      latitude: 37.7854,
      longitude: -122.4005,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      status: 'pending',
      photoUrls: [],
    ).toMap(),
    
    SosRequest(
      id: 'sos-2',
      userId: 'civilian-2',
      userName: 'Jane Smith',
      type: 'Trapped',
      description: 'Trapped in building with rising water.',
      latitude: 37.7635,
      longitude: -122.4216,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      status: 'active',
      photoUrls: [],
      assignedToId: 'admin-1',
      assignedToName: 'Admin Demo',
      notes: 'First responders en route',
    ).toMap(),
    
    SosRequest(
      id: 'sos-3',
      userId: 'civilian-1',
      userName: 'John Doe',
      type: 'Fire',
      description: 'Fire in apartment building. Everyone evacuated.',
      latitude: 37.7849,
      longitude: -122.4294,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'resolved',
      photoUrls: [],
      assignedToId: 'field-1',
      assignedToName: 'Sam Field',
      notes: 'Fire department responded. Fire contained.',
    ).toMap(),
  ];
  
  // Create sample warehouse with resources
  static Map<String, dynamic> _createWarehouse({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required String managerId,
    required String managerName,
    String status = 'active',
  }) {
    final resources = <Resource>[
      Resource(
        id: '$id-resource-1',
        name: 'Rice',
        category: 'Food',
        quantity: 1000,
        unit: 'kg',
        minStockLevel: 200,
        expiryDate: DateTime.now().add(const Duration(days: 180)),
        status: 'available',
      ),
      
      Resource(
        id: '$id-resource-2',
        name: 'Bottled Water',
        category: 'Water',
        quantity: 5000,
        unit: 'liters',
        minStockLevel: 1000,
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        status: 'available',
      ),
      
      Resource(
        id: '$id-resource-3',
        name: 'First Aid Kits',
        category: 'Medicine',
        quantity: 150,
        unit: 'units',
        minStockLevel: 50,
        expiryDate: DateTime.now().add(const Duration(days: 730)),
        status: 'available',
      ),
      
      Resource(
        id: '$id-resource-4',
        name: 'Blankets',
        category: 'Clothing',
        quantity: 300,
        unit: 'units',
        minStockLevel: 100,
        expiryDate: DateTime.now().add(const Duration(days: 1095)),
        status: 'available',
      ),
      
      Resource(
        id: '$id-resource-5',
        name: 'Portable Generators',
        category: 'Equipment',
        quantity: 5,
        unit: 'units',
        minStockLevel: 10,
        expiryDate: DateTime.now().add(const Duration(days: 1825)),
        status: 'available',
      ),
      
      Resource(
        id: '$id-resource-6',
        name: 'Canned Food',
        category: 'Food',
        quantity: 2000,
        unit: 'units',
        minStockLevel: 500,
        expiryDate: DateTime.now().add(const Duration(days: 730)),
        status: 'available',
      ),
      
      Resource(
        id: '$id-resource-7',
        name: 'Tents',
        category: 'Shelter',
        quantity: 50,
        unit: 'units',
        minStockLevel: 20,
        expiryDate: DateTime.now().add(const Duration(days: 1460)),
        status: 'available',
      ),
    ];
    
    // Calculate used capacity (sum of all resource quantities)
    int usedCapacity = 0;
    for (final resource in resources) {
      usedCapacity += resource.quantity;
    }
    
    return Warehouse(
      id: id,
      name: name,
      address: '123 Warehouse Ave, City',
      latitude: latitude,
      longitude: longitude,
      managerId: managerId,
      managerName: managerName,
      resources: resources,
      capacity: 10000,
      usedCapacity: usedCapacity,
      status: status,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ).toMap();
  }
}