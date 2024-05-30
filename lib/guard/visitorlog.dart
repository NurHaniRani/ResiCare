import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resicareapp/databasehelper.dart';
import 'package:resicareapp/guard/guardhomepage.dart';
import 'package:resicareapp/loginpage.dart';
import 'package:resicareapp/models/visitor.dart';
import 'package:intl/intl.dart';
import 'package:resicareapp/models/resident.dart';
import 'package:resicareapp/resident/profilepage.dart';

class VisitorLogPage extends StatefulWidget {
  final int userId;

  VisitorLogPage({required this.userId});

  @override
  _VisitorLogPageState createState() => _VisitorLogPageState();
}


class _VisitorLogPageState extends State<VisitorLogPage> {
  TextEditingController _searchController = TextEditingController();
  List<Visitor> _visitorList = [];
  List<Visitor> _filteredVisitorList = [];

  @override
  void initState() {
    super.initState();
    _loadVisitors();
  }

  Future<void> _loadVisitors() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> visitorMapList = await dbHelper.getVisitorListNonNullValues();
    List<Visitor> visitorList = visitorMapList.map((visitorMap) => Visitor.fromMap(visitorMap)).toList();
    setState(() {
      _visitorList = visitorList;
      _filteredVisitorList = visitorList;
    });
  }

  void _filterVisitors(String keyword) {
    setState(() {
      _filteredVisitorList = _visitorList.where((visitor) {
        // Add conditions for filtering based on visitor attributes (e.g., name, phone number)
        return visitor.name.toLowerCase().contains(keyword.toLowerCase()) ||
            visitor.phoneNumber.toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://e0.pxfuel.com/wallpapers/908/11/desktop-wallpaper-futuristic-building-sky-living-blue-black-minimalist-house-architecture.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 40.0,
            left: 15.0,
            child: Text(
              'Visitor Log',
              style: GoogleFonts.poppins(
                color: const Color.fromARGB(255, 255, 255, 255),
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Positioned(
            top: 120.0,
            left: 20.0,
            right: 20.0,
            child: Container(
              height: 450.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search),
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      ),
                      onChanged: _filterVisitors,
                    ),
                  ),
                  Expanded(
                    child: _buildVisitorList(), // Use the _buildVisitorList method
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Show total visitors
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text(
                            'Total Visitors: ${_visitorList.length}', // Use _visitorList.length
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    'Show Total Visitors',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
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
                  MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.userId)),
                );
              },
              icon: Icon(Icons.person),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () {
                // Navigate to HomePage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GuardHomePage(userId: widget.userId)),
                );
              },
              icon: Icon(Icons.home),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () {
                // Navigate to LoginPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
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

  Future<Resident?> _fetchResident(int residentId) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    // Fetch Resident from the database using residentId
    List<Map<String, dynamic>> residents = await dbHelper.getResidentById(residentId);
    if (residents.isNotEmpty) {
      // Convert the map to a Resident object
      return Resident.fromMap(residents.first);
    }
    return null;
  }

  Widget _buildVisitorList() {
    List<Visitor> visitorsToShow = _filteredVisitorList.isNotEmpty ? _filteredVisitorList : _visitorList;

    if (visitorsToShow.isEmpty) {
      return Center(
        child: Text(
          'No visitors',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    return ListView.builder(
      itemCount: visitorsToShow.length,
      itemBuilder: (context, index) {
        Visitor visitor = visitorsToShow[index];

        // Fetch the corresponding Resident using residentId
        return FutureBuilder<Resident?>(
          future: _fetchResident(visitor.residentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Show loading indicator while fetching data
            }

            Resident? resident = snapshot.data;

            return ListTile(
              title: Text(visitor.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone: ${visitor.phoneNumber}'),
                  Text('Date Arrive: ${visitor.dateArrive}'),
                  Text('Time Arrive: ${visitor.timeArrive}'),
                  Text('Date Depart: ${visitor.dateDepart}'),
                  Text('Time Depart: ${visitor.timeDepart}'),
                  Text('Unit Number: ${resident != null ? resident.unitNumber : 'Not available'}'), // Add unit number
                ],
              ),
            );
          },
        );
      },
    );
  }


}
