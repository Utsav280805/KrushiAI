import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:krushi_ai/screens/auth_wrapper.dart';
import 'package:krushi_ai/screens/login/login_screen.dart';
import 'package:krushi_ai/screens/registration/registration_screen.dart';
import 'package:krushi_ai/screens/dashboard/dashboard_screen.dart';

/// Main entry point - LAB 5 Implementation
/// Initializes Firebase and starts the app with session management

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  print('🔥 [INIT] Starting KrushiAI application...');
  
  try {
    // Initialize Firebase
    print('🔥 [FIREBASE] Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ [FIREBASE] Firebase initialized successfully!');
    print('🔥 [FIREBASE] Firebase app name: ${Firebase.app().name}');
  } catch (e, stackTrace) {
    print('❌ [FIREBASE] Failed to initialize Firebase: $e');
    print('📋 [FIREBASE] Stack trace: $stackTrace');
  }

  print('🚀 [APP] Launching app...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Krushi AI - Agricultural Project',
      debugShowCheckedModeBanner: false,

      // Theme configuration with green agricultural colors
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // Primary green
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFF66BB6A),
          surface: Colors.white,
          error: const Color(0xFFE53935),
        ),

        // AppBar theme
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        ),

        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),

        // Floating action button theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
      ),

      // Set AuthWrapper as the initial route for session management
      home: const AuthWrapper(),

      // Define named routes for navigation
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
