// lib/services/database_service.dart

/// Abstract interface for database services
/// This can be implemented by both real Firestore and mock implementations
abstract class DatabaseService {
  /// Stream a collection of documents
  Stream<List<Map<String, dynamic>>> streamCollection({
    required String collection,
  });
  
  /// Stream a filtered collection of documents
  Stream<List<Map<String, dynamic>>> streamCollectionWhere({
    required String collection,
    required String field,
    required dynamic isEqualTo,
  });
  
  /// Stream a single document
  Stream<Map<String, dynamic>?> streamDocument({
    required String collection,
    required String documentId,
  });
  
  /// Get a collection of documents
  Future<List<Map<String, dynamic>>> getCollection({
    required String collection,
  });
  
  /// Get a filtered collection of documents
  Future<List<Map<String, dynamic>>> getCollectionWhere({
    required String collection,
    required String field,
    required dynamic isEqualTo,
  });
  
  /// Get a single document
  Future<Map<String, dynamic>?> getData({
    required String collection,
    required String documentId,
  });
  
  /// Set (create or replace) a document
  Future<void> setData({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  });
  
  /// Add a new document with auto-generated ID
  Future<String> addData({
    required String collection,
    required Map<String, dynamic> data,
  });
  
  /// Update fields in an existing document
  Future<void> updateData({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  });
  
  /// Delete a document
  Future<void> deleteData({
    required String collection,
    required String documentId,
  });
  
  /// Execute multiple write operations in a batch
  Future<void> batchWrite({
    required List<Map<String, dynamic>> operations,
  });
  
  /// Upload a file to storage
  Future<String> uploadFile({
    required dynamic file,
    required String path,
    required String fileName,
  });
  
  /// Delete a file from storage
  Future<void> deleteFile({
    required String path,
    required String fileName,
  });
  
  /// Query for documents within a radius of a location
  Future<List<Map<String, dynamic>>> queryWithinRadius({
    required String collection,
    required double latitude,
    required double longitude,
    required double radiusInKm,
    String? field,
    dynamic isEqualTo,
  });
}