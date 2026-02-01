import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// AuthService - Firebase Authentication Service
///
/// Purpose: Handles all Firebase authentication operations
/// Implements: Registration, Login, Logout, Session Management, Google Sign-In
/// Pattern: Singleton pattern for single instance across app

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // SharedPreferences keys
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserName = 'userName';

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Register new user with email and password
  ///
  /// Returns: Success message or throws exception with error
  Future<String> registerUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    print('📝 [AUTH] Starting registration for: $email');
    try {
      print('🔥 [AUTH] Creating user with Firebase...');
      // Create user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      print('✅ [AUTH] User created successfully: ${userCredential.user?.uid}');
      
      // Update display name
      print('👤 [AUTH] Updating display name to: $fullName');
      await userCredential.user?.updateDisplayName(fullName);
      await userCredential.user?.reload();
      print('✅ [AUTH] Display name updated');

      // Save session
      print('💾 [AUTH] Saving session...');
      await _saveSession(email, fullName);
      print('✅ [AUTH] Session saved successfully');

      return 'Registration successful!';
    } on FirebaseAuthException catch (e) {
      print('❌ [AUTH] Firebase error during registration: ${e.code} - ${e.message}');
      // Handle Firebase-specific errors
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ [AUTH] Unexpected error during registration: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Login user with email and password
  ///
  /// Returns: Success message or throws exception with error
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    print('🔐 [AUTH] Starting login for: $email');
    try {
      // Sign in with email and password
      print('🔥 [AUTH] Signing in with Firebase...');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('✅ [AUTH] Login successful for user: ${userCredential.user?.uid}');
      print('👤 [AUTH] User name: ${userCredential.user?.displayName ?? "No name set"}');
      
      // Save session
      print('💾 [AUTH] Saving session...');
      await _saveSession(email, userCredential.user?.displayName);
      print('✅ [AUTH] Session saved successfully');

      return 'Login successful!';
    } on FirebaseAuthException catch (e) {
      print('❌ [AUTH] Firebase error during login: ${e.code} - ${e.message}');
      // Handle Firebase-specific errors
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ [AUTH] Unexpected error during login: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Sign in with Google
  ///
  /// Returns: Success message or throws exception with error
  Future<String> signInWithGoogle() async {
    print('🔐 [GOOGLE] Starting Google Sign-In...');
    try {
      // Trigger the authentication flow
      print('🔥 [GOOGLE] Showing Google account picker...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('⚠️ [GOOGLE] User cancelled Google Sign-In');
        throw 'Google Sign-In was cancelled';
      }

      print('✅ [GOOGLE] Google account selected: ${googleUser.email}');

      // Obtain the auth details from the request
      print('🔥 [GOOGLE] Getting authentication details...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('✅ [GOOGLE] Authentication details obtained');

      // Create a new credential
      print('🔥 [GOOGLE] Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('✅ [GOOGLE] Firebase credential created');

      // Sign in to Firebase with the Google credential
      print('🔥 [GOOGLE] Signing in to Firebase...');
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      print('✅ [GOOGLE] Firebase sign-in successful');
      print('👤 [GOOGLE] User: ${userCredential.user?.displayName ?? "No name"}');
      print('📧 [GOOGLE] Email: ${userCredential.user?.email ?? "No email"}');

      // Save session
      print('💾 [GOOGLE] Saving session...');
      await _saveSession(
        userCredential.user?.email ?? '',
        userCredential.user?.displayName,
      );
      print('✅ [GOOGLE] Session saved successfully');

      return 'Google Sign-In successful!';
    } on FirebaseAuthException catch (e) {
      print('❌ [GOOGLE] Firebase error during Google Sign-In: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ [GOOGLE] Unexpected error during Google Sign-In: $e');
      throw 'Google Sign-In failed: $e';
    }
  }

  /// Logout current user
  ///
  /// Returns: Success message or throws exception with error
  Future<String> logoutUser() async {
    print('🚪 [AUTH] Starting logout...');
    try {
      print('🔥 [AUTH] Signing out from Firebase...');
      await _auth.signOut();
      print('✅ [AUTH] Firebase sign out successful');
      
      // Also sign out from Google if user was signed in with Google
      print('🔥 [AUTH] Signing out from Google...');
      await _googleSignIn.signOut();
      print('✅ [AUTH] Google sign out successful');
      
      print('💾 [AUTH] Clearing session...');
      await _clearSession();
      print('✅ [AUTH] Session cleared successfully');
      
      return 'Logged out successfully!';
    } catch (e) {
      print('❌ [AUTH] Error during logout: $e');
      throw 'Failed to logout. Please try again.';
    }
  }

  /// Check if user session exists (for auto-login)
  ///
  /// Returns: true if user was previously logged in
  Future<bool> checkSession() async {
    print('🔍 [AUTH] Checking session...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      final hasCurrentUser = _auth.currentUser != null;
      
      print('💾 [AUTH] Session stored: $isLoggedIn');
      print('👤 [AUTH] Current user exists: $hasCurrentUser');
      
      if (hasCurrentUser) {
        print('👤 [AUTH] Current user: ${_auth.currentUser?.email}');
      }
      
      return isLoggedIn && hasCurrentUser;
    } catch (e) {
      print('❌ [AUTH] Error checking session: $e');
      return false;
    }
  }

  /// Get stored user email from session
  Future<String?> getStoredEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserEmail);
    } catch (e) {
      return null;
    }
  }

  /// Get stored user name from session or Firebase
  Future<String?> getUserName() async {
    try {
      // First try to get from current user
      if (_auth.currentUser?.displayName != null) {
        print('👤 [AUTH] Got user name from Firebase: ${_auth.currentUser!.displayName}');
        return _auth.currentUser!.displayName;
      }
      
      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_keyUserName);
      print('👤 [AUTH] Got user name from SharedPreferences: $name');
      return name;
    } catch (e) {
      print('❌ [AUTH] Error getting user name: $e');
      return null;
    }
  }

  /// Save user session to SharedPreferences
  Future<void> _saveSession(String email, [String? userName]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserEmail, email);
      if (userName != null) {
        await prefs.setString(_keyUserName, userName);
        print('💾 [AUTH] Saved user name: $userName');
      }
      print('💾 [AUTH] Session saved: $email');
    } catch (e) {
      print('❌ [AUTH] Error saving session: $e');
      // Session save failed, but authentication succeeded
      // User can still use the app
    }
  }

  /// Clear user session from SharedPreferences
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyUserName);
      print('💾 [AUTH] All session data cleared');
    } catch (e) {
      print('❌ [AUTH] Error clearing session: $e');
      // Session clear failed, but sign out succeeded
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    print('🔍 [AUTH] Handling exception code: ${e.code}');
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled in Firebase Console.';
      default:
        return 'Authentication failed: ${e.message ?? 'Unknown error'}';
    }
  }

  /// Send password reset email
  Future<String> sendPasswordResetEmail(String email) async {
    print('📧 [AUTH] Sending password reset email to: $email');
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      print('✅ [AUTH] Password reset email sent');
      return 'Password reset email sent. Please check your inbox.';
    } on FirebaseAuthException catch (e) {
      print('❌ [AUTH] Error sending reset email: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ [AUTH] Unexpected error sending reset email: $e');
      throw 'Failed to send reset email. Please try again.';
    }
  }
}
