import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resicareapp/landingpage.dart';
import 'package:resicareapp/resident/complaintlogpage.dart';
import 'package:resicareapp/resident/familydetailpage.dart';
import 'package:resicareapp/resident/hallreservationpage.dart';
import 'package:resicareapp/loginpage.dart';
import '../resident/profilepage.dart';
import '../databasehelper.dart';
import 'package:resicareapp/models/resident.dart';
import 'package:resicareapp/resident/visitorlogpage.dart';
import 'package:resicareapp/models/news.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatelessWidget {
  final int userId;
  late final Future<Resident> _userFuture;

  HomePage({required this.userId}) {
    _userFuture = DatabaseHelper().getUserById(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://img.freepik.com/free-vector/minimal-house-exterior-design-mobile-phone-wallpaper_53876-100874.jpg',
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
                      'ResiCare',
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 59, 59, 61),
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(height: 50.0),
                  FutureBuilder<List<News>>(
                    future: DatabaseHelper().getLatestNews(),
                    builder: (context, AsyncSnapshot<List<News>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final List<News> newsList = snapshot.data ?? [];
                        return CarouselSlider(
                          items: newsList.map((news) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: Colors.lightGreen,
                                    borderRadius: BorderRadius.circular(10.0), // Curved borders
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0), // Add padding around the text
                                    child: Center(
                                      child: Text(
                                        news.newsText,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                          options: CarouselOptions(
                            height: 200,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            aspectRatio: 16 / 9,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enableInfiniteScroll: true,
                            autoPlayAnimationDuration: Duration(milliseconds: 800),
                            viewportFraction: 0.8,
                          ),
                        );
                      }
                    },
                  ),

                  SizedBox(height: 70.0),
                  // First Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Block 1: Visitor Log Page
                      _buildNavigationBlock(
                        color: Colors.blue,
                        icon: Icons.people,
                        label: 'Visitor Log',
                        onPressed: () {
                          // Navigate to Visitor Log Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => VisitorLogPage(userId: userId)),
                          );
                        },
                      ),
                      // Block 2: Family Details Page
                      _buildNavigationBlock(
                        color: Colors.green,
                        icon: Icons.family_restroom,
                        label: 'Family Details',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FamilyDetailPage(userId: userId)),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  // Second Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Block 3: Hall Reservation Page
                      _buildNavigationBlock(
                        color: Colors.orange,
                        icon: Icons.event,
                        label: 'Hall Reservation',
                        onPressed: () {
                          // Navigate to Hall Reservation Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HallReservationPage(userId: userId)),
                          );
                        },
                      ),
                      // Block 4: Complaint Form Page
                      _buildNavigationBlock(
                        color: Colors.red,
                        icon: Icons.report,
                        label: 'Complaint Form',
                        onPressed: () {
                          // Navigate to Complaint Form Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ComplaintLogPage(userId: userId)),
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
                      // Block 5: Profile Page
                      _buildNavigationBlock(
                        color: Colors.purple,
                        icon: Icons.person,
                        label: 'Profile',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 200.0),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.orange,
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
                    MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)),
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
              color: Colors.black,
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
        width: 150,
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

