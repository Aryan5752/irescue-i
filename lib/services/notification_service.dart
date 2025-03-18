// // notification_service.dart
// import 'dart:async';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import '../models/alert.dart';
// import '../models/sos_request.dart';

// class NotificationService {
//   // Singleton pattern
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();
  
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
//       FlutterLocalNotificationsPlugin();
  
//   // Initialize notification plugin
//   Future<void> initialize() async {
//     // Initialize settings for Android
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
    
//     // Initialize settings for iOS
//     const DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
    
//     // Combined initialization settings
//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
    
//     // Initialize the plugin
//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//     );
//   }
  
//   // Handle notification tap
//   void _onNotificationTapped(NotificationResponse response) {
//     // Parse payload and handle navigation
//     if (response.payload != null) {
//       final String payload = response.payload!;
      
//       // For a real implementation, you would handle navigation here
//       // For example, if the payload is "alert:123", navigate to the alert details page
//       print('Notification tapped with payload: $payload');
//     }
//   }
  
//   // Request permission for notifications (required for iOS)
//   Future<bool> requestPermission() async {
//     final result = await _flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );
    
//     return result ?? false;
//   }
  
//   // Show a basic notification
//   Future<void> showNotification({
//     required int id,
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'disaster_management_channel',
//       'Disaster Management',
//       importance: Importance.high,
//       priority: Priority.high,
//       showWhen: true,
//     );
    
//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
    
//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
    
//     await _flutterLocalNotificationsPlugin.show(
//       id,
//       title,
//       body,
//       notificationDetails,
//       payload: payload,
//     );
//   }
  
//   // Show an alert notification
//   Future<void> showAlertNotification(Alert alert) async {
//     // Generate notification ID from alert ID
//     final int notificationId = alert.id.hashCode;
    
//     // Create title based on severity
//     String severityText;
//     switch (alert.severity) {
//       case 5:
//         severityText = '⚠️ CRITICAL';
//         break;
//       case 4:
//         severityText = '⚠️ SEVERE';
//         break;
//       case 3:
//         severityText = '⚠️ MODERATE';
//         break;
//       default:
//         severityText = '⚠️ ALERT';
//     }
    
//     final String title = '$severityText: ${alert.title}';
//     final String body = alert.description;
//     final String payload = 'alert:${alert.id}';
    
//     await showNotification(
//       id: notificationId,
//       title: title,
//       body: body,
//       payload: payload,
//     );
//   }
  
//   // Show an SOS request notification
//   Future<void> showSosNotification(SosRequest sosRequest) async {
//     // Generate notification ID from SOS ID
//     final int notificationId = sosRequest.id.hashCode;
    
//     final String title = '🆘 SOS Request: ${sosRequest.type}';
//     final String body = 'From ${sosRequest.userName}: ${sosRequest.description}';
//     final String payload = 'sos:${sosRequest.id}';
    
//     await showNotification(
//       id: notificationId,
//       title: title,
//       body: body,
//       payload: payload,
//     );
//   }
  
//   // Show a resource alert notification (low stock, etc.)
//   Future<void> showResourceAlert({
//     required String title,
//     required String message,
//     required String resourceId,
//   }) async {
//     // Generate notification ID from resource ID
//     final int notificationId = resourceId.hashCode;
    
//     final String notificationTitle = '📦 $title';
//     final String payload = 'resource:$resourceId';
    
//     await showNotification(
//       id: notificationId,
//       title: notificationTitle,
//       body: message,
//       payload: payload,
//     );
//   }
  
//   // Cancel a specific notification
//   Future<void> cancelNotification(int id) async {
//     await _flutterLocalNotificationsPlugin.cancel(id);
//   }
  
//   // Cancel all notifications
//   Future<void> cancelAllNotifications() async {
//     await _flutterLocalNotificationsPlugin.cancelAll();
//   }
// }