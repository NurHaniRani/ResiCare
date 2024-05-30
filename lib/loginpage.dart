import 'package:flutter/material.dart';
import 'package:resicareapp/databasehelper.dart';
import 'package:resicareapp/resident/homepage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resicareapp/models/resident.dart';
import 'package:resicareapp/admin/adminhomepage.dart';
import 'package:resicareapp/guard/guardhomepage.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://img.freepik.com/free-vector/minimal-house-exterior-design-mobile-phone-wallpaper_53876-100874.jpg',
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Login',
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 59, 59, 61),
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.lightGreen),
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: Colors.lightGreen),
                    prefixIcon: Icon(Icons.email, color: Colors.lightGreen),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightGreen),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightGreen, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.lightGreen),
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(color: Colors.lightGreen),
                    prefixIcon: Icon(Icons.lock, color: Colors.lightGreen),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightGreen),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightGreen, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    // Get user input from text fields
                    String email = emailController.text;
                    String password = passwordController.text;

                    // Query the database to check if the credentials are valid
                    DatabaseHelper dbHelper = DatabaseHelper();
                    int? userId = await dbHelper.getUserIdByEmail(email, password);
                    if (userId != null) {
                      Resident user = await dbHelper.getUserById(userId);
                      if (user.userType == 'Admin') {
                        // Redirect to AdminHomePage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminHomePage(userId: user.id!),
                          ),
                        );
                      } else if (user.userType == 'Guard') {
                        // Redirect to GuardHomePage for guard users
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuardHomePage(userId: user.id!),
                          ),
                        );
                      } else {
                        // Redirect to HomePage for regular users
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(userId: user.id!),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invalid email or password. Please try again.'),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: Colors.lightGreen,
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
