import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resicareapp/guard/guardprofilepage.dart';
import 'package:resicareapp/landingpage.dart';
import 'package:resicareapp/databasehelper.dart';
import 'package:resicareapp/models/resident.dart';
import 'visitorlog.dart';
import 'visitormanager.dart';

class GuardHomePage extends StatelessWidget {
  final int userId;
  late final Future<Resident> _userFuture;

  GuardHomePage({required this.userId}) {
    _userFuture = DatabaseHelper().getUserById(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://e0.pxfuel.com/wallpapers/908/11/desktop-wallpaper-futuristic-building-sky-living-blue-black-minimalist-house-architecture.jpg',
              fit: BoxFit.fill,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // ResiCare text
                  SizedBox(height: 20.0),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'ResiCare Guard',
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(height: 150.0),
                  // First Row
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavigationBlock(
                        color: Colors.black,
                        icon: Icons.event,
                        label: 'Visitor Manager',
                        onPressed: () {
                          // Navigate to Complaint Form Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => VisitorManagerPage(userId: userId,)),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  // Third Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavigationBlock(
                        color: Colors.black,
                        icon: Icons.book,
                        label: 'Visitor Log',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => VisitorLogPage(userId: userId,)),
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavigationBlock(
                        color: Colors.black,
                        icon: Icons.person,
                        label: 'Profile',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GuardProfilePage(userId: userId)),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 400.0),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 60,
        notchMargin: 5,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                // Navigate to ProfilePage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GuardProfilePage(userId: userId)),
                );
              },
              icon: Icon(Icons.person),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () {
                // Add logic for the middle button
              },
              icon: Icon(Icons.home),
              color: Colors.blue,
            ),
            IconButton(
              onPressed: () {
                // Add logout logic here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LandingPage()),
                );
              },
              icon: Icon(Icons.logout),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBlock({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        width: 250,
        height: 100,
        color: color,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: Colors.white,
                ),
                SizedBox(height: 10.0),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

