import 'package:flutter/material.dart';
import 'package:resicareapp/databasehelper.dart';
import 'package:resicareapp/loginpage.dart';
import 'package:resicareapp/models/resident.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController unitNumberController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  String? userTypeValue;

  final _formKey = GlobalKey<FormState>(); // Add a global key for the form

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://img.freepik.com/free-vector/minimal-house-exterior-design-mobile-phone-wallpaper_53876-100874.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Form( // Wrap your form with Form widget
                key: _formKey, // Assign the global key to the Form widget
                autovalidateMode: AutovalidateMode.disabled, // Set autovalidation to disabled initially
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 70.0),
                    Text(
                      'Register',
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 59, 59, 61),
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(color: Colors.lightGreen),
                        prefixIcon: Icon(Icons.person, color: Colors.lightGreen),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightGreen),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightGreen, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.lightGreen),
                        prefixIcon: Icon(Icons.email, color: Colors.lightGreen),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightGreen),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightGreen, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.lightGreen),
                        prefixIcon: Icon(Icons.lock, color: Colors.lightGreen),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightGreen),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightGreen, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: unitNumberController,
                      decoration: InputDecoration(
                        labelText: 'Unit Number',
                        labelStyle: TextStyle(color: Colors.lightGreen),
                        prefixIcon: Icon(Icons.home, color: Colors.lightGreen),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightGreen),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightGreen, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Unit Number is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(color: Colors.lightGreen),
                        prefixIcon: Icon(Icons.phone, color: Colors.lightGreen),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightGreen),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightGreen, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone Number is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    DropdownButtonFormField<String>(
                      value: userTypeValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          userTypeValue = newValue;
                        });
                      },
                      items: <String>['Resident', 'Guard'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'User Type',
                        labelStyle: TextStyle(color: Colors.lightGreen),
                        prefixIcon: Icon(Icons.person, color: Colors.lightGreen),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightGreen),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightGreen, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'User Type is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () async {
                        // Validate form
                        if (_formKey.currentState!.validate()) {
                          // Get user input from text fields
                          String name = nameController.text;
                          String email = emailController.text;
                          String password = passwordController.text;
                          String unitNumber = unitNumberController.text;
                          String phoneNumber = phoneNumberController.text;
                          String userType = userTypeValue ?? '';
                          String imageUrl = 'assets/profile.png';

                          // Create a new Resident object
                          Resident newResident = Resident(
                            name: name,
                            phoneNumber: phoneNumber,
                            email: email,
                            password: password,
                            unitNumber: unitNumber,
                            userType: userType,
                            imageUrl: imageUrl,
                          );

                          // Insert the resident into the database
                          DatabaseHelper dbHelper = DatabaseHelper();
                          int result = await dbHelper.insertResident(newResident);

                          if (result != 0) {
                            // Registration successful, navigate to login page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          } else {
                            // Registration failed
                            // Handle error or show error message
                          }
                        }
                      },
                      child: Text('Register',
                        style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.lightGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

