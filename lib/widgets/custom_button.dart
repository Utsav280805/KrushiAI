import 'package:flutter/material.dart';

/// CustomButton - A reusable button widget
///
/// Purpose: Provides consistent button styling across the application
/// with responsive width and customizable properties.
///
/// Benefits:
/// - Consistent visual design
/// - Easy to update button style app-wide
/// - Responsive width using MediaQuery
/// - Flexible and customizable
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive design using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth =
        width ?? screenWidth * 0.9; // 90% of screen width by default

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: buttonWidth,
        height: 56.0, // Standard Material Design button height
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                backgroundColor ?? const Color(0xFF4CAF50), // Green theme
            foregroundColor: textColor ?? Colors.white,
            elevation: 2.0,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20.0),
                const SizedBox(width: 8.0),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
