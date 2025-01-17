import 'package:face_salon_beauty_booking/Authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:face_salon_beauty_booking/SQLite/sqlite.dart'; // Import DatabaseHelper

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool isVisible = false;

  // Initialize DatabaseHelper
  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pinkAccent, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ListTile(
                      title: Text("Register New Account",
                          style: TextStyle(
                              fontSize: 50, fontWeight: FontWeight.bold)),
                    ),
                    // Name Field
                    _buildInputField(
                      controller: name,
                      icon: Icons.person,
                      hintText: "Full Name",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },
                    ),
                    // Email Field
                    _buildInputField(
                      controller: email,
                      icon: Icons.email,
                      hintText: "Email",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Email is required";
                        } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    // Phone Field
                    _buildInputField(
                      controller: phone,
                      icon: Icons.phone,
                      hintText: "Phone Number",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Phone number is required";
                        } else if (value.length < 10 || value.length > 15) {
                          return "Enter a valid phone number";
                        } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return "Phone number must contain only digits";
                        }
                        return null;
                      },
                    ),
                    // Username Field
                    _buildInputField(
                      controller: username,
                      icon: Icons.person,
                      hintText: "Username",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Username is required";
                        }
                        return null;
                      },
                    ),
                    // Password Field
                    _buildPasswordField(
                      controller: password,
                      hintText: "Password",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password is required";
                        } else if (value.length < 4) {
                          return "Password must be at least 4 characters long";
                        }
                        return null;
                      },
                    ),
                    // Confirm Password Field
                    _buildPasswordField(
                      controller: confirmPassword,
                      hintText: "Confirm Password",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Confirm Password is required";
                        } else if (value != password.text) {
                          return "Passwords don't match";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // Sign Up Button
                    Container(
                      height: 55,
                      width: MediaQuery.of(context).size.width * .9,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.pinkAccent),
                      child: TextButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            // Collect user data
                            Map<String, dynamic> user = {
                              'username': username.text,
                              'password': password.text,
                              'name': name.text,
                              'email': email.text,
                              'phone': phone.text,
                            };
        
                            // Call userSignup method to insert user into the database
                            int result = await dbHelper.userSignup(user);
        
                            if (result > 0) {
                              // Navigate to login page after successful signup
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginScreen()));
                            } else {
                              // Show error if signup failed
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Sign Up Failed')));
                            }
                          }
                        },
                        child: const Text("SIGN UP",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    // Login Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()));
                          },
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(color: Colors.pinkAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required String? Function(String?) validator,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white60.withOpacity(.5)),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          icon: Icon(icon),
          border: InputBorder.none,
          hintText: hintText,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white60.withOpacity(.5)),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: !isVisible,
        decoration: InputDecoration(
          icon: const Icon(Icons.lock),
          border: InputBorder.none,
          hintText: hintText,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                isVisible = !isVisible;
              });
            },
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          ),
        ),
      ),
    );
  }
}
