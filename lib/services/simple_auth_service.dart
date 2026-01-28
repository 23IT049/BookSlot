import '../models/user.dart';
import 'firebase_service.dart';

class SimpleAuthService {
  static User? _currentUser;
  
  // Get current user
  static User? get currentUser => _currentUser;

  // Simple sign in with email and password (Firestore only)
  static Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Try to get user from Firestore by email
      User? user = await FirebaseService.getUserByEmail(email);
      
      if (user != null && user.password == password) {
        _currentUser = user;
        return user;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Simple sign up with email and password
  static Future<User?> signUpWithEmailAndPassword(String email, String password, String name, {String? phone}) async {
    try {
      // Check if user already exists
      User? existingUser = await FirebaseService.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('User already exists');
      }

      // Create new user
      User user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        password: password, // Note: In production, hash this password
        phone: phone,
        isAdmin: false,
      );
      
      await FirebaseService.saveUser(user);
      _currentUser = user;
      return user;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    _currentUser = null;
  }

  // Update user profile
  static Future<void> updateProfile(String name, {String? phone}) async {
    try {
      if (_currentUser != null) {
        User updatedUser = _currentUser!.copyWith(name: name, phone: phone);
        await FirebaseService.updateUser(updatedUser);
        _currentUser = updatedUser;
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Check if user is authenticated
  static bool get isAuthenticated => _currentUser != null;

  // Set current user (for persistence)
  static void setCurrentUser(User user) {
    _currentUser = user;
  }
}
