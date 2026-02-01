import 'package:flutter/material.dart';
import 'package:krushi_ai/services/auth_service.dart';
import 'package:krushi_ai/screens/login/login_screen.dart';
import 'package:krushi_ai/screens/dashboard/dashboard_screen.dart';

/// AuthWrapper - Session Management Screen
///
/// Purpose: Checks user authentication state on app startup
/// Implements: Auto-login functionality using SharedPreferences
/// Navigation: Redirects to Dashboard if logged in, Registration if not

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  /// Check if user has an active session
  Future<void> _checkAuthStatus() async {
    try {
      // Check if user session exists
      final hasSession = await _authService.checkSession();

      // Small delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isChecking = false;
        });

        // Navigate based on session status
        if (hasSession) {
          // User is logged in, go to dashboard
          print('✅ [WRAPPER] Session found, navigating to dashboard');
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          // User is not logged in, go to registration screen
          print('⚠️ [WRAPPER] No session, navigating to registration');
          Navigator.pushReplacementNamed(context, '/register');
        }
      }
    } catch (e) {
      // Error checking session, default to registration screen
      print('❌ [WRAPPER] Error checking session: $e');
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
        Navigator.pushReplacementNamed(context, '/register');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFE8F5E9), Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20.0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco,
                  size: 80.0,
                  color: Color(0xFF4CAF50),
                ),
              ),

              const SizedBox(height: 24.0),

              // App Title
              const Text(
                'KrushiAI',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                  letterSpacing: 1.0,
                ),
              ),

              const SizedBox(height: 8.0),

              const Text(
                'AI For Healthier Crops',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 48.0),

              // Loading indicator
              if (_isChecking)
                const CircularProgressIndicator(color: Color(0xFF4CAF50)),
            ],
          ),
        ),
      ),
    );
  }
}
