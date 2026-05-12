// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/app_models.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  UserModel? _userData;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  UserRole? get userRole => _userData?.role;
  String get userName =>
      _userData?.nom ?? _user?.email?.split('@')[0] ?? 'Utilisateur';
  String get userEmail => _user?.email ?? '';
  String get userInitials {
    final name = userName;
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  AuthProvider() {
    _init();
  }

  void _init() {
    AuthService.userState.listen((User? user) async {
      _user = user;
      if (user != null) {
        await loadUserData(user.uid);
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  Future<void> loadUserData(String uid) async {
    _userData = await FirestoreService.getUserById(uid);
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await AuthService.signOut();
    _user = null;
    _userData = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
