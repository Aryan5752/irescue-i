// map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../services/location_service.dart';

class MapScreen extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final double initialZoom;
  final Map<String, Map<String, dynamic>>? markers;
  final Map<String, Map<String, dynamic>>? polygons;
  final Map<String, Map<String, dynamic>>? circles;
  final Map<String, Map<String, dynamic>>? polylines;
  final bool showUserLocation;
  final Function(LatLng)? onMapTap;
  final Function(CameraPosition)? onCameraMove;

  const MapScreen({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    this.initialZoom = 14.0,
    this.markers,
    this.polygons,
    this.circles,
    this.polylines,
    this.showUserLocation = true,
    this.onMapTap,
    this.onCameraMove,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polygon> _polygons = {};
  final Set<Circle> _circles = {};
  final Set<Polyline> _polylines = {};
  LatLng? _userLocation;
  Timer? _locationUpdateTimer;
  // final LocationService _locationService = LocationService();
  
  final Map<String, BitmapDescriptor> _markerIcons = {};
  
  @override
  void initState() {
    super.initState();
    
    // Initialize map overlays
    _initMarkers();
    _initPolygons();
    _initCircles();
    _initPolylines();
    
    // Get user location
    if (widget.showUserLocation) {
      _getCurrentLocation();
      // Set up periodic location updates
      _locationUpdateTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _getCurrentLocation(),
      );
    }
  }
  
  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }
  
  // Get current location
  Future<void> _getCurrentLocation() async {
    try {
      // final position = await _locationService.getCurrentPosition();
      setState(() {
        // _userLocation = LatLng(position.latitude, position.longitude);
        
        // Add or update user marker
        _markers.removeWhere(
          (marker) => marker.markerId == const MarkerId('user_location'),
        );
        
        _markers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position: _userLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(
              title: 'Your Location',
            ),
          ),
        );
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }
  
  // Initialize marker icons
  Future<void> _loadMarkerIcons() async {
    // For a real app, you would load custom icons here
    // For the hackathon, we'll use default icons
    _markerIcons['alert'] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    _markerIcons['warehouse'] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    _markerIcons['sos'] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    _markerIcons['medical'] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    _markerIcons['police'] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    _markerIcons['fire'] = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
  }
  
  // Initialize markers
  void _initMarkers() {
    if (widget.markers == null) return;
    
    widget.markers!.forEach((id, data) {
      final position = LatLng(
        data['latitude'] as double,
        data['longitude'] as double,
      );
      
      BitmapDescriptor icon = BitmapDescriptor.defaultMarker;
      
      // Set icon based on marker type
      final type = data['type'] as String?;
      if (type != null && _markerIcons.containsKey(type)) {
        icon = _markerIcons[type]!;
      } else if (type == 'alert') {
        // For alerts, use severity-based color if available
        final severity = data['severity'] as int?;
        if (severity != null) {
          switch (severity) {
            case 5:
              icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
              break;
            case 4:
              icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
              break;
            case 3:
              icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
              break;
            default:
              icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
          }
        }
      }
      
      _markers.add(
        Marker(
          markerId: MarkerId(id),
          position: position,
          icon: icon,
          infoWindow: InfoWindow(
            title: data['title'] as String?,
            snippet: data['snippet'] as String?,
          ),
          onTap: data['onTap'] as Function()?,
        ),
      );
    });
  }
  
  // Initialize polygons
  void _initPolygons() {
    if (widget.polygons == null) return;
    
    widget.polygons!.forEach((id, data) {
      final points = (data['points'] as List<dynamic>)
          .map((point) => LatLng(
                point['latitude'] as double,
                point['longitude'] as double,
              ))
          .toList();
      
      _polygons.add(
        Polygon(
          polygonId: PolygonId(id),
          points: points,
          fillColor: (data['fillColor'] as Color?)?.withOpacity(0.3) ?? 
              Colors.red.withOpacity(0.3),
          strokeColor: (data['strokeColor'] as Color?) ?? Colors.red,
          strokeWidth: (data['strokeWidth'] as int?) ?? 2,
        ),
      );
    });
  }
  
  // Initialize circles
  void _initCircles() {
    if (widget.circles == null) return;
    
    widget.circles!.forEach((id, data) {
      final center = LatLng(
        data['latitude'] as double,
        data['longitude'] as double,
      );
      
      _circles.add(
        Circle(
          circleId: CircleId(id),
          center: center,
          radius: data['radius'] as double,
          fillColor: (data['fillColor'] as Color?)?.withOpacity(0.3) ?? 
              Colors.red.withOpacity(0.3),
          strokeColor: (data['strokeColor'] as Color?) ?? Colors.red,
          strokeWidth: (data['strokeWidth'] as int?) ?? 2,
        ),
      );
    });
  }
  
  // Initialize polylines
  void _initPolylines() {
    if (widget.polylines == null) return;
    
    widget.polylines!.forEach((id, data) {
      final points = (data['points'] as List<dynamic>)
          .map((point) => LatLng(
                point['latitude'] as double,
                point['longitude'] as double,
              ))
          .toList();
      
      _polylines.add(
        Polyline(
          polylineId: PolylineId(id),
          points: points,
          color: (data['color'] as Color?) ?? Colors.blue,
          width: (data['width'] as int?) ?? 5,
        ),
      );
    });
  }
  
  // Focus on user location
  Future<void> _focusOnUserLocation() async {
    if (_userLocation == null) {
      await _getCurrentLocation();
    }
    
    if (_userLocation != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          _userLocation!,
          widget.initialZoom,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.initialLatitude,
                widget.initialLongitude,
              ),
              zoom: widget.initialZoom,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _loadMarkerIcons().then((_) => _initMarkers());
            },
            markers: _markers,
            polygons: _polygons,
            circles: _circles,
            polylines: _polylines,
            myLocationEnabled: widget.showUserLocation,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: false,
            onTap: widget.onMapTap,
            onCameraMove: widget.onCameraMove,
          ),
          
          // Layer controls
          Positioned(
            top: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Container(
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: _focusOnUserLocation,
                      tooltip: 'My Location',
                    ),
                    const Divider(height: 1),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final controller = await _controller.future;
                        controller.animateCamera(CameraUpdate.zoomIn());
                      },
                      tooltip: 'Zoom In',
                    ),
                    const Divider(height: 1),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () async {
                        final controller = await _controller.future;
                        controller.animateCamera(CameraUpdate.zoomOut());
                      },
                      tooltip: 'Zoom Out',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}