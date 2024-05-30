import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resicareapp/admin/reservationmanagerpage.dart';
import 'package:resicareapp/landingpage.dart';
import 'package:resicareapp/admin/adminprofilepage.dart';
import 'package:resicareapp/databasehelper.dart';
import 'package:resicareapp/models/resident.dart';
import 'package:resicareapp/admin/complaintmanagerpage.dart';
import 'package:resicareapp/admin/newsmanagerpage.dart';
import 'package:resicareapp/admin/residentsmanagerpage.dart';
import 'package:carousel_slider/carousel_slider.dart';


class AdminHomePage extends StatelessWidget {
  final int userId;
  late final Future<Resident> _userFuture;

  AdminHomePage({required this.userId}) {
    _userFuture = DatabaseHelper().getUserById(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://static.vecteezy.com/system/resources/previews/021/620/518/original/wall-concrete-with-3d-open-window-against-blue-sky-and-clouds-exterior-rooftop-white-cement-building-ant-view-minimal-modern-architecture-with-summer-sky-backdrop-background-for-spring-summer-vector.jpg',
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
                      'ResiCare Admin',
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 59, 59, 61),
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(height: 80.0),
                  // Carousel Slider for Pending Reservations and Complaints to be Reviewed
                  CarouselSlider(
                    items: [
                      FutureBuilder<int>(
                        future: DatabaseHelper().getPendingReservationsCount(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else {
                            final pendingReservationsCount = snapshot.data ?? 0;
                            return _buildDashboardBlock(
                              color: Colors.pink,
                              icon: Icons.calendar_month,
                              label: 'Reservations Pending',
                              value: pendingReservationsCount.toString(),
                            );
                          }
                        },
                      ),
                      FutureBuilder<int>(
                        future: DatabaseHelper().getComplaintsToBeReviewedCount(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else {
                            final complaintsToBeReviewedCount = snapshot.data ?? 0;
                            return _buildDashboardBlock(
                              color: Colors.pink,
                              icon: Icons.warning,
                              label: 'Complaints To Be Reviewed',
                              value: complaintsToBeReviewedCount.toString(),
                            );
                          }
                        },
                      ),
                    ],
                    options: CarouselOptions(
                      height: 150,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      viewportFraction: 0.8,
                    ),
                  ),
                  SizedBox(height: 90.0),
                  // Rest of the content
                  // First Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Block 1: Visitor Log Page
                      _buildNavigationBlock(
                        color: Colors.blue,
                        icon: Icons.newspaper,
                        label: 'News Manager',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NewsManagerPage(userId: userId,)),
                          );
                        },
                      ),
                      // Block 2: Family Details Page
                      _buildNavigationBlock(
                        color: Colors.green,
                        icon: Icons.family_restroom,
                        label: 'Residents Log',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ResidentsManagerPage(userId: userId,)),
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
                        label: 'Reservations',
                        onPressed: () {
                          // Navigate to Hall Reservation Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ReservationManagerPage(userId: userId,)),
                          );
                        },
                      ),
                      // Block 4: Complaint Form Page
                      _buildNavigationBlock(
                        color: Colors.red,
                        icon: Icons.report,
                        label: 'Complaints',
                        onPressed: () {
                          // Navigate to Complaint Form Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ComplaintManagerPage(userId: userId,)),
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
                            MaterialPageRoute(builder: (context) => AdminProfilePage(userId: userId)),
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
        color: Colors.blue[200],
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
                  MaterialPageRoute(builder: (context) => AdminProfilePage(userId: userId)),
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

  Widget _buildDashboardBlock({
    required Color color,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        width: 400,
        height: 200,
        color: color,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Add navigation logic if needed
            },
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
                SizedBox(height: 5.0),
                Text(
                  value,
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

