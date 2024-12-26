// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:barber_reservation/artesdeilusion/blackbox.dart';
import 'package:flutter/material.dart';
import 'package:barber_reservation/auth/authservice.dart';
import 'package:barber_reservation/auth/resetpassword.dart';
 import 'dart:html' as html;


const String kGoogleApiKey = 'AIzaSyC8KdjLpiXhk0eCqFr5vfectbTwzhDM9ZE';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  bool showPassword = true;

  
 
 
Future<void> _openEmail({
  required String email,
  required String subject,
  required String body,
}) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
  );

  try {
    html.window.open(emailUri.toString(), '_self'); // Opens the email client
  } catch (e) {
    throw 'Could not launch $emailUri: $e';
  }
}

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.miniStartDocked,
      floatingActionButton:BlackBox(),
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: isMobile
              ? Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5))
              : null,
          color: Colors.white,
        ),
        height: kBottomNavigationBarHeight,
        child: ButtonBar(
          alignment: MainAxisAlignment.end,
          children: [
              // Destek Button - Opens Help Page URL
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Geri Dön"),
            ),
            // Destek Button - Opens Help Page URL
            TextButton(
              onPressed: () {
  _openEmail(
    email: 'info@artesdeilusion.com',
    subject: 'Salon Adliye | Project 00007',
    body: 'Lütfen gerekli detayları belirtiniz.',
  );},
              child: const Text("Destek"),
            ),
          ],
        ),
      ),
       body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 800) {
            // Desktop & Tablet layout
            return Row(
              children: _buildUI(context),
            );
          } else {
            // Mobile layout
            return SingleChildScrollView(
              // Scrollable for mobile view
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildUIMobile(context),
              ),
            );
          }
        },
      ),
    );
  }

  List<Widget> _buildUI(BuildContext context) {
    return [
      Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.brown,
           child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25),
                          bottom:  
                            Radius.circular(25)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(top: 20, bottom: 0),
                    child: Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width * 0.4,
                        padding: const EdgeInsets.only(
                            left: 40, right: 40, top: 30, bottom: 20),
                        child:   _loginForm(context)
)),
              ),
            ],
          )),
    ];
  }

  List<Widget> _buildUIMobile(BuildContext context) {
    return [
      Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 10),
              child:  _loginForm(context)),
        ),
      )
    ];
  }

  Widget _loginForm(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Salon Adliye | Yönetici Girişi", style: TextStyle(
                  fontSize: 25,
                )),
            Divider(
              color: Colors.grey.shade300,
              height: 30,
            ),
            
             TextFormField(
              onChanged: (val) {
                setState(() => email = val);
              },
              validator: (val) => val!.isEmpty ? 'Email giriniz' : null,
              decoration: InputDecoration(
                labelText: 'Email Adresi',
                labelStyle: const TextStyle(),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              obscureText: showPassword,
              onChanged: (val) {
                setState(() => password = val);
              },
              validator: (val) => val!.length < 8
                  ? 'Şifre 8 karakterden uzun olmalıdır.'
                  : null,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: Icon(showPassword
                        ? Icons.visibility_off
                        : Icons.visibility)),
                labelText: 'Şifre',
                labelStyle: const TextStyle(),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            TextButton(
              style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.all(5))),
              child: const Text("Şifreni mi unuttun?"),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const PasswordResetDialog();
                  },
                );
              },
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: isMobile
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
              children: [
                
                const SizedBox(width: 10),
                ElevatedButton(
                 
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        error = ''; // Clear previous errors
                      });

                      // Await the result of the sign-in function
                      String resultMessage = await _auth
                          .signInUserWithEmailPassword(email, password);

                      // Set the error or success message accordingly
                      if (resultMessage.contains('başarıyla giriş yaptı')) {
                        // Sign-in was successful, optionally navigate to the next page
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                        setState(() {
                          error =
                              resultMessage; // Optionally set this for display or logging
                        });
                      } else {
                        // Sign-in failed, update the error message
                        setState(() {
                          error =
                              resultMessage; // Show the error message from sign-in
                        });
                      }
                    } else {
                      // Handle the case where form validation fails
                      setState(() {
                        error =
                            'Lütfen tüm alanları doğru bir şekilde doldurduğunuzdan emin olun.';
                      });
                    }
                  },
                  child: const Text("Giriş Yap"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
 }
