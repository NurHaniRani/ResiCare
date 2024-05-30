import 'dart:io';
import 'package:flutter/material.dart';
import 'package:resicareapp/databasehelper.dart';
import 'package:resicareapp/landingpage.dart';
import 'package:resicareapp/models/resident.dart';
import 'package:resicareapp/resident/homepage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Resident _user;
  late DatabaseHelper _dbHelper;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _unitNumberController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _editingProfile = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _user = Resident(
      id: -1,
      name: '',
      email: '',
      phoneNumber: '',
      unitNumber: '',
      imageUrl: '',
      password: '', // Provide a default value for password
      userType: 'default', // Provide a default value for userType
    );
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      _user = await _dbHelper.getUserById(widget.userId);
      // Initialize controllers with user data
      _nameController.text = _user.name;
      _phoneNumberController.text = _user.phoneNumber;
      _unitNumberController.text = _user.unitNumber;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _updateProfileImage(File(pickedFile.path));
      });
    }
  }

  Future<void> _updateProfileImage(File newImage) async {
    try {
      await _dbHelper.updateResidentImageUrl(widget.userId, newImage.path);
      await _getUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image updated successfully')),
      );
    } catch (e) {
      print('Error updating profile image: $e');
    }
  }

  Future<void> _updateProfile() async {
    try {
      // Update user details in the database
      await _dbHelper.updateResidentDetails(
        widget.userId,
        _nameController.text,
        _phoneNumberController.text,
        _unitNumberController.text,
      );
      // Refresh user data
      await _getUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      setState(() {
        _editingProfile = false;
      });
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://img.freepik.com/free-vector/minimal-house-exterior-design-mobile-phone-wallpaper_53876-100874.jpg',
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0),
                  Text(
                    'Profile',
                    style: GoogleFonts.poppins(
                      color: const Color.fromARGB(255, 59, 59, 61),
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Center(
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: _user.imageUrl != null &&
                            _user.imageUrl!.isNotEmpty
                            ? _user.imageUrl!.startsWith('assets')
                            ? AssetImage(_user.imageUrl!) as ImageProvider
                            : FileImage(File(_user.imageUrl!)) as ImageProvider
                            : AssetImage('assets/profilegirl.png') as ImageProvider,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  _editingProfile
                      ? Form(
                    key: _formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Icon(Icons.person),
                            title: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: 'Enter your name',
                                labelText: 'Name',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.email),
                            title: Text(
                              'Email: ${_user.email}',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.location_on),
                            title: TextFormField(
                              controller: _unitNumberController,
                              decoration: InputDecoration(
                                hintText: 'Enter your unit number',
                                labelText: 'Unit Number',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Unit number is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.phone),
                            title: TextFormField(
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'Enter your phone number',
                                labelText: 'Phone Number',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Phone number is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _updateProfile();
                              }
                            },
                            child: Text(
                              'Save Profile',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text(
                            'Name: ${_user.name}',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.email),
                          title: Text(
                            'Email: ${_user.email}',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.location_on),
                          title: Text(
                            'Unit Number: ${_user.unitNumber}',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.phone),
                          title: Text(
                            'Phone Number: ${_user.phoneNumber}',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              _editingProfile = true;
                            });
                          },
                          child: Text(
                            'Edit Profile',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
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
              onPressed: () {},
              icon: Icon(Icons.person),
              color: Colors.black,
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
}
