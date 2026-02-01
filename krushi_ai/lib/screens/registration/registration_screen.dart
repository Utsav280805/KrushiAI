import 'package:flutter/material.dart';
import 'package:krushi_ai/widgets/custom_text_field.dart';
import 'package:krushi_ai/widgets/custom_button.dart';
import 'package:krushi_ai/utils/validators.dart';
import 'package:krushi_ai/services/auth_service.dart';

/// Registration Screen - LAB 5 Implementation
///
/// Demonstrates:
/// - Form validation with custom validators
/// - Firebase user registration
/// - Password confirmation matching
/// - Error handling and user feedback
/// - Navigation between screens
/// - Loading states during async operations

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Auth service instance
  final AuthService _authService = AuthService();

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle registration button press
  Future<void> _handleRegistration() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_validateForm()) {
      return;
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Register user with Firebase
      final message = await _authService.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
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

        // Navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // Hide loading and show error
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// Validate all form fields
  bool _validateForm() {
    // Validate full name
    final nameError = Validators.validateRequired(
      _fullNameController.text,
      'Full Name',
    );
    if (nameError != null) {
      setState(() {
        _errorMessage = nameError;
      });
      return false;
    }

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

    // Validate password match
    final matchError = Validators.validatePasswordMatch(
      _passwordController.text,
      _confirmPasswordController.text,
    );
    if (matchError != null) {
      setState(() {
        _errorMessage = matchError;
      });
      return false;
    }

    return true;
  }

  /// Navigate to login screen
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFFE8F5E9), Colors.white],
            ),
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.05),

                        // App Logo
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
                          child: const Icon(
                            Icons.eco,
                            size: 60.0,
                            color: Color(0xFF4CAF50),
                          ),
                        ),

                        const SizedBox(height: 24.0),

                        // Title
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),

                        const SizedBox(height: 8.0),

                        const Text(
                          'Join KrushiAI for smarter farming',
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

                        // Full Name Field
                        CustomTextField(
                          hintText: 'Enter your full name',
                          labelText: 'Full Name',
                          prefixIcon: Icons.person_outline,
                          controller: _fullNameController,
                          keyboardType: TextInputType.name,
                        ),

                        const SizedBox(height: 8.0),

                        // Email Field
                        CustomTextField(
                          hintText: 'Enter your email',
                          labelText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 8.0),

                        // Password Field
                        CustomTextField(
                          hintText: 'Enter your password',
                          labelText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          controller: _passwordController,
                        ),

                        const SizedBox(height: 8.0),

                        // Confirm Password Field
                        CustomTextField(
                          hintText: 'Confirm your password',
                          labelText: 'Confirm Password',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          controller: _confirmPasswordController,
                        ),

                        const SizedBox(height: 24.0),

                        // Register Button
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: Color(0xFF4CAF50),
                              )
                            : CustomButton(
                                text: 'Register',
                                onPressed: _handleRegistration,
                                icon: Icons.person_add,
                              ),

                        const SizedBox(height: 24.0),

                        // Login Link
                        GestureDetector(
                          onTap: _navigateToLogin,
                          child: RichText(
                            text: const TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14.0,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Log In',
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

                        SizedBox(height: screenHeight * 0.05),
                      ],
                    ),
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
