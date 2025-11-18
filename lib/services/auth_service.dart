import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream para escuchar cambios en el estado de autenticación
  Stream<auth.User?> get authStateChanges => _auth.authStateChanges();

  // Obtener usuario actual
  auth.User? get currentUser => _auth.currentUser;

  // Registro con email y contraseña
  Future<auth.UserCredential> registerWithEmailAndPassword(
      String email, String password, String name) async {
    print('AuthService: Starting register for $email');
    try {
      auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      auth.User? user = result.user;
      print('AuthService: User created: ${user?.email}');

      if (user != null) {
        print('AuthService: Saving to Firestore for ${user.uid}');
        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'name': name,
          'email': email,
          'role': 'buyer',
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('AuthService: Firestore save success');
      }

      return result;
    } catch (e) {
      print('AuthService: Register error: $e');
      rethrow;
    }
  }

  // Login con email y contraseña
  Future<auth.UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Obtener datos del usuario desde Firestore
  Future<User?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return User.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}