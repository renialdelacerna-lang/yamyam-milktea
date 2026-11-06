import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'screens/home_screen.dart';

/// Main entry point for the Yamyam Milk Tea application
/// Initializes Hive database and runs the app
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database service
  final databaseService = DatabaseService();
  await databaseService.initialize();

  runApp(YamyamApp(databaseService: databaseService));
}

/// Root application widget
class YamyamApp extends StatelessWidget {
  final DatabaseService databaseService;

  const YamyamApp({
    super.key,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yamyam Milk Tea',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Primary color scheme based on brown (tea theme)
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          primary: Colors.brown,
          secondary: Colors.orange,
        ),
        useMaterial3: true,
        
        // AppBar theme
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),

        // Card theme
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),

        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Floating action button theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: HomeScreen(databaseService: databaseService),
    );
  }
}
