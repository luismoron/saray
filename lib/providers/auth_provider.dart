import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  auth.User? _firebaseUser;
  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;

  auth.User? get firebaseUser => _firebaseUser;
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    print('AuthProvider constructor called');
    _init();
  }

  void _init() {
    print('AuthProvider _init called');
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(auth.User? firebaseUser) async {
    print('AuthStateChanged called with user: ${firebaseUser?.email}');
    _firebaseUser = firebaseUser;
    if (firebaseUser != null) {
      _user = await _authService.getUserData(firebaseUser.uid);
    } else {
      _user = null;
    }
    _isInitialized = true;
    print('AuthProvider initialized: $_isInitialized');
    notifyListeners();
  }

  Future<void> register(String email, String password, String name) async {
    print('Register started for $email');
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.registerWithEmailAndPassword(email, password, name);
      print('Register success for $email');
    } catch (e) {
      print('Register error: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  // Método temporal para asignar rol admin (desarrollo)
  // TODO: Remover después de asignar admin inicial
  Future<bool> assignAdminRole() async {
    if (user == null) return false;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.id)
          .update({'role': 'admin'});

      // Actualizar usuario local
      final updatedUser = user!.copyWith(role: 'admin');
      _user = updatedUser;
      notifyListeners();

      return true;
    } catch (e) {
      print('Error assigning admin role: $e');
      return false;
    }
  }
}