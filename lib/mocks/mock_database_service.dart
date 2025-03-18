// lib/services/mock/mock_database_service.dart

import 'dart:async';
import 'dart:math';
import 'package:irescue/services/database_service.dart';
import 'sample_data.dart';

class MockDatabaseService implements DatabaseService {
  // In-memory storage for collections
  final Map<String, Map<String, Map<String, dynamic>>> _database = {};
  
  // Stream controllers for real-time updates
  final Map<String, StreamController<List<Map<String, dynamic>>>> _collectionStreamControllers = {};
  final Map<String, Map<String, StreamController<Map<String, dynamic>?>>> _documentStreamControllers = {};
  
  MockDatabaseService();
  
  /// Initialize the mock database with sample data
  Future<void> initialize() async {
    await reset();
  }
  
  /// Reset the database to initial state with sample data
  Future<void> reset() async {
    // Clear existing data
    _database.clear();
    
    // Initialize collections
    _database['users'] = {};
    _database['warehouses'] = {};
    _database['alerts'] = {};
    _database['sosRequests'] = {};
    _database['resourceAllocations'] = {};
    _database['resourceTransfers'] = {};
    
    // Add sample data
    _populateSampleData();
    
    // Emit updates to any active streams
    for (final collection in _database.keys) {
      _emitCollectionUpdate(collection);
    }
  }
  
  /// Populate the database with sample data
  void _populateSampleData() {
    // Add users
    for (final user in SampleData.users.values) {
      _database['users']![user.id] = user.toMap();
    }
    
    // Add warehouses
    for (final warehouse in SampleData.warehouses) {
      _database['warehouses']![warehouse['id'] as String] = warehouse;
    }
    
    // Add alerts
    for (final alert in SampleData.alerts) {
      _database['alerts']![alert['id'] as String] = alert;
    }
    
    // Add SOS requests
    for (final sos in SampleData.sosRequests) {
      _database['sosRequests']![sos['id'] as String] = sos;
    }
  }
  
  // Get or create a collection stream controller
  StreamController<List<Map<String, dynamic>>> _getCollectionStreamController(String collection) {
    if (!_collectionStreamControllers.containsKey(collection)) {
      _collectionStreamControllers[collection] = StreamController<List<Map<String, dynamic>>>.broadcast();
    }
    return _collectionStreamControllers[collection]!;
  }
  
  // Get or create a document stream controller
  StreamController<Map<String, dynamic>?> _getDocumentStreamController(String collection, String documentId) {
    _documentStreamControllers[collection] ??= {};
    if (!_documentStreamControllers[collection]!.containsKey(documentId)) {
      _documentStreamControllers[collection]![documentId] = StreamController<Map<String, dynamic>?>.broadcast();
    }
    return _documentStreamControllers[collection]![documentId]!;
  }
  
  // Emit collection update to all listeners
  void _emitCollectionUpdate(String collection) {
    if (_collectionStreamControllers.containsKey(collection) && 
        !_collectionStreamControllers[collection]!.isClosed) {
      final documents = _database[collection]?.values.toList() ?? [];
      _collectionStreamControllers[collection]!.add(documents);
    }
  }
  
  // Emit document update to listeners
  void _emitDocumentUpdate(String collection, String documentId) {
    if (_documentStreamControllers[collection]?.containsKey(documentId) == true && 
        !_documentStreamControllers[collection]![documentId]!.isClosed) {
      final document = _database[collection]?[documentId];
      _documentStreamControllers[collection]![documentId]!.add(document);
    }
  }
  
  @override
  Stream<List<Map<String, dynamic>>> streamCollection({required String collection}) {
    final controller = _getCollectionStreamController(collection);
    
    // Emit initial data
    Future.microtask(() {
      final documents = _database[collection]?.values.toList() ?? [];
      controller.add(documents);
    });
    
    return controller.stream;
  }
  
  @override
  Stream<List<Map<String, dynamic>>> streamCollectionWhere({
    required String collection,
    required String field,
    required dynamic isEqualTo,
  }) {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    
    // Emit initial filtered data
    Future.microtask(() {
      final documents = _database[collection]?.values
          .where((doc) => doc[field] == isEqualTo)
          .toList() ?? [];
      controller.add(documents);
    });
    
    // Subscribe to the main collection stream and filter
    streamCollection(collection: collection).listen((documents) {
      final filteredDocs = documents
          .where((doc) => doc[field] == isEqualTo)
          .toList();
      controller.add(filteredDocs);
    });
    
    return controller.stream;
  }
  
  @override
  Stream<Map<String, dynamic>?> streamDocument({
    required String collection,
    required String documentId,
  }) {
    final controller = _getDocumentStreamController(collection, documentId);
    
    // Emit initial data
    Future.microtask(() {
      final document = _database[collection]?[documentId];
      controller.add(document);
    });
    
    return controller.stream;
  }
  
