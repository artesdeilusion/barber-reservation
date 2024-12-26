import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordResetDialog extends StatefulWidget {
  const PasswordResetDialog({super.key});

  @override
  _PasswordResetDialogState createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> resetPassword() async {
    final String email = emailController.text.trim();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      Navigator.of(context).pop(); // Close the dialog
      // Show a success message or navigate to another page.
    } catch (e) {
      // Handle password reset email sending errors
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Şifremi Unuttum'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email Adresi',
              labelStyle: TextStyle(),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Vazgeç'),
        ),
        ElevatedButton(
          onPressed: resetPassword,
          child: const Text('Sıfırlama E-postası Gönder'),
        ),
      ],
    );
  }
}
