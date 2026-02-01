import 'package:flutter/material.dart';
import 'package:krushi_ai/widgets/custom_text_field.dart';
import 'package:krushi_ai/widgets/custom_button.dart';
import 'package:krushi_ai/utils/validators.dart';
import 'package:krushi_ai/services/auth_service.dart';

/// Login Screen - LAB 5 Implementation
///
/// Demonstrates:
/// - Firebase Authentication integration
/// - Form validation with custom validators
/// - Loading states during async operations
/// - Error handling and user feedback
/// - Navigation between screens
/// - Column layout widget
/// - Container for structure
/// - Padding for spacing
/// - SizedBox for vertical spacing
/// - Text widgets for labels
/// - Image/Icon for app logo
/// - TextField (via CustomTextField)
/// - ElevatedButton (via CustomButton)
/// - GestureDetector/TextButton for links
/// - SingleChildScrollView for overflow safety
/// - MediaQuery for responsive design
/// - SafeArea for device-safe rendering
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Auth service instance
  final AuthService _authService = AuthService();

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login button press with Firebase authentication
  Future<void> _handleLogin() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate inputs
    if (!_validateInputs()) {
      return;
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Login user with Firebase
      final message = await _authService.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Hide loading
      setState(() {
        _isLoading = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );

        // Navigate to dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      // Hide loading and show error
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// Validate email and password inputs
  bool _validateInputs() {
    // Validate email
    final emailError = Validators.validateEmail(_emailController.text);
    if (emailError != null) {
      setState(() {
        _errorMessage = emailError;
      });
      return false;
    }

    // Validate password
    final passwordError = Validators.validatePassword(_passwordController.text);
    if (passwordError != null) {
      setState(() {
        _errorMessage = passwordError;
      });
      return false;
    }

    return true;
  }

  /// Navigate to registration screen
  void _handleSignUp() {
    Navigator.pushNamed(context, '/register');
  }

  /// Handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      print('🔐 [LOGIN SCREEN] Starting Google Sign-In...');
      // Sign in with Google
      final message = await _authService.signInWithGoogle();

      // Hide loading
      setState(() {
        _isLoading = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );

        // Navigate to dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      print('❌ [LOGIN SCREEN] Google Sign-In error: $e');
      // Hide loading and show error
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive design using MediaQuery
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // SafeArea ensures content is within device-safe boundaries
      body: SafeArea(
        child: Container(
          // Gradient background for visual appeal
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFE8F5E9), // Light green
                Colors.white,
              ],
            ),
          ),
          // SingleChildScrollView prevents overflow on smaller screens
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Spacer for top padding
                      SizedBox(height: screenHeight * 0.08),

                      // App Logo/Icon
                      Container(
                        padding: const EdgeInsets.all(20.0),
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
                        child: Icon(
                          Icons.eco,
                          size: 80.0,
                          color: const Color(0xFF4CAF50),
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

                      // Subtitle
                      const Text(
                        'AI For Healthier Crops',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 48.0),

                      // Welcome Text
                      const Text(
                        'Welcome to KrushiAI',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 8.0),

                      const Text(
                        'Your partner in healthy farming',
                        style: TextStyle(fontSize: 14.0, color: Colors.grey),
                      ),

                      const SizedBox(height: 32.0),

                      // Error message display
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12.0),
                          margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 13.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Email Input Field (using CustomTextField)
                      CustomTextField(
                        hintText: 'Enter your email',
                        labelText: 'Email or Phone Number',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 16.0),

                      // Password Input Field (using CustomTextField)
                      CustomTextField(
                        hintText: 'Enter your password',
                        labelText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                      ),

                      const SizedBox(height: 8.0),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                          ),
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Forgot Password feature'),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // Login Button (using CustomButton) with loading state
                      _isLoading
                          ? const CircularProgressIndicator(
                              color: Color(0xFF4CAF50),
                            )
                          : CustomButton(
                              text: 'Log In',
                              onPressed: _handleLogin,
                              icon: Icons.arrow_forward,
                            ),

                      const SizedBox(height: 24.0),

                      // Divider with "Or continue with" text
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1.0,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'Or continue with',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // Social Login Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Google Button
                          _SocialLoginButton(
                            icon: Icons.g_mobiledata,
                            label: 'Google',
                            onTap: _handleGoogleSignIn,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32.0),

                      // Sign Up Link (using GestureDetector)
                      GestureDetector(
                        onTap: _handleSignUp,
                        child: RichText(
                          text: const TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14.0,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom spacer
                      SizedBox(height: screenHeight * 0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Social Login Button Widget
/// Demonstrates reusable component pattern
class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24.0),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
