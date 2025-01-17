import 'package:flutter/material.dart';
import 'homepage.dart';
import 'view_packages.dart';
import 'Authentication/login.dart';

void main() {
  runApp(BeautySalonApp());
}

class BeautySalonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Salon Beauty Booking',
      theme: ThemeData(
        primarySwatch: Colors.pink, // Define the app's color theme
      ),
      initialRoute: '/', // Start at the homepage
      routes: {
        '/': (context) => HomePage(), // Homepage with logo and buttons
        '/viewPackages': (context) => ViewPackagesPage(), // View Packages Page
        '/login': (context) => LoginScreen(), // Login Page
      },
    );
  }
}
