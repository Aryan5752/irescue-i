// offline_queue.dart - Improved implementation
import 'dart:convert';
import 'package:irescue/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineQueue {
  static const String _queueKey = 'offline_operation_queue';
  static const String _lastSyncKey = 'offline_queue_last_sync';
  final DatabaseService _databaseService;
  bool _isProcessing = false;

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
    
    // Update last sync time
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  // Process all queued operations
  Future<void> processQueue() async {
    // Prevent concurrent processing
    if (_isProcessing) {
      return;
    }
    
    _isProcessing = true;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> queue = prefs.getStringList(_queueKey) ?? [];
      
      if (queue.isEmpty) {
        _isProcessing = false;
        return;
      }
      
      // Sort queue by priority (high first) and timestamp
      final List<Map<String, dynamic>> decodedQueue = queue
          .map((op) => jsonDecode(op) as Map<String, dynamic>)
          .toList();
      
      decodedQueue.sort((a, b) {
        // Sort by priority first (high priority first)
        final aPriority = a['priority'] == 'high' ? 0 : 1;
        final bPriority = b['priority'] == 'high' ? 0 : 1;
        
        if (aPriority != bPriority) {
          return aPriority.compareTo(bPriority);
        }
        
        // Then sort by timestamp (oldest first)
        final aTimestamp = a['timestamp'] as String;
        final bTimestamp = b['timestamp'] as String;
        return aTimestamp.compareTo(bTimestamp);
      });
      
      // Convert back to JSON strings
      queue = decodedQueue.map((op) => jsonEncode(op)).toList();
      
      List<String> failedOperations = [];
      List<String> successfulOperations = [];
      
      for (String operationJson in queue) {
        try {
          Map<String, dynamic> operation = jsonDecode(operationJson);
          await _executeOperation(operation);
          successfulOperations.add(operationJson);
        } catch (e) {
          // If operation fails, keep it in the queue
          failedOperations.add(operationJson);
          print('Failed to process offline operation: $e');
        }
      }
      
      // Update queue with only failed operations
      await prefs.setStringList(_queueKey, failedOperations);
      
      // Log successful syncs
      final successCount = successfulOperations.length;
      if (successCount > 0) {
        print('Successfully processed $successCount offline operations');
      }
      
      // Update last sync time
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error processing offline queue: $e');
    } finally {
      _isProcessing = false;
    }
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
  
  // Get the queue size
  Future<int> getQueueSize() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_queueKey) ?? [];
    return queue.length;
  }
  
  // Get the last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString(_lastSyncKey);
    if (lastSync != null) {
      return DateTime.parse(lastSync);
    }
    return null;
  }
  
  // Clear the queue (use with caution)
  Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }
}