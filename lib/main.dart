// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:irescue/firebase_options.dart';
import 'package:irescue/utils/offline_queue.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';
import 'config/themes.dart';

import 'models/user.dart';

import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/connectivity_service.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/alert/alert_bloc.dart';
import 'bloc/sos/sos_bloc.dart';
import 'bloc/connectivity/connectivity_bloc.dart';
import 'bloc/warehouse/warehouse_bloc.dart';

import 'screens/auth/login_screen.dart';
import 'screens/civilian/civilian_home_screen.dart';
import 'screens/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
 await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  
  // // Initialize services
  // final locationService = LocationService();
  // await locationService.initialize();
  
  // final notificationService = NotificationService();
  // await notificationService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Services
        RepositoryProvider<AuthService>(
          create: (context) => AuthService(),
        ),
        RepositoryProvider<DatabaseService>(
          create: (context) => DatabaseService(),
        ),
        // RepositoryProvider<LocationService>(
        //   create: (context) => LocationService(),
        // ),
        // RepositoryProvider<NotificationService>(
        //   create: (context) => NotificationService(),
        // ),
        RepositoryProvider<OfflineQueue>(
          create: (context) => OfflineQueue(
            databaseService: context.read<DatabaseService>(),
          ),
        ),
        RepositoryProvider<ConnectivityService>(
          create: (context) => ConnectivityService(
            offlineQueue: context.read<OfflineQueue>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // BLoCs
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authService: context.read<AuthService>(),
              databaseService: context.read<DatabaseService>(),
            )..add(const AuthStarted()),
          ),
          BlocProvider<ConnectivityBloc>(
            create: (context) => ConnectivityBloc(
              connectivityService: context.read<ConnectivityService>(),
            )..add(const ConnectivityStarted()),
          ),
          BlocProvider<AlertBloc>(
            create: (context) => AlertBloc(
              databaseService: context.read<DatabaseService>(),
              // locationService: context.read<LocationService>(),
              connectivityService: context.read<ConnectivityService>(),
            ),
          ),
          BlocProvider<SosBloc>(
            create: (context) => SosBloc(
              databaseService: context.read<DatabaseService>(),
              // locationService: context.read<LocationService>(),
              connectivityService: context.read<ConnectivityService>(),
            ),
          ),
          BlocProvider<WarehouseBloc>(
            create: (context) => WarehouseBloc(
              databaseService: context.read<DatabaseService>(),
              connectivityService: context.read<ConnectivityService>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Disaster Management',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system,
          // Set home to AuthGate for authentication flow
          home: const AuthGate(),
          routes: AppRoutes.routes,
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, connectivityState) {
        // Show connectivity banner if offline
        
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is AuthAuthenticated) {
              // Route based on user role
              final User currentUser = state.user;
              
              if (currentUser.role == 'admin' || currentUser.role == 'government') {
                return AdminDashboard(currentUser: currentUser);
              } else {
                return CivilianHomeScreen(currentUser: currentUser);
              }
            } else {
              return LoginScreen();
            }
          },
        );
      },
    );
  }
}