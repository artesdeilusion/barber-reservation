import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String> signInUserWithEmailPassword(
      String email, String password) async {
    try {
     
      // Email exists, proceed to sign in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // User successfully signed in
        return 'Kullanıcı başarıyla giriş yaptı: ${user.uid}'; // Updated message
      } else {
        return 'Giriş sonrası kullanıcı bilgileri boş.'; // Updated message
      }
    } catch (e) {
      return "Giriş sırasında bir hata oluştu: $e"; // Updated message
    }
  }

  // Check if email is already registered
  Future<bool> isEmailRegistered(String email) async {
    try {
      final List<String> signInMethods =
          await _auth.fetchSignInMethodsForEmail(email);
      return signInMethods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // Create a stream to detect authentication state changes
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future<User?> registerWithEmailAndPassword(
    String phone,
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Send email verification
        await result.user!.sendEmailVerification();

        // Create a document in the "users" collection with the user's UID
        await _createUserDocument(
          result.user!.uid,
          phone,
          email,
        );
      }

      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
    String uid,
    String phone,
    String email,
  ) async {
    try {
      print('Creating user document in Firestore for UID: $uid');
      await FirebaseFirestore.instance.collection('businesses').doc(uid).set({
        'email': email,
        'phone': phone,
        'uid': uid,
        'admin_password': null,
        'places': [],
      });
      print('User document successfully created');
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user document: $e');
      }
      rethrow;
    }
  }
}
