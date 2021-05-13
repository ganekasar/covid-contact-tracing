import 'file:///D:/AppsFromFlutter/covid-contact-tracing/lib/screens/login.dart';
import 'file:///D:/AppsFromFlutter/covid-contact-tracing/lib/screens/nearby_interface.dart';
import 'file:///D:/AppsFromFlutter/covid-contact-tracing/lib/screens/registration.dart';
import 'file:///D:/AppsFromFlutter/covid-contact-tracing/lib/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        NearbyInterface.id: (context) => NearbyInterface(),
      },
    );
  }
}
