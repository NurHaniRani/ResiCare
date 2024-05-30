import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resicareapp/loginpage.dart';
import 'package:resicareapp/resident/profilepage.dart';
import 'package:resicareapp/resident/homepage.dart';
import 'package:resicareapp/databasehelper.dart';
import 'package:resicareapp/models/hall.dart';
import 'package:resicareapp/models/reserve.dart';
import 'package:intl/intl.dart';

class HallReservationPage extends StatefulWidget {
  final int userId;

  HallReservationPage({required this.userId});

  @override
  _HallReservationPageState createState() => _HallReservationPageState();
}

class _HallReservationPageState extends State<HallReservationPage> {
  late List<Hall> _halls = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHalls();
    _filteredHalls = [];
  }

  Future<void> _loadHalls() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Hall> halls = await dbHelper.getAvailableHalls(); // Implement getHalls() in your database helper class
    setState(() {
      _halls = halls;
    });
  }

  List<Hall> _filteredHalls = [];

  void _searchHall(String keyword) {
    setState(() {
      _filteredHalls = _halls.where((hall) {
        return hall.name.toLowerCase().contains(keyword.toLowerCase());
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
              'https://img.freepik.com/free-vector/minimal-house-exterior-design-mobile-phone-wallpaper_53876-100874.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 40.0,
            left: 15.0,
            child: Text(
              'Hall Reservation',
              style: GoogleFonts.poppins(
                color: const Color.fromARGB(255, 59, 59, 61),
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
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Hall',
                        prefixIcon: Icon(Icons.search),
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      ),
                      onChanged: _searchHall,
                    ),
                  ),
                  Expanded(child: _buildHallList()),
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
                    // Add functionality to show total halls
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text(
                            'Total Halls: ${_halls.length}',
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
                    'Show Total Halls',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _showReservationsDialog(context);
                  },
                  child: Text(
                    'View Reservations',
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(userId: widget.userId)),
                );
              },
              icon: Icon(Icons.home),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () {
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


  Widget _buildHallList() {
    List<Hall> hallsToShow = _filteredHalls.isNotEmpty ? _filteredHalls : _halls;

    if (hallsToShow.isEmpty) {
      return Center(
        child: Text(
          'No Halls Available',
          style: GoogleFonts.poppins(),
        ),
      );
    }

    return SingleChildScrollView(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: hallsToShow.length,
        itemBuilder: (context, index) {
          Hall hall = hallsToShow[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                title: Text(
                  hall.name,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // Implement reserve functionality
                    _reserveHall(context, hall);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _reserveHall(BuildContext context, Hall hall) {
    DateTime selectedDate = DateTime.now(); // Initialize selected date with current date
    String reason = '';
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reserve Hall'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text('Date:'),
                        trailing: TextButton(
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 1),
                            );
                            if (pickedDate != null && pickedDate != selectedDate) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          child: Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Reason for reservation',
                            labelText: 'Reason',
                          ),
                          onChanged: (value) {
                            reason = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a reason for the reservation';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    // Check if the hall is available on the selected date
                    DatabaseHelper dbHelper = DatabaseHelper();
                    bool isAvailable = await dbHelper.isHallAvailable(hall.id!, selectedDate.toIso8601String());

                    if (isAvailable) {
                      // Insert the reservation into the database
                      Reserve newReserve = Reserve(
                        hallId: hall.id!,
                        ownerId: widget.userId,
                        dateReserved: selectedDate.toIso8601String(),
                        reason: reason,
                        status: 'Pending',
                      );
                      await dbHelper.insertReservation(newReserve);
                      Navigator.of(context).pop(); // Close the dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reservation made successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hall is not available on the selected date'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    print('Error reserving hall: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error reserving hall'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text('Reserve'),
            ),
          ],
        );
      },
    );
  }

  void _showReservationsDialog(BuildContext context) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> reservations = await dbHelper.getReservationsForUser(widget.userId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('My Reservations'),
          content: Container(
            width: double.maxFinite,
            child: reservations.isEmpty
                ? Center(
              child: Text(
                'No Reservations Found',
                style: GoogleFonts.poppins(),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                var reservation = reservations[index];
                DateTime parsedDate = DateTime.parse(reservation['dateReserved']);
                String formattedDate = '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
                String status = reservation['status'];

                return ListTile(
                  title: Text(
                    '${reservation['hallName']}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: $formattedDate'),
                      Text('Reason: ${reservation['reason']}'),
                      Text('Status: $status'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: (status == "Reserved" || status == "Rejected")
                            ? null
                            : () {
                          _deleteReservation(context, reservation['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _deleteReservation(BuildContext context, int reservationId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this reservation?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Do not delete
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm delete
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.deleteReservation(reservationId);
      Navigator.of(context).pop(); // Close the dialog
      _showReservationsDialog(context); // Refresh the reservations list
    }
  }


}
