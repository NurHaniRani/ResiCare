import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resicareapp/admin/adminprofilepage.dart';
import 'package:resicareapp/admin/adminhomepage.dart';
import 'package:resicareapp/databasehelper.dart';
import 'package:resicareapp/models/hall.dart';
import 'package:resicareapp/loginpage.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:resicareapp/models/reserve.dart';


class ReservationManagerPage extends StatefulWidget {
  final int userId;

  ReservationManagerPage({required this.userId});

  @override
  _ReservationManagerPageState createState() => _ReservationManagerPageState();
}

class _ReservationManagerPageState extends State<ReservationManagerPage> {
  List<Hall> _halls = [];
  List<double> reservationCounts = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHalls();
    _filteredHalls = [];
  }

  Future<void> _loadHalls() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Hall> halls = await dbHelper.getHalls(); // Implement getHalls() in your database helper class
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

  final _formKey = GlobalKey<FormState>();

  void _addNewHall() async {
    String name = '';
    String status = 'Available'; // Default value for status

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Hall'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(hintText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    name = value;
                  },
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: InputDecoration(hintText: 'Status'),
                  items: ['Available', 'Unavailable'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    status = newValue!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Form is validated
                  DatabaseHelper dbHelper = DatabaseHelper();
                  Hall newHall = Hall(name: name, status: status);
                  await dbHelper.insertHall(newHall);
                  await _loadHalls(); // Reload the halls list to reflect the changes
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('New hall added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://static.vecteezy.com/system/resources/previews/021/620/518/original/wall-concrete-with-3d-open-window-against-blue-sky-and-clouds-exterior-rooftop-white-cement-building-ant-view-minimal-modern-architecture-with-summer-sky-backdrop-background-for-spring-summer-vector.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 40.0,
            left: 15.0,
            child: Text(
              'Reservation Manager',
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
              height: 470.0,
              decoration: BoxDecoration(
                color: Colors.purple[200],
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
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[200]!),
                  ),
                  onPressed: () {
                    showReservationChart(context);
                  },
                  child: Text(
                    'Show Reservations by Halls',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),


                SizedBox(height: 10), // Add some space between the buttons
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.pink[200]!),
                  ),
                  onPressed: _addNewHall,
                  child: Text(
                    'Add New Hall',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminProfilePage(userId: widget.userId)),
                );
              },
              icon: Icon(Icons.person),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminHomePage(userId: widget.userId)),
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
                color: Colors.purple[200],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                title: Text(
                  hall.name,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Implement edit functionality
                        _editHall(hall);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.book),
                      onPressed: () {
                        //Implement reservation history
                        _showReservationHistory(context, hall);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_month),
                      onPressed: () {
                        // Implement reserve functionality
                        _viewReservationsForHall(context, hall);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _editHall(Hall hall) async {
    String editedName = hall.name;
    String editedStatus = hall.status;

    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Hall'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(hintText: 'Name', labelText: 'Name'),
                  initialValue: hall.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    editedName = value;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: editedStatus,
                  items: ['Available', 'Unavailable'].map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      editedStatus = value;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Status',
                  ),
                ),
              ],
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
                    DatabaseHelper dbHelper = DatabaseHelper();
                    Hall updatedHall = Hall(id: hall.id, name: editedName, status: editedStatus);
                    await dbHelper.updateHall(updatedHall);
                    await _loadHalls(); // Reload the halls list to reflect the changes
                    Navigator.of(context).pop(); // Close the dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${hall.name} updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    print('Error updating hall: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating ${hall.name}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _viewReservationsForHall(BuildContext context, Hall hall) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> reservations = await dbHelper.getReservationsForHall(hall.id!);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Reservations for ${hall.name}'),
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
                    return ListTile(
                      title: Text(
                        'Date: $formattedDate',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reason: ${reservation['reason']}'),
                          Text('Status: ${reservation['status']}'),
                          Text('Unit Number: ${reservation['unitNumber']}'),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Confirm Accepted'),
                                      content: Text('Are you sure you want to accept this reservation?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Close the dialog
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await _updateReservationStatus(context, dbHelper, hall, reservation['id'], 'Reserved');
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reservation accepted')));
                                          },
                                          child: Text('Confirm'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: Icon(Icons.check_circle, color: Colors.green), // Check mark icon
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Confirm Rejection'),
                                      content: Text('Are you sure you want to reject this reservation?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Close the dialog
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await _updateReservationStatus(context, dbHelper, hall, reservation['id'], 'Rejected');
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reservation rejected')));
                                          },
                                          child: Text('Confirm'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: Icon(Icons.cancel, color: Colors.red),
                              ),
                            ],
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
      },
    );
  }

  Future<void> _updateReservationStatus(BuildContext context, DatabaseHelper dbHelper, Hall hall, int reservationId, String newStatus) async {
    await dbHelper.updateReservationStatus(
      reservationId: reservationId,
      newStatus: newStatus,
    );
    Navigator.of(context).pop(); // Close the confirmation dialog
    Navigator.of(context).pop(); // Close the reservations dialog
    _viewReservationsForHall(context, hall); // Refresh the reservations list
  }

  Future<void> _showReservationHistory(BuildContext context, Hall hall) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> reservations = await dbHelper.getReservationHistory(hall.id!);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Reservation History for ${hall.name}'),
              content: Container(
                width: double.maxFinite,
                child: reservations.isEmpty
                    ? Center(
                  child: Text(
                    'No Reservation History Found',
                    style: GoogleFonts.poppins(),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    var reservation = reservations[index];
                    DateTime parsedDate = DateTime.parse(reservation['dateReserved']);
                    String formattedDate =
                        '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
                    return ListTile(
                      title: Text(
                        'Date: $formattedDate',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reason: ${reservation['reason']}'),
                          Text('Status: ${reservation['status']}'),
                          Text('Unit Number: ${reservation['unitNumber']}'),
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
      },
    );
  }

  // Method to build the reservation chart widget
  Widget buildReservationChart(Map<String, double> dataMap, int totalReservations, BuildContext context) {
    return AlertDialog(
      title: Text(
        'Reservation Chart',
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Container(
        height: 350.0,
        width: 300.0,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32.0,
          chartRadius: MediaQuery.of(context).size.width / 3.2,
          initialAngleInDegree: 0,
          chartType: ChartType.disc,
          ringStrokeWidth: 32,
          centerText: "Total\n$totalReservations", // Center text with total count
          legendOptions: LegendOptions(
            showLegendsInRow: true,
            legendPosition: LegendPosition.bottom,
            showLegends: true,
            legendShape: BoxShape.rectangle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValues: false, // Hide individual chart values
            showChartValuesInPercentage: true, // Show chart values as percentages
            decimalPlaces: 0, // Set decimalPlaces to 0 to display integers
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }

// Updated showReservationChart method
  Future<void> showReservationChart(BuildContext context) async {
    // Fetch data from hall table
    List<Hall> halls = await DatabaseHelper().getAllHalls();

    // Fetch data from reservation table
    List<Reserve> reservations = await DatabaseHelper().getAllReservations();

    // Initialize a map to store reservation counts for each hall
    Map<String, int> reservationCountsByHall = {};

    // Count reservations for each hall
    for (Hall hall in halls) {
      reservationCountsByHall[hall.name] = 0;
    }

    // Count reservations for each hall
    for (Reserve reservation in reservations) {
      String hallName = halls.firstWhere((hall) => hall.id == reservation.hallId).name;
      reservationCountsByHall[hallName] = reservationCountsByHall[hallName]! + 1;
    }

    // Calculate total reservations
    int totalReservations = reservations.length;

    // Prepare data for the pie chart with reservation counts for each hall and total reservations
    Map<String, double> dataMap = {};

    reservationCountsByHall.forEach((hallName, count) {
      int percentage = ((count / totalReservations) * 100).round();
      dataMap['$hallName\n$count ($percentage%)'] = count.toDouble();
    });

    // Show the pie chart in a dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return buildReservationChart(dataMap, totalReservations, context); // Use the extracted method
      },
    );
  }

}

