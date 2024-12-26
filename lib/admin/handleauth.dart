import 'package:barber_reservation/admin/adminpage.dart';
import 'package:barber_reservation/auth/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HandleAuthPage extends StatefulWidget {
  const HandleAuthPage({super.key});

  @override
  _HandleAuthPageState createState() => _HandleAuthPageState();
}

class _HandleAuthPageState extends State<HandleAuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _user == null ? const LoginPage() : const AdminPage();
  }

 
}