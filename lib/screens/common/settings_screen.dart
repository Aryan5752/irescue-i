// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../bloc/auth/auth_bloc.dart';

class SettingsScreen extends StatefulWidget {
  final User currentUser;

  const SettingsScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // App settings
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _saveOfflineData = true;
  
  // Alert preferences
  List<String> _alertTypes = [];
  double _alertRadius = 10.0; // in km
  
  @override
  void initState() {
    super.initState();
    
    // Load settings from SharedPreferences
    _loadSettings();
    
    // Initialize alert subscriptions from user data
    if (widget.currentUser.subscriptions != null) {
      _alertTypes = List.from(widget.currentUser.subscriptions!);
    } else {
      // Default alert types
      _alertTypes = ['Earthquake', 'Flood', 'Fire', 'Hurricane', 'Tornado'];
    }
  }
  
  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _locationEnabled = prefs.getBool('locationEnabled') ?? true;
      _saveOfflineData = prefs.getBool('saveOfflineData') ?? true;
      _alertRadius = prefs.getDouble('alertRadius') ?? 10.0;
    });
  }
  
  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('locationEnabled', _locationEnabled);
    await prefs.setBool('saveOfflineData', _saveOfflineData);
    await prefs.setDouble('alertRadius', _alertRadius);
    
    // Update user subscriptions
    if (widget.currentUser.subscriptions == null || 
        !_listsEqual(widget.currentUser.subscriptions!, _alertTypes)) {
      context.read<AuthBloc>().add(
        AuthProfileUpdateRequested(
          subscriptions: _alertTypes,
        ),
      );
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  // Check if two lists are equal
  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            
            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Settings
                  const Text(
                    'App Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Dark Mode
                  _buildSwitchTile(
                    title: 'Dark Mode',
                    subtitle: 'Enable dark theme for the app',
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                    icon: Icons.dark_mode,
                  ),
                  const Divider(),
                  
                  // Notifications
                  _buildSwitchTile(
                    title: 'Notifications',
                    subtitle: 'Receive alerts and notifications',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    icon: Icons.notifications,
                  ),
                  const Divider(),
                  
                  // Location
                  _buildSwitchTile(
                    title: 'Location Services',
                    subtitle: 'Allow app to access your location',
                    value: _locationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _locationEnabled = value;
                      });
                    },
                    icon: Icons.location_on,
                  ),
                  const Divider(),
                  
                  // Offline Data
                  _buildSwitchTile(
                    title: 'Save Offline Data',
                    subtitle: 'Store data for offline use',
                    value: _saveOfflineData,
                    onChanged: (value) {
                      setState(() {
                        _saveOfflineData = value;
                      });
                    },
                    icon: Icons.cloud_off,
                  ),
                  const SizedBox(height: 24),
                  
                  // Alert Preferences
                  const Text(
                    'Alert Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Alert Types
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alert Types',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Select the types of alerts you want to receive',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildAlertTypeCheckbox('Earthquake'),
                          _buildAlertTypeCheckbox('Flood'),
                          _buildAlertTypeCheckbox('Fire'),
                          _buildAlertTypeCheckbox('Hurricane'),
                          _buildAlertTypeCheckbox('Tornado'),
                          _buildAlertTypeCheckbox('Tsunami'),
                          _buildAlertTypeCheckbox('Landslide'),
                          _buildAlertTypeCheckbox('Chemical'),
                          _buildAlertTypeCheckbox('Security'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Alert Radius
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alert Radius',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Distance (in km) for which you want to receive alerts',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Slider(
                            value: _alertRadius,
                            min: 5.0,
                            max: 100.0,
                            divisions: 19,
                            label: '${_alertRadius.round()} km',
                            onChanged: (value) {
                              setState(() {
                                _alertRadius = value;
                              });
                            },
                          ),
                          Text(
                            'Current radius: ${_alertRadius.round()} km',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // About
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Version
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Version'),
                    subtitle: const Text('1.0.0'),
                  ),
                  
                  // Privacy Policy
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Show privacy policy
                      _showPrivacyPolicy();
                    },
                  ),
                  
                  // Terms of Service
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Show terms of service
                      _showTermsOfService();
                    },
                  ),
                  
                  // About / Credits
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Show about dialog
                      _showAboutDialog();
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save Settings'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _saveSettings,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  // Build switch tile
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon),
    );
  }
  
  // Build alert type checkbox
  Widget _buildAlertTypeCheckbox(String type) {
    return CheckboxListTile(
      title: Text(type),
      value: _alertTypes.contains(type),
      onChanged: (value) {
        setState(() {
          if (value == true) {
            if (!_alertTypes.contains(type)) {
              _alertTypes.add(type);
            }
          } else {
            _alertTypes.remove(type);
          }
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }
  
  // Show privacy policy
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This is a demo privacy policy for the hackathon. '
            'In a real app, this would be a comprehensive privacy policy. '
            'The app collects location data to provide alerts for nearby emergencies. '
            'User data is stored securely and not shared with third parties.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  // Show terms of service
  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'This is a demo terms of service for the hackathon. '
            'In a real app, this would be comprehensive terms of service. '
            'The app is provided "as is" without warranty of any kind. '
            'Users are responsible for ensuring their own safety in emergency situations.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  // Show about dialog
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Disaster Management',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.security,
        size: 48,
        color: Colors.blue,
      ),
      children: const [
        Text(
          'Disaster Management is a hackathon project designed to help '
          'people during natural disasters and emergencies. The app '
          'provides real-time alerts, SOS functionality, and resource '
          'management capabilities.',
        ),
        SizedBox(height: 16),
        Text(
          'Created for demonstration purposes only.',
        ),
      ],
    );
  }
}