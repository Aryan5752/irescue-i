// offline_queue.dart
import 'dart:convert';
import 'package:irescue/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineQueue {
  static const String _queueKey = 'offline_operation_queue';
  final DatabaseService _databaseService;

  OfflineQueue({required DatabaseService databaseService}) 
      : _databaseService = databaseService;

  // Add operation to the queue
  Future<void> addOperation(Map<String, dynamic> operation) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_queueKey) ?? [];
    
    // Add timestamp to track when operation was queued
    operation['timestamp'] = DateTime.now().toIso8601String();
    
    queue.add(jsonEncode(operation));
    await prefs.setStringList(_queueKey, queue);
  }

  // Process all queued operations
  Future<void> processQueue() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_queueKey) ?? [];
    
    if (queue.isEmpty) return;
    
    List<String> failedOperations = [];
    
    for (String operationJson in queue) {
      try {
        Map<String, dynamic> operation = jsonDecode(operationJson);
        await _executeOperation(operation);
      } catch (e) {
        // If operation fails, keep it in the queue
        failedOperations.add(operationJson);
      }
    }
    
    // Update queue with only failed operations
    await prefs.setStringList(_queueKey, failedOperations);
  }
  
  // Execute a specific operation
  Future<void> _executeOperation(Map<String, dynamic> operation) async {
    final String type = operation['type'];
    final String collectionPath = operation['collection'];
    final Map<String, dynamic> data = operation['data'];
    final String? documentId = operation['documentId'];
    
    switch (type) {
      case 'create':
        await _databaseService.setData(
          collection: collectionPath, 
          data: data,
          documentId: documentId,
        );
        break;
      case 'update':
        await _databaseService.updateData(
          collection: collectionPath,
          documentId: documentId!,
          data: data,
        );
        break;
      case 'delete':
        await _databaseService.deleteData(
          collection: collectionPath,
          documentId: documentId!,
        );
        break;
      default:
        throw Exception('Unknown operation type: $type');
    }
  }
  
  // Get the current queue for debugging
  Future<List<Map<String, dynamic>>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_queueKey) ?? [];
    
    return queue.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }
  
  // Clear the queue (use with caution)
  Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }
}