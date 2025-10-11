
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/connectivity_service.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database
  final databaseService = DatabaseService();
  await databaseService.database;

  // Prepare shared services
  final authService = AuthService();
  final apiService = ApiService(authService);
  final connectivityService = ConnectivityService(
    authService: authService,
    apiService: apiService,
  );

  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(MyApp(
    authService: authService,
    apiService: apiService,
    connectivityService: connectivityService,
    notificationService: notificationService,
    databaseService: databaseService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final ApiService apiService;
  final ConnectivityService connectivityService;
  final NotificationService notificationService;
  final DatabaseService databaseService;

  const MyApp({
    super.key,
    required this.authService,
    required this.apiService,
    required this.connectivityService,
    required this.notificationService,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider.value(value: connectivityService),
        Provider<NotificationService>.value(value: notificationService),
        Provider<DatabaseService>.value(value: databaseService),
      ],
      child: MaterialApp(
        title: 'Marina Hotel',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF1976D2),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1976D2),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1976D2),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          useMaterial3: true,
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, child) {
            return authService.isLoggedIn ? const DashboardScreen() : const LoginScreen();
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}
