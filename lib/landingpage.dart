import 'package:flutter/material.dart';
import 'package:resicareapp/loginpage.dart';
import 'package:resicareapp/registerpage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String? backgroundImageUrl;
  String? iconImageUrl; // URL of the image to be displayed

  @override
  void initState() {
    super.initState();
    downloadImages();
  }

  Future<void> downloadImages() async {
    // Download the background image
    final backgroundImageResponse = await http.get(Uri.parse('https://img.freepik.com/free-vector/minimal-house-exterior-design-mobile-phone-wallpaper_53876-100874.jpg'));

    if (backgroundImageResponse.statusCode == 200) {
      setState(() {
        backgroundImageUrl = 'https://img.freepik.com/free-vector/minimal-house-exterior-design-mobile-phone-wallpaper_53876-100874.jpg';
      });
    } else {
      // Handle error for background image
    }

    // Download the icon image
    final iconImageResponse = await http.get(Uri.parse('https://cdn-icons-png.freepik.com/256/14027/14027068.png'));

    if (iconImageResponse.statusCode == 200) {
      setState(() {
        iconImageUrl = 'https://cdn-icons-png.freepik.com/256/14027/14027068.png';
      });
    } else {
      // Handle error for icon image
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Stack(
        children: [
          Positioned.fill(
            child: backgroundImageUrl != null
                ? Image.network(
              backgroundImageUrl!,
              fit: BoxFit.cover,
            )
                : CircularProgressIndicator(), // Show loading indicator while downloading
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ResiCare',
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 59, 59, 61),
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                  )
                ),
                SizedBox(height: 20.0),
                if (iconImageUrl != null)
                  Image.network(
                    iconImageUrl!,
                    width: 200, // Adjust the width as needed
                    height: 200, // Adjust the height as needed
                    fit: BoxFit.cover,
                  )
                else
                  CircularProgressIndicator(), // Show loading indicator while downloading
                SizedBox(height: 20.0),
                SizedBox(
                  width: 0.7 * MediaQuery.of(context).size.width, // 70% of the screen width
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to login page when the login button is pressed
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white), // Set text color to white
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.lightGreen), // Set button background color to orange
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Set boxed corners
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0), // Add spacing between buttons
                SizedBox(
                  width: 0.7 * MediaQuery.of(context).size.width, // 70% of the screen width
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to register page when the register button is pressed
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(color: Colors.white), // Set text color to white
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.lightGreen), // Set button background color to orange
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Set boxed corners
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
