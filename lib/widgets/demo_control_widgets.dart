// lib/widgets/demo_controls.dart

import 'package:flutter/material.dart';
import 'package:irescue/mocks/mock_connectivity_service.dart';
import 'package:irescue/mocks/mock_location_service.dart';
import 'package:irescue/mocks/mock_service_locatior.dart';
/// A widget that displays controls for manipulating the demo environment.
/// 
/// This is useful for demonstration purposes during a hackathon to simulate
/// different scenarios like going offline or changing location.
class DemoControls extends StatelessWidget {
  final bool showOnlineControls;
  final bool showLocationControls;
  final VoidCallback? onClose;

  const DemoControls({
    super.key,
    this.showOnlineControls = true,
    this.showLocationControls = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.indigo[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo[200]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.build, color: Colors.indigo),
              const SizedBox(width: 8),
              const Text(
                'Hackathon Demo Controls',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const Spacer(),
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const Divider(color: Colors.indigo),
          
          // Connectivity Controls
          if (showOnlineControls) ...[
            const Text(
              'Connectivity:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context: context,
                  icon: Icons.wifi,
                  label: 'Online (WiFi)',
                  onPressed: () {
                    final connectivityService = serviceLocator.connectivityService as MockConnectivityService;
                    connectivityService.setOnlineWifi();
                    _showToast(context, 'Device is now online (WiFi)');
                  },
                ),
                _buildActionButton(
                  context: context,
                  icon: Icons.signal_cellular_alt,
                  label: 'Online (Mobile)',
                  onPressed: () {
                    final connectivityService = serviceLocator.connectivityService as MockConnectivityService;
                    connectivityService.setOnlineMobile();
                    _showToast(context, 'Device is now online (Mobile)');
                  },
                ),
                _buildActionButton(
                  context: context,
                  icon: Icons.wifi_off,
                  label: 'Offline',
                  onPressed: () {
                    final connectivityService = serviceLocator.connectivityService as MockConnectivityService;
                    connectivityService.setOffline();
                    _showToast(context, 'Device is now offline');
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          
          // Location Controls
          if (showLocationControls) ...[
            const Text(
              'Location:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context: context,
                  icon: Icons.home,
                  label: 'City Center',
                  onPressed: () {
                    final locationService = serviceLocator.locationService as MockLocationService;
                    locationService.setMockLocation(37.7749, -122.4194); // San Francisco
                    _showToast(context, 'Location set to City Center');
                  },
                ),
                _buildActionButton(
                  context: context,
                  icon: Icons.water,
                  label: 'Near Flood',
                  onPressed: () {
                    final locationService = serviceLocator.locationService as MockLocationService;
                    locationService.setMockLocation(37.7739, -122.4190); // Near flood alert
                    _showToast(context, 'Location set near Flood Alert');
                  },
                ),
                _buildActionButton(
                  context: context,
                  icon: Icons.whatshot,
                  label: 'Near Fire',
                  onPressed: () {
                    final locationService = serviceLocator.locationService as MockLocationService;
                    locationService.setMockLocation(37.7585, -122.5140); // Near fire alert
                    _showToast(context, 'Location set near Fire Alert');
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          // Reset controls
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reset All Mock Services'),
              onPressed: () async {
                await serviceLocator.reset();
                _showToast(context, 'All mock services reset to default state');
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Build action button
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            backgroundColor: Colors.indigo[100],
            foregroundColor: Colors.indigo[800],
          ),
          child: Icon(icon),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  // Show toast message
  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// A button that toggles the demo controls panel
class DemoControlsButton extends StatelessWidget {
  final bool showOnlineControls;
  final bool showLocationControls;

  const DemoControlsButton({
    super.key,
    this.showOnlineControls = true,
    this.showLocationControls = true,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: () {
        _showDemoControlsDialog(context);
      },
      backgroundColor: Colors.indigo[100],
      foregroundColor: Colors.indigo[800],
      child: const Icon(Icons.build),
    );
  }
  
  void _showDemoControlsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.build, color: Colors.indigo),
            const SizedBox(width: 8),
            const Text('Demo Controls'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: DemoControls(
            showOnlineControls: showOnlineControls,
            showLocationControls: showLocationControls,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}