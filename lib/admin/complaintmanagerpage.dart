import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resicareapp/admin/adminprofilepage.dart';
import 'package:resicareapp/admin/adminhomepage.dart';
import 'package:resicareapp/databasehelper.dart';
import 'package:resicareapp/models/complaint.dart';
import 'package:resicareapp/loginpage.dart';

class ComplaintManagerPage extends StatefulWidget {
  final int userId;

  ComplaintManagerPage({required this.userId});

  @override
  _ComplaintManagerPageState createState() => _ComplaintManagerPageState();
}

class _ComplaintManagerPageState extends State<ComplaintManagerPage> {
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
    List<Complaint> complaintList = await dbHelper.getComplaints();
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
              'https://static.vecteezy.com/system/resources/previews/021/620/518/original/wall-concrete-with-3d-open-window-against-blue-sky-and-clouds-exterior-rooftop-white-cement-building-ant-view-minimal-modern-architecture-with-summer-sky-backdrop-background-for-spring-summer-vector.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 40.0,
            left: 15.0,
            child: Text(
              'Complaint Manager',
              style: GoogleFonts.poppins(
                color: const Color.fromARGB(255, 59, 59, 61),
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          // Dropdowns for filtering complaints by status and category
          Positioned(
            top: 95.0, // Adjust position as needed
            left: 20.0,
            right: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SizedBox(
                    height: 33, // Set the desired height
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedStatusFilter,
                        isExpanded: true,
                        // Makes the dropdown take the full width
                        underline: SizedBox(),
                        // Removes the default underline
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatusFilter = newValue!;
                          });
                        },
                        items: _statusFilters.map<DropdownMenuItem<String>>((
                            String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10), // Add spacing between the dropdowns
                Flexible(
                  child: SizedBox(
                    height: 33, // Set the desired height
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCategoryFilter,
                        isExpanded: true,
                        // Makes the dropdown take the full width
                        underline: SizedBox(),
                        // Removes the default underline
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategoryFilter = newValue!;
                          });
                        },
                        items: _categoryFilters.map<DropdownMenuItem<String>>((
                            String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Container( // Wrap with Container
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
                  color: Colors.pink[200],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: _buildComplaintList(),
              ),
            ),
          ),

          Positioned(
            bottom: 40.0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.purple[200]!),
                  ),
                  onPressed: () {
                    // Show total complaints
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
                  MaterialPageRoute(builder: (context) =>
                      AdminProfilePage(userId: widget.userId)),
                );
              },
              icon: Icon(Icons.person),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      AdminHomePage(userId: widget.userId)),
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

  // Function to build the complaint list based on filters
  // Function to build the complaint list based on filters
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
        return ListTile(
          title: Text(complaint.complaintText, style: GoogleFonts.poppins()),
          subtitle: Text(
              'Status: ${complaint.status}', style: GoogleFonts.poppins()),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  // Edit Complaint Status
                  _editComplaintStatus(context, complaint);
                },
              ),
            ],
          ),
          // Add more details or actions as needed
        );
      },
    );
  }

  void _editComplaintStatus(BuildContext context, Complaint complaint) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Complaint Status'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Complaint Text: ${complaint.complaintText}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Category: ${complaint.category}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: complaint.status,
                  items: _statusFilters.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        complaint.status = value;
                      });
                      // Call a function here to update the complaint status in the database
                      _updateComplaintStatus(complaint);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Status',
                  ),
                ),
              ],
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
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateComplaintStatus(Complaint complaint) async {
    try {
      if (complaint.id == null) {
        // Show an error snackbar or toast indicating that the complaint ID is null
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Complaint ID is null'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Exit the method early
      }

      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.updateComplaintStatus(complaint.id!, complaint.status);
      // Show a snackbar or toast to indicate successful update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complaint status updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      // Reload the complaints list to reflect the changes
      _loadComplaints();
    } catch (e) {
      // Handle any errors that occur during the update process
      print('Error updating complaint status: $e');
      // Show an error snackbar or toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating complaint status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to filter complaints based on selected filters
  List<Complaint> _filterComplaints() {
    List<Complaint> filteredList = _complaintList;

    // Filter by status
    if (_selectedStatusFilter != "All") {
      filteredList = filteredList.where((complaint) => complaint.status == _selectedStatusFilter).toList();
    }

    // Filter by category
    if (_selectedCategoryFilter != "All") {
      filteredList = filteredList.where((complaint) => complaint.category == _selectedCategoryFilter).toList();
    }

    return filteredList;
  }

}