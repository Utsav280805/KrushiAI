import 'package:flutter/material.dart';
import 'package:krushi_ai/widgets/feature_card.dart';
import 'package:krushi_ai/services/auth_service.dart';
import 'package:krushi_ai/screens/history/history_screen.dart';
import 'package:krushi_ai/screens/test_data_collection_screen.dart';

/// Dashboard/Home Screen - LAB 4 Implementation
///
/// Demonstrates:
/// - Scaffold widget for screen structure
/// - AppBar for top navigation
/// - Column and Row layouts
/// - Card widgets (via FeatureCard)
/// - GridView for responsive card layout
/// - Icon widgets
/// - FloatingActionButton
/// - MediaQuery for responsive design
/// - Expanded/Flexible for adaptive sizing
/// - SafeArea for device-safe rendering
/// - FutureBuilder for async data display
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  String _userName = 'Farmer';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    print('👤 [DASHBOARD] Loading user name...');
    final userName = await _authService.getUserName();
    print('👤 [DASHBOARD] User name received: $userName');
    if (userName != null && userName.isNotEmpty) {
      setState(() {
        _userName = userName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive design using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine grid columns based on screen width
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      // AppBar with title
      appBar: AppBar(
        title: const Text(
          'Krushi AI',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Notification icon
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Notifications')));
            },
          ),
          // Logout icon
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
          // Profile icon
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: const Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),

      // Main body content
      body: SafeArea(
        child: Column(
          children: [
            // Header Section with gradient background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.0),
                  bottomRight: Radius.circular(32.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome text with user's name
                  Text(
                    'Hello, $_userName',
                    style: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'How are your crops today?',
                    style: TextStyle(fontSize: 16.0, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),

            // Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16.0),

            // Feature Cards Grid (using GridView for responsive layout)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                  children: [
                    // Crop Info Card
                    FeatureCard(
                      title: 'Crop Info',
                      subtitle: 'Learn more',
                      icon: Icons.grass,
                      backgroundColor: const Color(0xFF4CAF50),
                      onTap: () {
                        _showFeatureMessage(context, 'Crop Info');
                      },
                    ),

                    // Weather Card
                    FeatureCard(
                      title: 'Weather',
                      subtitle: 'Forecast',
                      icon: Icons.wb_sunny,
                      backgroundColor: const Color(0xFF2196F3),
                      onTap: () {
                        _showFeatureMessage(context, 'Weather');
                      },
                    ),

                    // Soil Health Card
                    FeatureCard(
                      title: 'Soil Health',
                      subtitle: 'Analysis',
                      icon: Icons.terrain,
                      backgroundColor: const Color(0xFF795548),
                      onTap: () {
                        _showFeatureMessage(context, 'Soil Health');
                      },
                    ),

                    // Disease Detection Card - Now opens Data Collection
                    FeatureCard(
                      title: 'Test Database',
                      subtitle: 'Add Prediction',
                      icon: Icons.add_circle,
                      backgroundColor: const Color(0xFFFF9800),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TestDataCollectionScreen(),
                          ),
                        );
                      },
                    ),

                    // Market Prices Card
                    FeatureCard(
                      title: 'Market Price',
                      subtitle: 'Live rates',
                      icon: Icons.trending_up,
                      backgroundColor: const Color(0xFF9C27B0),
                      onTap: () {
                        _showFeatureMessage(context, 'Market Price');
                      },
                    ),

                    // Expert Advice Card
                    FeatureCard(
                      title: 'Expert Help',
                      subtitle: 'Consult now',
                      icon: Icons.support_agent,
                      backgroundColor: const Color(0xFFF44336),
                      onTap: () {
                        _showFeatureMessage(context, 'Expert Help');
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16.0),
          ],
        ),
      ),

      // FloatingActionButton for quick actions
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showFeatureMessage(context, 'Capture Leaf');
        },
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.camera_alt),
        label: const Text(
          'Scan Crop',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // Bottom Navigation Bar (optional enhancement)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Scan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 1) {
            // Navigate to History Screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Navigating to tab $index'),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
      ),
    );
  }

  /// Handle logout functionality
  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        // Logout user
        final authService = AuthService();
        await authService.logoutUser();

        // Navigate to login screen
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  /// Helper method to show feature messages
  void _showFeatureMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature clicked'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
