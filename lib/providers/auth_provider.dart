import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/simple_auth_service.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    loadUserFromPrefs();
  }

  Future<void> loadUserFromPrefs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('currentUser');

      if (userJson != null) {
        _currentUser = User.fromJson(json.decode(userJson));
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserToPrefs(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUser', json.encode(user.toJson()));
    } catch (e) {
      _errorMessage = 'Failed to save user data';
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      User? user = await SimpleAuthService.signInWithEmailAndPassword(email, password);

      if (user != null) {
        _currentUser = user;
        SimpleAuthService.setCurrentUser(user);
        await _saveUserToPrefs(user);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, {String? phone}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      User? user = await SimpleAuthService.signUpWithEmailAndPassword(email, password, name, phone: phone);

      if (user != null) {
        _currentUser = user;
        SimpleAuthService.setCurrentUser(user);
        await _saveUserToPrefs(user);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await SimpleAuthService.signOut();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUser');
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Logout failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(String name, {String? phone}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser != null) {
        User updatedUser = _currentUser!.copyWith(name: name, phone: phone);
        
        await SimpleAuthService.updateProfile(name, phone: phone);
        await FirebaseService.updateUser(updatedUser);
        
        _currentUser = updatedUser;
        SimpleAuthService.setCurrentUser(updatedUser);
        await _saveUserToPrefs(updatedUser);
      }
    } catch (e) {
      _errorMessage = 'Failed to update profile';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
