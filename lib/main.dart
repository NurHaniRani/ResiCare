import 'package:flutter/material.dart';
import 'package:resicareapp/landingpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingPage(), // Set the home property to your LoginPage widget
    );
  }
}

