import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resicareapp/loginpage.dart';
import 'package:resicareapp/resident/profilepage.dart';
import 'package:resicareapp/resident/homepage.dart';
import 'package:resicareapp/databasehelper.dart';
import 'package:resicareapp/models/visitor.dart';
import 'package:intl/intl.dart';

class VisitorLogPage extends StatefulWidget {
  final int userId;

  VisitorLogPage({required this.userId});

  @override
  _VisitorLogPageState createState() => _VisitorLogPageState();
}

class _VisitorLogPageState extends State<VisitorLogPage> {
  late List<Visitor> _visitorHistory = [];
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _dateArrivedController = TextEditingController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVisitorHistory();
    _filteredVisitorHistory = [];
  }

  Future<void> _loadVisitorHistory() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Visitor> history = await dbHelper.getVisitorHistory(widget.userId);
    setState(() {
      _visitorHistory = history;
    });
  }

  List<Visitor> _filteredVisitorHistory = [];

  void _searchVisitor(String keyword) {
    setState(() {
      _filteredVisitorHistory = _visitorHistory.where((visitor) {
        return (visitor.name?.toLowerCase()?.contains(keyword.toLowerCase()) ?? false) ||
            (visitor.phoneNumber?.toLowerCase()?.contains(keyword.toLowerCase()) ?? false) ||
            (visitor.dateArrive?.toLowerCase()?.contains(keyword.toLowerCase()) ?? false) ||
            (visitor.timeArrive?.toLowerCase()?.contains(keyword.toLowerCase()) ?? false) ||
            (visitor.dateDepart?.toLowerCase()?.contains(keyword.toLowerCase()) ?? false) ||
            (visitor.timeDepart?.toLowerCase()?.contains(keyword.toLowerCase()) ?? false);
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
              'Visitor Log',
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
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search),
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      ),
                      onChanged: _searchVisitor,
                    ),
                  ),
                  Expanded(child: _buildVisitorHistoryList()),
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
                            'Total Visitors: ${_visitorHistory.length}',
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
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    // Show the add visitor form
                    _showVisitorForm(context);
                  },
                  child: Text(
                    'Add Visitor',
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

  Widget _buildVisitorHistoryList() {
    List<Visitor> visitorHistoryToShow = _filteredVisitorHistory.isNotEmpty ? _filteredVisitorHistory : _visitorHistory;

    if (visitorHistoryToShow.isEmpty) {
      return Center(
        child: Text(
          'No visitor history',
          style: GoogleFonts.poppins(), // Set font to Google Poppins
        ),
      );
    }

    // Sort the visitor history list based on visitor status
    visitorHistoryToShow.sort((a, b) {
      int statusA = _getVisitorStatusOrder(a);
      int statusB = _getVisitorStatusOrder(b);
      return statusA.compareTo(statusB);
    });

    return SingleChildScrollView(
      child: ListView.builder(
        shrinkWrap: true, // This ensures that the ListView only occupies the space it needs
        itemCount: visitorHistoryToShow.length,
        itemBuilder: (context, index) {
          Visitor visitor = visitorHistoryToShow[index];
          bool disableButtons = visitor.timeArrive != null || visitor.timeDepart != null;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visitor.name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold), // Set font to Google Poppins
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      _getVisitorStatus(visitor),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ), // Set font to Google Poppins
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatDate(visitor.dateArrive)}',
                      style: GoogleFonts.poppins(), // Set font to Google Poppins
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      'Phone: ${visitor.phoneNumber}',
                      style: GoogleFonts.poppins(), // Set font to Google Poppins
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: disableButtons ? null : () {
                        _editVisitorDetails(context, visitor); // Call edit function
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: disableButtons ? null : () {
                        _deleteVisitorConfirmation(context, visitor); // Call delete confirmation dialog
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


// Helper method to get the order of visitor status
  int _getVisitorStatusOrder(Visitor visitor) {
    if (visitor.timeArrive == null) {
      return 0; // Pending Arrival
    } else if (visitor.timeDepart == null) {
      return 1; // Arrived
    } else {
      return 2; // Departed
    }
  }


  void _deleteVisitorConfirmation(BuildContext context, Visitor visitor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Visitor',
            style: GoogleFonts.poppins(), // Set font to Google Poppins
          ),
          content: Text(
            'Are you sure you want to delete this visitor?',
            style: GoogleFonts.poppins(), // Set font to Google Poppins
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(), // Set font to Google Poppins
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteVisitor(visitor); // Call delete function
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(), // Set font to Google Poppins
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteVisitor(Visitor visitor) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.deleteVisitor(visitor.id!); // Assuming deleteVisitor function takes the visitor's id
    _loadVisitorHistory(); // Reload visitor history after deletion
  }

  void _editVisitorDetails(BuildContext context, Visitor visitor) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController(text: visitor.name);
    TextEditingController phoneNumberController = TextEditingController(text: visitor.phoneNumber);
    TextEditingController dateArriveController = TextEditingController(text: visitor.dateArrive);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Visitor Details'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: phoneNumberController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: dateArriveController,
                    decoration: InputDecoration(labelText: 'Date Arrive'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Date arrived is required';
                      }
                      return null;
                    },
                    onTap: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        dateArriveController.text =
                            DateFormat('yyyy-MM-dd').format(date);
                      }
                    },
                  ),
                ],
              ),
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
                  String newName = nameController.text.trim();
                  String newPhoneNumber = phoneNumberController.text.trim();
                  String newDateArrive = dateArriveController.text.trim();

                  Visitor updatedVisitor = Visitor(
                    id: visitor.id,
                    name: newName,
                    phoneNumber: newPhoneNumber,
                    dateArrive: newDateArrive,
                    residentId: visitor.residentId,
                    timeArrive: visitor.timeArrive,
                    dateDepart: visitor.dateDepart,
                    timeDepart: visitor.timeDepart,
                  );

                  await _updateVisitor(updatedVisitor);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Visitor details updated successfully'),
                    ),
                  );
                  await _loadVisitorHistory();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateVisitor(Visitor visitor) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.updateVisitor(visitor);
  }

  String _formatDate(String date) {
    // Format date as DDMMYY
    return DateFormat('dd/MM/yy').format(DateTime.parse(date));
  }

  String _getVisitorStatus(Visitor visitor) {
    if (visitor.timeArrive == null) {
      return 'Pending Arrival';
    } else if (visitor.timeDepart == null) {
      return 'Arrived';
    } else {
      return 'Departed';
    }
  }

  void _showVisitorForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Visitor'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _dateArrivedController,
                    decoration: InputDecoration(labelText: 'Date Arrived'),
                    onTap: () async {
                      // Remove focus from the text field
                      FocusScope.of(context).requestFocus(FocusNode());
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        _dateArrivedController.text =
                            DateFormat('yyyy-MM-dd').format(date);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Date arrived is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
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
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addVisitor();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }


  void _addVisitor() {
    String name = _nameController.text.trim();
    String phoneNumber = _phoneNumberController.text.trim();
    String dateArrived = _dateArrivedController.text.trim();

    Visitor newVisitor = Visitor(
      name: name,
      phoneNumber: phoneNumber,
      dateArrive: dateArrived,
      residentId: widget.userId, // Pass userId as residentId
    );

    DatabaseHelper dbHelper = DatabaseHelper();
    dbHelper.insertVisitor(newVisitor);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visitor Added Successfully'),
      ),
    );
    _loadVisitorHistory(); // Refresh the visitor history after adding a new visitor
  }

}
