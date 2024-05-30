import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resicareapp/databasehelper.dart';
import 'package:resicareapp/guard/guardhomepage.dart';
import 'package:resicareapp/guard/guardprofilepage.dart';
import 'package:resicareapp/loginpage.dart';
import 'package:resicareapp/models/visitor.dart';
import 'package:intl/intl.dart';
import 'package:resicareapp/models/resident.dart';

class VisitorManagerPage extends StatefulWidget {
  final int userId;

  VisitorManagerPage({required this.userId});

  @override
  _VisitorManagerPageState createState() => _VisitorManagerPageState();
}

class _VisitorManagerPageState extends State<VisitorManagerPage> {
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
    List<Map<String, dynamic>> visitorsData = await dbHelper.getVisitorList();
    List<Visitor> visitorList = visitorsData.map((visitorData) => Visitor.fromMap(visitorData)).toList();
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

  Future<bool> _showConfirmationDialog(String message) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Confirm'),
            ),
          ],
        );
      },
    ) ?? false;
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
              'Visitor Manager',
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
                    'Total Visitors For Arrival',
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
                  MaterialPageRoute(builder: (context) => GuardProfilePage(userId: widget.userId)),
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

            // Convert dateArrive from String to DateTime
            DateTime? dateArrive = visitor.dateArrive != null ? DateTime.parse(visitor.dateArrive!) : null;
            DateTime? dateDepart = visitor.dateDepart != null ? DateTime.parse(visitor.dateDepart!) : null;
            bool isArrived = visitor.timeArrive != null && dateArrive != null;
            bool isDeparted = visitor.dateDepart != null && visitor.timeDepart != null && dateDepart != null;

            return ListTile(
              title: Text(visitor.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone: ${visitor.phoneNumber}'),
                  Text('Date Arrive: ${dateArrive != null ? DateFormat('yyyy-MM-dd').format(dateArrive) : 'Not available'}'),
                  Text('Unit Number: ${resident != null ? resident.unitNumber : 'Not available'}'), // Add unitNumber
                ],
              ),
              trailing: IconButton(
                icon: isArrived && !isDeparted ? Icon(Icons.exit_to_app) : Icon(Icons.access_time), // Change icon based on conditions
                onPressed: () {
                  if (isArrived && !isDeparted) {
                    _confirmAddDepartureTime(visitor);
                  } else {
                    _confirmAddArrivalTime(visitor);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  void _confirmAddDepartureTime(Visitor visitor) async {
    bool confirm = await _showConfirmationDialog('Do you want to add departure time for ${visitor.name}?');
    if (confirm) {
      _addDepartureTime(visitor);
    }
  }

  void _confirmAddArrivalTime(Visitor visitor) async {
    bool confirm = await _showConfirmationDialog('Do you want to add arrival time for ${visitor.name}?');
    if (confirm) {
      _addArrivalTime(visitor);
    }
  }

  void _addDepartureTime(Visitor visitor) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    DateTime now = DateTime.now();
    String departureTime = DateFormat('HH:mm').format(now);
    String departureDate = DateFormat('yyyy-MM-dd').format(now);
    visitor.dateDepart = departureDate;
    visitor.timeDepart = departureTime;
    await dbHelper.updateVisitor(visitor);
    setState(() {
      _loadVisitors();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${visitor.name} departed at $departureTime'),
      ),
    );
  }

  void _addArrivalTime(Visitor visitor) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    DateTime now = DateTime.now();
    String arrivalTime = DateFormat('HH:mm').format(now);
    visitor.timeArrive = arrivalTime;
    await dbHelper.updateVisitor(visitor);
    setState(() {
      _loadVisitors();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${visitor.name} arrived at $arrivalTime'),
      ),
    );
  }
}


