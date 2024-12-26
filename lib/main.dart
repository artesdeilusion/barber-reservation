import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_reservation/auth/authservice.dart';
import 'package:barber_reservation/homepage.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart'; // For determining locale
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

   
  
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  final String systemLocale = await findSystemLocale();
  Intl.defaultLocale = systemLocale; // Or set to 'tr' for Turkish by default

  // Set the local time zone to a specific location
  final detroit = tz.getLocation('America/Detroit');
  tz.setLocalLocation(detroit);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class RootPage extends StatelessWidget {
  final AuthService _auth = AuthService();

  RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.user,
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        User? user = snapshot.data;
        // If no user is logged in, show the LoginPage
        if (user == null) {
          return const HomePage();
        } else {
             return const HomePage(); 
        }
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        SfGlobalLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'),
        
      ],
      locale: const Locale('tr_TR'),

      debugShowCheckedModeBanner: false,
      title: 'Salon Adliye | Randevu',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.brown),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
          )
        ),
        textTheme: GoogleFonts.manropeTextTheme(),
       ),
      home: RootPage(),
    );
  }
}
