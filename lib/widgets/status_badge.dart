// status_badge.dart
import 'package:flutter/material.dart';
import '../config/themes.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;
  final Color? textColor;
  final Color? backgroundColor;
  final bool bold;
  final EdgeInsetsGeometry? padding;
  final String? customText;
  final BorderRadiusGeometry? borderRadius;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize,
    this.textColor,
    this.backgroundColor,
    this.bold = true,
    this.padding,
    this.customText,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Determine badge color based on status
    final Color badgeColor = backgroundColor ?? _getStatusColor(status);
    
    // Determine text color (default to white for dark backgrounds, black for light)
    final Color textCol = textColor ?? _getTextColor(badgeColor);
    
    // Determine display text (uppercase by default)
    final String displayText = customText ?? status.toUpperCase();
    
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textCol,
          fontSize: fontSize ?? 12,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
  // Get standard color for status
  Color _getStatusColor(String statusValue) {
    return AppThemes.getStatusColor(statusValue);
  }
  
  // Determine if text should be white or black based on background brightness
  Color _getTextColor(Color backgroundColor) {
    // Calculate relative luminance (brightness) of the color
    final double luminance = (0.299 * backgroundColor.red + 
        0.587 * backgroundColor.green + 
        0.114 * backgroundColor.blue) / 255;
    
    // Use white text for dark backgrounds, black for light
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
  
  // Factory for severity badge (1-5 scale)
  factory StatusBadge.severity(int severity, {
    double? fontSize,
    Color? textColor,
    bool bold = true,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
  }) {
    String severityText;
    switch (severity) {
      case 5:
        severityText = 'CRITICAL';
        break;
      case 4:
        severityText = 'SEVERE';
        break;
      case 3:
        severityText = 'MODERATE';
        break;
      case 2:
        severityText = 'MINOR';
        break;
      case 1:
        severityText = 'LOW';
        break;
      default:
        severityText = 'UNKNOWN';
    }
    
    return StatusBadge(
      status: severityText.toLowerCase(),
      fontSize: fontSize,
      textColor: textColor,
      backgroundColor: AppThemes.getSeverityColor(severity),
      bold: bold,
      padding: padding,
      customText: severityText,
      borderRadius: borderRadius,
    );
  }
  
  // Factory for SOS status badge
  factory StatusBadge.sos(String sosStatus, {
    double? fontSize,
    Color? textColor,
    bool bold = true,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
  }) {
    Color statusColor;
    
    switch (sosStatus.toLowerCase()) {
      case 'pending':
        statusColor = Colors.red;
        break;
      case 'active':
        statusColor = Colors.orange;
        break;
      case 'assigned':
        statusColor = Colors.blue;
        break;
      case 'resolved':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }
    
    return StatusBadge(
      status: sosStatus,
      fontSize: fontSize,
      textColor: textColor,
      backgroundColor: statusColor,
      bold: bold,
      padding: padding,
      borderRadius: borderRadius,
    );
  }
  
  // Factory for resource stock status
  factory StatusBadge.stock(int quantity, int minStockLevel, {
    double? fontSize,
    Color? textColor,
    bool bold = true,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
  }) {
    String stockStatus;
    Color statusColor;
    
    if (quantity <= 0) {
      stockStatus = 'OUT OF STOCK';
      statusColor = Colors.red[900]!;
    } else if (quantity <= minStockLevel * 0.5) {
      stockStatus = 'CRITICAL';
      statusColor = Colors.red;
    } else if (quantity <= minStockLevel) {
      stockStatus = 'LOW';
      statusColor = Colors.orange;
    } else if (quantity <= minStockLevel * 2) {
      stockStatus = 'ADEQUATE';
      statusColor = Colors.green;
    } else {
      stockStatus = 'SUFFICIENT';
      statusColor = Colors.blue;
    }
    
    return StatusBadge(
      status: stockStatus.toLowerCase(),
      fontSize: fontSize,
      textColor: textColor,
      backgroundColor: statusColor,
      bold: bold,
      padding: padding,
      customText: stockStatus,
      borderRadius: borderRadius,
    );
  }
  
  // Factory for connectivity status
  factory StatusBadge.connectivity(bool isConnected, {
    double? fontSize,
    Color? textColor,
    bool bold = true,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
  }) {
    return StatusBadge(
      status: isConnected ? 'online' : 'offline',
      fontSize: fontSize,
      textColor: textColor,
      backgroundColor: isConnected ? Colors.green : Colors.red,
      bold: bold,
      padding: padding,
      customText: isConnected ? 'ONLINE' : 'OFFLINE',
      borderRadius: borderRadius,
    );
  }
}