import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resicareapp/databasehelper.dart';
import 'package:resicareapp/models/family.dart';
import 'package:resicareapp/resident/homepage.dart';
import 'package:resicareapp/loginpage.dart';
import 'package:resicareapp/resident/profilepage.dart';

class FamilyDetailPage extends StatefulWidget {
  final int userId;

  const FamilyDetailPage({Key? key, required this.userId}) : super(key: key);

  @override
  _FamilyDetailPageState createState() => _FamilyDetailPageState();
}

class _FamilyDetailPageState extends State<FamilyDetailPage> {
  late List<Family> _familyMembers = [];
  late DatabaseHelper _dbHelper;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    List<Family> familyMembers = await _dbHelper.getFamilyMembersByUserId(widget.userId);
    setState(() {
      _familyMembers = familyMembers;
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
              'Family Details',
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
              child: _buildFamilyList(),
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
                            'Total Family Members: ${_familyMembers.length}',
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
                    'Show Total Family Members',
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
                    _addFamilyMember();
                  },
                  child: Text(
                    'Add Family Member',
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

  Widget _buildFamilyList() {
    if (_familyMembers.isEmpty) {
      return Center(
        child: Text(
          'No family members registered',
          style: GoogleFonts.poppins(),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: _familyMembers.length,
        itemBuilder: (context, index) {
          Family familyMember = _familyMembers[index];
          return ListTile(
            title: Text(
              familyMember.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              familyMember.phoneNumber,
              style: GoogleFonts.poppins(),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editFamilyMember(context, familyMember);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteFamilyMember(familyMember.id!);
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _addFamilyMember() {
    // Clear text controllers to ensure the form is empty
    _nameController.clear();
    _phoneNumberController.clear();
    _categoryController.clear();

    // Define a list of categories
    List<String> categories = ['Children', 'Adult', 'Elderly'];
    String selectedCategory = categories[0]; // Default to the first category

    final _formKey = GlobalKey<FormState>(); // Add a form key for validation

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Family Member'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                  ),
                  SizedBox(height: 10), // Add some spacing
                  // DropdownButtonFormField for selecting category
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        selectedCategory = value;
                        _categoryController.text = value; // Update category controller
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Category',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Category is required';
                      }
                      return null;
                    },
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
                  _submitForm(_nameController.text, _phoneNumberController.text, _categoryController.text); // Use _categoryController.text
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



  void _submitForm(String name, String phoneNumber, String category) {
    Family newFamilyMember = Family(
      name: name,
      phoneNumber: phoneNumber,
      category: category,
      userId: widget.userId,
    );
    _dbHelper.insertFamilyMember(newFamilyMember);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Family member added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    _loadFamilyMembers();
    _nameController.clear();
    _phoneNumberController.clear();
  }

  void _editFamilyMember(BuildContext context, Family familyMember) {
    _nameController.text = familyMember.name;
    _phoneNumberController.text = familyMember.phoneNumber;
    _categoryController.text = familyMember.category; // Set category controller text

    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Family Member'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                  ),
                  SizedBox(height: 10), // Add some spacing
                  // DropdownButtonFormField for selecting category
                  DropdownButtonFormField<String>(
                    value: familyMember.category, // Use family member's category as initial value
                    items: ['Children', 'Adult', 'Elderly'].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        _categoryController.text = value; // Update category controller
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
                  _submitEditForm(familyMember.id!);
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


  void _submitEditForm(int familyId) async {
    Family updatedFamilyMember = Family(
      id: familyId,
      name: _nameController.text,
      phoneNumber: _phoneNumberController.text,
      category: _categoryController.text,
      userId: widget.userId,
    );

    try {
      int result = await _dbHelper.updateFamilyDetails(
        familyId,
        updatedFamilyMember.name!,
        updatedFamilyMember.phoneNumber!,
        updatedFamilyMember.category!,
      );

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Family member updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update family member.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    _loadFamilyMembers();
  }

  void _deleteFamilyMember(int memberId) async {
    // Show confirmation dialog
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this family member?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false when Cancel is pressed
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true when Delete is pressed
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    // If user confirms deletion, proceed to delete the family member
    if (confirmDelete == true) {
      try {
        int result = await _dbHelper.deleteFamilyMember(memberId);

        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Family member deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete family member.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      _loadFamilyMembers();
    }
  }


}
