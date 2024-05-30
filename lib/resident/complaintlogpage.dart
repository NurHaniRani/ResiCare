import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resicareapp/landingpage.dart';
import 'package:resicareapp/models/complaint.dart';
import 'package:resicareapp/databasehelper.dart';
import 'homepage.dart';
import 'package:resicareapp/resident/profilepage.dart';

class ComplaintLogPage extends StatefulWidget {
  final int userId;

  ComplaintLogPage({required this.userId});

  @override
  _ComplaintLogPageState createState() => _ComplaintLogPageState();
}

class _ComplaintLogPageState extends State<ComplaintLogPage> {
  late List<Complaint> _complaintList = [];
  late List<String> _statusFilters = [
    "All",
    "To Be Reviewed",
    "Reviewing",
    "Completed"
  ];
  late List<String> _categoryFilters = [
    "All",
    'Safety & Security',
    'Disturbance',
    'Parking',
    'Utility',
    'Others'
  ];
  String _selectedStatusFilter = "All";
  String _selectedCategoryFilter = "All";

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Complaint> complaintList = await dbHelper.getComplaintsByUserId(widget.userId);
    setState(() {
      _complaintList = complaintList;
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
              'Complaint Log',
              style: GoogleFonts.poppins(
                color: const Color.fromARGB(255, 59, 59, 61),
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          // Dropdowns for filtering complaints by status and category
          Positioned(
            top: 95.0,
            left: 20.0,
            right: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SizedBox(
                    height: 33,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedStatusFilter,
                        isExpanded: true,
                        underline: SizedBox(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatusFilter = newValue!;
                          });
                        },
                        items: _statusFilters.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: SizedBox(
                    height: 33,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCategoryFilter,
                        isExpanded: true,
                        underline: SizedBox(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategoryFilter = newValue!;
                          });
                        },
                        items: _categoryFilters.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Container(
                              child: Text(value),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Complaint list
          Positioned(
            top: 140.0,
            left: 20.0,
            right: 20.0,
            child: SingleChildScrollView(
              child: Container(
                height: 450.0,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: _buildComplaintList(),
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text(
                            'Total Complaints: ${_complaintList.length}',
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
                    'Show Total Complaints',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _showAddComplaintForm,
                  child: Text(
                    'Add Complaint',
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

  Widget _buildComplaintList() {
    List<Complaint> filteredComplaints = _filterComplaints();

    if (filteredComplaints.isEmpty) {
      return Center(
        child: Text(
          'No Complaints Available',
          style: GoogleFonts.poppins(),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredComplaints.length,
      itemBuilder: (context, index) {
        Complaint complaint = filteredComplaints[index];

        // Determine if edit and delete buttons should be enabled based on complaint status
        bool isEditable = complaint.status != "Completed" && complaint.status != "Reviewing";

        return ListTile(
          title: Text(complaint.complaintText, style: GoogleFonts.poppins()),
          subtitle: Text('Status: ${complaint.status}', style: GoogleFonts.poppins()),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: isEditable ? () {
                  _editComplaint(context, complaint);
                } : null, // Set onPressed to null if not editable
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: isEditable ? () {
                  _confirmDelete(context, complaint);
                } : null, // Set onPressed to null if not editable
              ),
            ],
          ),
        );
      },
    );
  }


  void _confirmDelete(BuildContext context, Complaint complaint) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this complaint?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteComplaint(complaint.id!); // Assuming complaint.id is non-null
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }


  void _deleteComplaint(int complaintId) async {
    DatabaseHelper dbHelper = DatabaseHelper();

    // Assuming deleteComplaint returns a Future<void>
    await dbHelper.deleteComplaint(complaintId);

    // Assuming _loadComplaints() is a function to reload complaints
    _loadComplaints();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Complaint deleted successfully'),
        backgroundColor: Colors.red, // Change color as needed
      ),
    );
  }

  void _addComplaint(Complaint complaint) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.insertComplaint(complaint);
    _loadComplaints(); // Reload complaints after adding
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Complaint added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  void _showAddComplaintForm() {
    String complaintText = '';
    String category = _categoryFilters[1]; // Default to the first category after "All"

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Complaint'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey, // Use the _formKey here
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Complaint Text'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Complaint text is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      complaintText = value;
                    },
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: category,
                    items: _categoryFilters.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        category = newValue;
                      }
                    },
                    decoration: InputDecoration(labelText: 'Category'),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Complaint newComplaint = Complaint(
                    complaintText: complaintText,
                    category: category,
                    status: "To Be Reviewed",
                    userId: widget.userId,
                  );
                  _addComplaint(newComplaint);
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



  void _editComplaint(BuildContext context, Complaint complaint) {
    TextEditingController complaintController =
    TextEditingController(text: complaint.complaintText);
    TextEditingController categoryController =
    TextEditingController(text: complaint.category);

    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Complaint'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: complaintController,
                    decoration: InputDecoration(labelText: 'Complaint Text'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Complaint text is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: categoryController.text,
                    items: [
                      'Safety & Security',
                      'Disturbance',
                      'Parking',
                      'Utility',
                      'Others',
                    ].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        categoryController.text = value;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Category',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (complaint.id != null) {
                    _updateComplaint(
                      complaint.id!,
                      complaintController.text.trim(),
                      categoryController.text,
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: Complaint ID is null.'),
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


  void _updateComplaint(int id, String complaintText, String category) async {
    Complaint updatedComplaint = Complaint(
      id: id,
      complaintText: complaintText,
      status: 'To Be Reviewed',
      category: category,
      userId: widget.userId,
    );
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.updateComplaint(updatedComplaint);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Complaint Updated Successfully'),
      ),
    );
    _loadComplaints();
  }

  List<Complaint> _filterComplaints() {
    List<Complaint> filteredList = _complaintList;

    if (_selectedStatusFilter != "All") {
      filteredList = filteredList.where((complaint) => complaint.status == _selectedStatusFilter).toList();
    }

    if (_selectedCategoryFilter != "All") {
      filteredList = filteredList.where((complaint) => complaint.category == _selectedCategoryFilter).toList();
    }

    return filteredList;
  }
}
