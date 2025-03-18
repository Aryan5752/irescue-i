// custom_map_marker.dart
import 'package:flutter/material.dart';
import '../config/themes.dart';

class CustomMapMarker extends StatelessWidget {
  final String type; // alert, sos, warehouse, medical, police, fire, etc.
  final int? severity; // 1-5 for alerts
  final String label;
  final Color? color;
  final double size;
  final VoidCallback? onTap;
  final bool showShadow;
  
  const CustomMapMarker({
    super.key,
    required this.type,
    this.severity,
    required this.label,
    this.color,
    this.size = 40.0,
    this.onTap,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size * 1.3,
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Stack(
          children: [
            // Shadow
            if (showShadow)
              Positioned(
                bottom: 0,
                left: size * 0.25,
                right: size * 0.25,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            
            // Marker body
            _buildMarkerBody(),
            
            // Label
            if (label.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.2,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Build marker based on type
  Widget _buildMarkerBody() {
    switch (type.toLowerCase()) {
      case 'alert':
        return _buildAlertMarker();
      case 'sos':
        return _buildSosMarker();
      case 'warehouse':
        return _buildWarehouseMarker();
      case 'medical':
        return _buildMedicalMarker();
      case 'police':
        return _buildPoliceMarker();
      case 'fire':
        return _buildFireMarker();
      case 'user':
        return _buildUserMarker();
      default:
        return _buildDefaultMarker();
    }
  }
  
  // Build alert marker
  Widget _buildAlertMarker() {
    final markerColor = severity != null
        ? AppThemes.getSeverityColor(severity!)
        : color ?? Colors.red;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.location_on,
          size: size,
          color: markerColor,
        ),
        Positioned(
          top: size * 0.25,
          child: Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.warning_amber,
                size: size * 0.25,
                color: markerColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Build SOS marker
  Widget _buildSosMarker() {
    final markerColor = color ?? Colors.red;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.location_on,
          size: size,
          color: markerColor,
        ),
        Positioned(
          top: size * 0.25,
          child: Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'SOS',
                style: TextStyle(
                  color: markerColor,
                  fontSize: size * 0.15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Build warehouse marker
  Widget _buildWarehouseMarker() {
    final markerColor = color ?? Colors.blue;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.location_on,
          size: size,
          color: markerColor,
        ),
        Positioned(
          top: size * 0.25,
          child: Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.store,
                size: size * 0.25,
                color: markerColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Build medical marker
  Widget _buildMedicalMarker() {
    final markerColor = color ?? Colors.green;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.location_on,
          size: size,
          color: markerColor,
        ),
        Positioned(
          top: size * 0.25,
          child: Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.medical_services,
                size: size * 0.25,
                color: markerColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Build police marker
  Widget _buildPoliceMarker() {
    final markerColor = color ?? Colors.indigo;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.location_on,
          size: size,
          color: markerColor,
        ),
        Positioned(
          top: size * 0.25,
          child: Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.local_police,
                size: size * 0.25,
                color: markerColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Build fire marker
  Widget _buildFireMarker() {
    final markerColor = color ?? Colors.orange;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.location_on,
          size: size,
          color: markerColor,
        ),
        Positioned(
          top: size * 0.25,
          child: Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.local_fire_department,
                size: size * 0.25,
                color: markerColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Build user marker
  Widget _buildUserMarker() {
    final markerColor = color ?? Colors.blue;
    
    return Container(
      width: size * 0.8,
      height: size * 0.8,
      decoration: BoxDecoration(
        color: markerColor.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: markerColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: size * 0.4,
          height: size * 0.4,
          decoration: BoxDecoration(
            color: markerColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
  
  // Build default marker
  Widget _buildDefaultMarker() {
    final markerColor = color ?? Colors.blue;
    
    return Icon(
      Icons.location_on,
      size: size,
      color: markerColor,
    );
  }
  
  // Create a widget that can be rendered into a bitmap
  Widget toBitmapDescriptor() {
    return Material(
      color: Colors.transparent,
      child: this,
    );
  }
}