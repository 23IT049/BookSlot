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

  // Demo login for testing
  static Future<User?> demoLogin(String email, String password) async {
    try {
      if (email == 'admin@bookslot.com' && password == 'admin123') {
        User admin = User(
          id: 'admin_1',
          name: 'Admin User',
          email: email,
          password: password,
          isAdmin: true,
        );
        
        // Save admin to Firestore if not exists
        User? existingAdmin = await FirebaseService.getUserByEmail(email);
        if (existingAdmin == null) {
          await FirebaseService.saveUser(admin);
        }
        
        _currentUser = admin;
        return admin;
      } else if (email == 'user@bookslot.com' && password == 'user123') {
        User user = User(
          id: 'user_1',
          name: 'Test User',
          email: email,
          password: password,
          isAdmin: false,
        );
        
        // Save user to Firestore if not exists
        User? existingUser = await FirebaseService.getUserByEmail(email);
        if (existingUser == null) {
          await FirebaseService.saveUser(user);
        }
        
        _currentUser = user;
        return user;
      }
      
      // Try regular login
      return await signInWithEmailAndPassword(email, password);
    } catch (e) {
      throw Exception('Demo login failed: $e');
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