  @override
  Future<List<Map<String, dynamic>>> getCollection({
    required String collection,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _database[collection]?.values.toList() ?? [];
  }
  
  @override
  Future<List<Map<String, dynamic>>> getCollectionWhere({
    required String collection,
    required String field,
    required dynamic isEqualTo,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _database[collection]?.values
        .where((doc) => doc[field] == isEqualTo)
        .toList() ?? [];
  }
  
  @override
  Future<Map<String, dynamic>?> getData({
    required String collection,
    required String documentId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    return _database[collection]?[documentId];
  }
  
  @override
  Future<void> setData({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Initialize collection if it doesn't exist
    _database[collection] ??= {};
    
    final String docId = documentId ?? _generateId();
    
    // Ensure data has an id
    if (!data.containsKey('id')) {
      data['id'] = docId;
    }
    
    // Set data
    _database[collection]![docId] = Map<String, dynamic>.from(data);
    
    // Emit updates
    _emitCollectionUpdate(collection);
    _emitDocumentUpdate(collection, docId);
  }
  
  @override
  Future<String> addData({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Initialize collection if it doesn't exist
    _database[collection] ??= {};
    
    final String docId = _generateId();
    
    // Ensure data has an id
    if (!data.containsKey('id')) {
      data['id'] = docId;
    }
    
    // Add data
    _database[collection]![docId] = Map<String, dynamic>.from(data);
    
    // Emit updates
    _emitCollectionUpdate(collection);
    _emitDocumentUpdate(collection, docId);
    
    return docId;
  }
  
  @override
  Future<void> updateData({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Initialize collection if it doesn't exist
    _database[collection] ??= {};
    
    // Check if document exists
    if (_database[collection]?.containsKey(documentId) == true) {
      // Update fields
      _database[collection]![documentId]!.addAll(data);
      
      // Emit updates
      _emitCollectionUpdate(collection);
      _emitDocumentUpdate(collection, documentId);
    } else {
      throw Exception('Document not found: $collection/$documentId');
    }
  }
  
  @override
  Future<void> deleteData({
    required String collection,
    required String documentId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Remove document if it exists
    _database[collection]?.remove(documentId);
    
    // Emit updates
    _emitCollectionUpdate(collection);
    _emitDocumentUpdate(collection, documentId);
  }
  
  @override
  Future<void> batchWrite({
    required List<Map<String, dynamic>> operations,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    for (final operation in operations) {
      final type = operation['type'] as String;
      final collection = operation['collection'] as String;
      final documentId = operation['documentId'] as String?;
      final data = operation['data'] as Map<String, dynamic>?;
      
      switch (type) {
        case 'set':
          if (documentId != null && data != null) {
            // No await here to batch operations
            _database[collection] ??= {};
            _database[collection]![documentId] = Map<String, dynamic>.from(data);
          }
          break;
        case 'update':
          if (documentId != null && data != null && _database[collection]?.containsKey(documentId) == true) {
            _database[collection]![documentId]!.addAll(data);
          }
          break;
        case 'delete':
          if (documentId != null) {
            _database[collection]?.remove(documentId);
          }
          break;
      }
    }
    
    // Emit updates for all affected collections
    final collections = operations.map((op) => op['collection'] as String).toSet();
    for (final collection in collections) {
      _emitCollectionUpdate(collection);
    }
  }
  
  @override
  Future<String> uploadFile({
    required dynamic file,
    required String path,
    required String fileName,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // For mock purposes, return a fake URL
    return 'https://mock-storage.example.com/$path/$fileName';
  }
  
  @override
  Future<void> deleteFile({
    required String path,
    required String fileName,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // No actual deletion needed for mocks
  }
  
  @override
  Future<List<Map<String, dynamic>>> queryWithinRadius({
    required String collection,
    required double latitude,
    required double longitude,
    required double radiusInKm,
    String? field,
    dynamic isEqualTo,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Get collection data
    List<Map<String, dynamic>> documents = await getCollection(collection: collection);
    
    // Apply field filter if specified
    if (field != null && isEqualTo != null) {
      documents = documents.where((doc) => doc[field] == isEqualTo).toList();
    }
    
    // Filter by radius
    final results = documents.where((doc) {
      if (doc.containsKey('latitude') && doc.containsKey('longitude')) {
        final double docLat = doc['latitude'] as double;
        final double docLng = doc['longitude'] as double;
        
        final distance = _calculateDistance(
          latitude, longitude, docLat, docLng);
        
        return distance <= radiusInKm;
      }
      return false;
    }).toList();
    
    // Add distance field to results
    for (final doc in results) {
      final double docLat = doc['latitude'] as double;
      final double docLng = doc['longitude'] as double;
      
      doc['distance'] = _calculateDistance(
        latitude, longitude, docLat, docLng);
    }
    
    return results;
  }
  
  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
    double lat1, double lon1, 
    double lat2, double lon2
  ) {
    const int earthRadius = 6371; // Earth radius in kilometers
    final double latDiff = _degreesToRadians(lat2 - lat1);
    final double lonDiff = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        sin(latDiff / 2) * sin(latDiff / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(lonDiff / 2) * sin(lonDiff / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
  
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
  
  // Generate a random ID
  String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final result = StringBuffer('mock-');
    for (var i = 0; i < 20; i++) {
      result.write(chars[random.nextInt(chars.length)]);
    }
    return result.toString();
  }
  
  /// Dispose resources
  void dispose() {
    for (final controller in _collectionStreamControllers.values) {
      controller.close();
    }
    _collectionStreamControllers.clear();
    
    for (final controllers in _documentStreamControllers.values) {
      for (final controller in controllers.values) {
        controller.close();
      }
    }
    _documentStreamControllers.clear();
  }
}