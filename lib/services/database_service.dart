// database_service.dart
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Get a collection stream
  Stream<List<Map<String, dynamic>>> streamCollection({
    required String collection,
  }) {
    return _firestore
        .collection(collection)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
              .toList();
        });
  }
  
  // Get a filtered collection stream
  Stream<List<Map<String, dynamic>>> streamCollectionWhere({
    required String collection,
    required String field,
    required dynamic isEqualTo,
  }) {
    return _firestore
        .collection(collection)
        .where(field, isEqualTo: isEqualTo)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
              .toList();
        });
  }
  
  // Get a document stream
  Stream<Map<String, dynamic>?> streamDocument({
    required String collection,
    required String documentId,
  }) {
    return _firestore
        .collection(collection)
        .doc(documentId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            return null;
          }
          return {
            ...doc.data()!,
            'id': doc.id,
          };
        });
  }
  
  // Get a collection
  Future<List<Map<String, dynamic>>> getCollection({
    required String collection,
  }) async {
    final snapshot = await _firestore.collection(collection).get();
    
    return snapshot.docs
        .map((doc) => {
          ...doc.data(),
          'id': doc.id,
        })
        .toList();
  }
  
  // Get a filtered collection
  Future<List<Map<String, dynamic>>> getCollectionWhere({
    required String collection,
    required String field,
    required dynamic isEqualTo,
  }) async {
    final snapshot = await _firestore
        .collection(collection)
        .where(field, isEqualTo: isEqualTo)
        .get();
    
    return snapshot.docs
        .map((doc) => {
          ...doc.data(),
          'id': doc.id,
        })
        .toList();
  }
  
  // Get a document
  Future<Map<String, dynamic>?> getData({
    required String collection,
    required String documentId,
  }) async {
    final doc = await _firestore
        .collection(collection)
        .doc(documentId)
        .get();
    
    if (!doc.exists) {
      return null;
    }
    
    return {
      ...doc.data()!,
      'id': doc.id,
    };
  }
  
  // Set data (create or overwrite)
  Future<void> setData({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    if (documentId != null) {
      await _firestore
          .collection(collection)
          .doc(documentId)
          .set(data);
    } else {
      await _firestore
          .collection(collection)
          .add(data);
    }
  }
  
  // Add data (auto-generate ID)
  Future<String> addData({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    final docRef = await _firestore
        .collection(collection)
        .add(data);
    
    return docRef.id;
  }
  
  // Update data
  Future<void> updateData({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(collection)
        .doc(documentId)
        .update(data);
  }
  
  // Delete data
  Future<void> deleteData({
    required String collection,
    required String documentId,
  }) async {
    await _firestore
        .collection(collection)
        .doc(documentId)
        .delete();
  }
  
  // Upload a file to storage
  Future<String> uploadFile({
    required File file,
    required String path,
    required String fileName,
  }) async {
    final ref = _storage.ref().child('$path/$fileName');
    
    final uploadTask = ref.putFile(file);
    
    final snapshot = await uploadTask;
    
    return await snapshot.ref.getDownloadURL();
  }
  
  // Delete a file from storage
  Future<void> deleteFile({
    required String path,
    required String fileName,
  }) async {
    final ref = _storage.ref().child('$path/$fileName');
    
    await ref.delete();
  }
  
  // Batch write
  Future<void> batchWrite({
    required List<Map<String, dynamic>> operations,
  }) async {
    final batch = _firestore.batch();
    
    for (final operation in operations) {
      final type = operation['type'] as String;
      final collection = operation['collection'] as String;
      final documentId = operation['documentId'] as String?;
      final data = operation['data'] as Map<String, dynamic>?;
      
      switch (type) {
        case 'set':
          if (documentId != null && data != null) {
            final docRef = _firestore.collection(collection).doc(documentId);
            batch.set(docRef, data);
          }
          break;
        case 'update':
          if (documentId != null && data != null) {
            final docRef = _firestore.collection(collection).doc(documentId);
            batch.update(docRef, data);
          }
          break;
        case 'delete':
          if (documentId != null) {
            final docRef = _firestore.collection(collection).doc(documentId);
            batch.delete(docRef);
          }
          break;
        default:
          throw Exception('Unknown operation type: $type');
      }
    }
    
    await batch.commit();
  }
  
  // Transaction
  Future<void> runTransaction({
    required Future<void> Function(Transaction) transaction,
  }) async {
    await _firestore.runTransaction(transaction);
  }
  
  // Query data within a radius (using Haversine formula via Firestore's GeoPoint)
  Future<List<Map<String, dynamic>>> queryWithinRadius({
    required String collection,
    required double latitude,
    required double longitude,
    required double radiusInKm,
    String? field,
    dynamic isEqualTo,
  }) async {
    // For proper geospatial queries, you would typically use a library like GeoFirestore
    // Since we're making a hackathon app, we'll do a simplified version
    // First, get all documents (potentially filtered)
    final QuerySnapshot snapshot;
    
    if (field != null && isEqualTo != null) {
      snapshot = await _firestore
          .collection(collection)
          .where(field, isEqualTo: isEqualTo)
          .get();
    } else {
      snapshot = await _firestore.collection(collection).get();
    }
    
    // Then filter in code
    final results = <Map<String, dynamic>>[];
    
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Check if document has latitude and longitude
      if (data.containsKey('latitude') && data.containsKey('longitude')) {
        final docLat = data['latitude'] as double;
        final docLng = data['longitude'] as double;
        
        // Calculate distance using Haversine formula
        final distance = _calculateDistance(
          latitude,
          longitude,
          docLat,
          docLng,
        );
        
        // If within radius, add to results
        if (distance <= radiusInKm) {
          results.add({
            ...data,
            'id': doc.id,
            'distance': distance,
          });
        }
      }
    }
    
    return results;
  }
  
  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Pi/180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}