// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irescue/mocks/mock_service_locatior.dart';
import 'config/routes.dart';
import 'config/themes.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/location_service.dart';
import 'services/connectivity_service.dart';
import 'utils/offline_queue.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/alert/alert_bloc.dart';
import 'bloc/sos/sos_bloc.dart';
import 'bloc/connectivity/connectivity_bloc.dart';
import 'bloc/warehouse/warehouse_bloc.dart';
import 'screens/auth/login_screen.dart';
import 'screens/civilian/civilian_home_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'models/user.dart';

// Global variable for demo mode
bool isDemoMode = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (isDemoMode) {
    // Initialize mock services for demo/hackathon mode
    await serviceLocator.initialize();
    
    // Log demo credentials for easy reference
    debugPrint('');
    debugPrint('======= DEMO CREDENTIALS =======');
    debugPrint('Admin: admin@test.com / password');
    debugPrint('User: user@test.com / password');
    debugPrint('================================');
    debugPrint('');
  } else {
    // Initialize Firebase for real production mode
    // This would be your original Firebase initialization code
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    throw UnimplementedError('Production mode is not available in hackathon demo');
  }
  
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
          create: (context) => serviceLocator.authService,
        ),
        RepositoryProvider<DatabaseService>(
          create: (context) => serviceLocator.databaseService,
        ),
        RepositoryProvider<LocationService>(
          create: (context) => serviceLocator.locationService,
        ),
        RepositoryProvider<ConnectivityService>(
          create: (context) => serviceLocator.connectivityService,
        ),
        RepositoryProvider<OfflineQueue>(
          create: (context) => serviceLocator.offlineQueue,
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
              connectivityService: context.read<ConnectivityService>(),
            ),
          ),
          BlocProvider<SosBloc>(
            create: (context) => SosBloc(
              databaseService: context.read<DatabaseService>(),
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
          debugShowCheckedModeBanner: false,
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