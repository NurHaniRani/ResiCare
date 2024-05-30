import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resicareapp/databasehelper.dart';
import 'package:resicareapp/landingpage.dart';
import 'package:resicareapp/models/resident.dart';
import 'package:resicareapp/models/family.dart';
import 'adminprofilepage.dart';
import 'adminhomepage.dart';
import 'package:pie_chart/pie_chart.dart';

class ResidentsManagerPage extends StatefulWidget {
  final int userId;

  ResidentsManagerPage({required this.userId});

  @override
  _ResidentsManagerPageState createState() => _ResidentsManagerPageState();
}

class _ResidentsManagerPageState extends State<ResidentsManagerPage> {
  late List<Resident> _residentList =[];
  late List<String> _userTypeFilters = ["All", "Admin", "Resident", "Guard"];
  String _selectedUserTypeFilter = "All";

  @override
  void initState() {
    super.initState();
    _loadResidents();
  }

  Future<void> _loadResidents() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Resident> residentList = await dbHelper.getResidents();
    setState(() {
      _residentList = residentList;
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
              'Residents Log',
              style: GoogleFonts.poppins(
                color: const Color.fromARGB(255, 59, 59, 61),
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          // Dropdown for filtering residents by user type
          Positioned(
            top: 95.0,
            left: 20.0,
            right: 20.0,
            child: SizedBox(
              height: 33,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: DropdownButton<String>(
                  value: _selectedUserTypeFilter,
                  isExpanded: true,
                  underline: SizedBox(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedUserTypeFilter = newValue!;
                    });
                  },
                  items: _userTypeFilters.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          //Residents List
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
                child: _buildResidentList(),
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
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.purple[200]!),
                  ),
                  onPressed: () {
                    // Show total residents
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text(
                            'Total Users: ${_residentList.length}',
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
                    'Show Total Users',
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
          Positioned(
            bottom: 70.0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[200]!),
                  ),
                  onPressed: () {
                    _showResidentChart(context);
                  },
                  child: Text(
                    'Show Resident Chart',
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

  Widget _buildResidentList() {
    List<Resident> filteredResidents = _filterResidents();

    if (filteredResidents.isEmpty) {
      return Center(
        child: Text(
          'No Residents Available',
          style: GoogleFonts.poppins(),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredResidents.length,
      itemBuilder: (context, index) {
        Resident resident = filteredResidents[index];
        return ListTile(
          title: Text(resident.name, style: GoogleFonts.poppins()),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Unit: ${resident.unitNumber}', style: GoogleFonts.poppins()),
              Text('Category: ${resident.userType}', style: GoogleFonts.poppins()),
              Text('Phone: ${resident.phoneNumber}', style: GoogleFonts.poppins()),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.people),
                onPressed: () {
                  // Display Family Members
                  _showFamilyMembers(context, resident.id!);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteResident(context, resident.id!);
                },
              ),
            ],
          ),
          // Add more details or actions as needed
        );
      },
    );
  }

  void _showFamilyMembers(BuildContext context, int residentId) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Family> familyMembers = await dbHelper.getFamilyMembers(residentId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Family Members', style: GoogleFonts.poppins()),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: familyMembers.length,
              itemBuilder: (context, index) {
                Family family = familyMembers[index];
                return ListTile(
                  title: Text(family.name, style: GoogleFonts.poppins()),
                  subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone: ${family.phoneNumber}', style: GoogleFonts.poppins()),
                    Text('Category: ${family.category}', style: GoogleFonts.poppins()),
                  ],
                ),
                  // Add more details or actions as needed
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }


  // Function to filter residents based on selected filters
  List<Resident> _filterResidents() {
    List<Resident> filteredList = _residentList;

    // Filter by user type
    if (_selectedUserTypeFilter != "All") {
      filteredList = filteredList.where((resident) => resident.userType == _selectedUserTypeFilter).toList();
    }

    return filteredList;
  }

  void _deleteResident(BuildContext context, int residentId) async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion', style: GoogleFonts.poppins()),
          content: Text('Are you sure you want to delete this resident?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Return false when cancel is pressed
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Return true when delete is pressed
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    // If user confirms deletion, proceed with deletion
    if (confirmDelete == true) {
      try {
        // Perform deletion from various tables
        await DatabaseHelper().deleteFromReserves(residentId);
        await DatabaseHelper().deleteFromFamily(residentId);
        await DatabaseHelper().deleteFromVisitors(residentId);
        await DatabaseHelper().deleteFromComplaints(residentId);
        await DatabaseHelper().deleteFromNews(residentId);
        await DatabaseHelper().deleteFromResidents(residentId);

        _loadResidents();

        // Show success message or navigate to a different screen
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Resident deleted successfully'),
        ));

        // You can add additional actions after deletion if needed
      } catch (e) {
        // Handle any errors that occur during deletion
        print('Error deleting resident: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error deleting resident. Please try again.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _showResidentChart(BuildContext context) async {
    // Fetch data from family table
    List<Family> familyMembers = await DatabaseHelper().getAllFamilyMembers();

    // Fetch all residents from the residents table
    List<Resident> residents = await DatabaseHelper().getAllResidents();

    // Count the number of Elderly, Children, and Adults from family members
    int elderlyCount = 0;
    int childrenCount = 0;
    int adultCount = 0;

    for (Family familyMember in familyMembers) {
      switch (familyMember.category) {
        case 'Elderly':
          elderlyCount++;
          break;
        case 'Children':
          childrenCount++;
          break;
        case 'Adult':
          adultCount++;
          break;
        default:
        // Do nothing for other categories
          break;
      }
    }

    // Categorize residents with userType 'resident' or 'Resident' as adults
    for (Resident resident in residents) {
      if (resident.userType.toLowerCase() == 'resident') {
        adultCount++;
      }
    }

    // Calculate total residents
    int totalResidents = elderlyCount + childrenCount + adultCount;

    // Calculate percentages and round them to integers
    int elderlyPercentage = ((elderlyCount / totalResidents) * 100).round();
    int childrenPercentage = ((childrenCount / totalResidents) * 100).round();
    int adultPercentage = ((adultCount / totalResidents) * 100).round();

    // Prepare data for the pie chart with rounded percentages
    Map<String, double> dataMap = {
      'Elderly\n$elderlyPercentage%': elderlyCount.toDouble(),
      'Children\n$childrenPercentage%': childrenCount.toDouble(),
      'Adults\n$adultPercentage%': adultCount.toDouble(),
    };

    // Show the pie chart in a dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Resident Chart',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            height: 350.0, // Increased height to accommodate total count
            width: 300.0,
            child: PieChart(
              dataMap: dataMap,
              animationDuration: Duration(milliseconds: 800),
              chartLegendSpacing: 32.0,
              chartRadius: MediaQuery.of(context).size.width / 3.2,
              initialAngleInDegree: 0,
              chartType: ChartType.disc,
              ringStrokeWidth: 32,
              centerText: "Total\n$totalResidents", // Center text with total count
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
                showChartValues: false,
                showChartValuesOutside: false,
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
      },
    );
  }


}
