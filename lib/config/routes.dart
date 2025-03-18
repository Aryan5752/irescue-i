// routes.dart
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/civilian/civilian_home_screen.dart';
import '../screens/civilian/sos_screen.dart';
import '../screens/civilian/alerts_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/warehouse_management.dart';
import '../screens/admin/resource_allocation.dart';
import '../screens/admin/alerts_map_screen.dart';
import '../screens/common/map_screen.dart';
import '../screens/common/profile_screen.dart';
import '../screens/common/settings_screen.dart';
import '../models/user.dart';

class AppRoutes {
  // Route names
  static const String login = '/login';
  static const String register = '/register';
  static const String civilianHome = '/civilian_home';
  static const String sos = '/sos';
  static const String alerts = '/alerts';
  static const String adminDashboard = '/admin_dashboard';
  static const String warehouseManagement = '/warehouse_management';
  static const String resourceAllocation = '/resource_allocation';
  static const String alertsMap = '/alerts_map';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Route map
  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    // Other routes will use onGenerateRoute since they require parameters
  };

  // Generate routes that require parameters
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Extract arguments
    final args = settings.arguments;

    final String? routeName = settings.name;
    
    switch (routeName) {
      case civilianHome:
        if (args is User) {
          return MaterialPageRoute(
            builder: (_) => CivilianHomeScreen(currentUser: args),
          );
        }
        return _errorRoute('User data required');

      case sos:
        if (args is User) {
          return MaterialPageRoute(
            builder: (_) => SosScreen(currentUser: args),
          );
        }
        return _errorRoute('User data required');

      case alerts:
        if (args is User) {
          return MaterialPageRoute(
            builder: (_) => AlertsScreen(currentUser: args),
          );
        }
        return _errorRoute('User data required');

      case adminDashboard:
        if (args is User) {
          return MaterialPageRoute(
            builder: (_) => AdminDashboard(currentUser: args),
          );
        }
        return _errorRoute('User data required');

      case warehouseManagement:
        if (args is User) {
          return MaterialPageRoute(
            builder: (_) => WarehouseManagementScreen(currentUser: args),
          );
        }
        return _errorRoute('User data required');

      case resourceAllocation:
        if (args is User) {
          return MaterialPageRoute(
            builder: (_) => ResourceAllocationScreen(currentUser: args),
          );
        }
        return _errorRoute('User data required');

      case alertsMap:
        if (args is User) {
          return MaterialPageRoute(
            builder: (_) => AlertsMapScreen(currentUser: args),
          );
        }
        return _errorRoute('User data required');

      case map:
        if (args is MapScreenArgs) {
          return MaterialPageRoute(
            builder: (_) => MapScreen(
              initialLatitude: args.initialLatitude,
              initialLongitude: args.initialLongitude,
              initialZoom: args.initialZoom,
              markers: args.markers,
              circles: args.circles,
              polygons: args.polygons,
              polylines: args.polylines,
              showUserLocation: args.showUserLocation,
            ),
          );
        }
        return _errorRoute('Map data required');

      case profile:
        if (args is User) {
          return MaterialPageRoute(
            builder: (_) => ProfileScreen(currentUser: args),
          );
        }
        return _errorRoute('User data required');

      case AppRoutes.settings:
        if (args is User) {
          return MaterialPageRoute(
            builder: (_) => SettingsScreen(currentUser: args),
          );
        }
        return _errorRoute('User data required');

      default:
        return _errorRoute('Route not found');
    }
  }

  // Error route
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Navigation Error',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: (){},
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to navigate to route with required user
  static void navigateToUserRoute(BuildContext context, String routeName, User user) {
    Navigator.pushNamed(
      context,
      routeName,
      arguments: user,
    );
  }

  // Helper method to replace with user route
  static void replaceWithUserRoute(BuildContext context, String routeName, User user) {
    Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: user,
    );
  }
}

// Arguments class for MapScreen
class MapScreenArgs {
  final double initialLatitude;
  final double initialLongitude;
  final double initialZoom;
  final Map<String, Map<String, dynamic>>? markers;
  final Map<String, Map<String, dynamic>>? circles;
  final Map<String, Map<String, dynamic>>? polygons;
  final Map<String, Map<String, dynamic>>? polylines;
  final bool showUserLocation;

  MapScreenArgs({
    required this.initialLatitude,
    required this.initialLongitude,
    this.initialZoom = 14.0,
    this.markers,
    this.circles,
    this.polygons,
    this.polylines,
    this.showUserLocation = true,
  });
}