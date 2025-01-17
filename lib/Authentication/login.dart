import 'package:face_salon_beauty_booking/Authentication/admin.dart';
import 'package:face_salon_beauty_booking/Authentication/signup.dart';
import 'package:face_salon_beauty_booking/SQLite/sqlite.dart';
import 'package:flutter/material.dart';
import 'package:face_salon_beauty_booking/packageselection.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextEditing controllers to control the text when entered
  final username = TextEditingController();
  final password = TextEditingController();

  // Bool variable to show and hide password
  bool isVisible = false;

  // Need to create global key for form
  final formKey = GlobalKey<FormState>();

  Map<String, dynamic> currentPackage = {

    'name': 'Default Package', // Example default value

    'price': 100.0, // Example default value

  };

  // Function to handle login
  Future<void> login() async {
    // Check if form is valid
    if (formKey.currentState!.validate()) {
      // First, check if the entered credentials match the admin account
      bool isAdmin =
          await DatabaseHelper().adminLogin(username.text, password.text);

      if (isAdmin) {
        // If admin, navigate to the admin dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AdminPage(), // Navigate to Admin Dashboard
          ),
        );
      } else {
        // If not admin, check if the credentials match a regular user
        int? userId = await DatabaseHelper()
            .getUserIdByCredentials(username.text, password.text);
        if (userId != null) {
          List<Map<String, dynamic>> selectedPackages = [];
          // If valid, navigate to the package selection page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PackageSelectionPage(
                selectedPackages: selectedPackages, 
                userId: userId,
                name: username.text,
                phoneNumber: '0123456789', // Placeholder
                email: 'example@example.com', // Placeholder
                bookingDate: DateTime.now(), // Placeholder
                serviceDuration: '1 Hour', // Placeholder
                additionalRequests: 'None', // Placeholder
                numberOfGuests: 1, // Placeholder
                currentPackage: currentPackage,
              ),
            ),
          );
        } else {
          // If invalid, show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invalid username or password")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pinkAccent, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    // Logo or Image
                    Image.asset(
                      "assets/logo.png",
                      width: 210,
                    ),
                    const SizedBox(height: 25),
                    // Username Field
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white60.withOpacity(.5)),
                      child: TextFormField(
                        controller: username,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Username is required";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          border: InputBorder.none,
                          hintText: "Username",
                        ),
                      ),
                    ),
        
                    // Password Field
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white60.withOpacity(.5)),
                      child: TextFormField(
                        controller: password,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Password is required";
                          }
                          return null;
                        },
                        obscureText: !isVisible,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.lock),
                          border: InputBorder.none,
                          hintText: "Password",
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isVisible = !isVisible;
                              });
                            },
                            icon: Icon(isVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                        ),
                      ),
                    ),
        
                    const SizedBox(height: 10),
        
                    // Login Button
                    Container(
                      height: 55,
                      width: MediaQuery.of(context).size.width * .9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.pinkAccent,
                      ),
                      child: TextButton(
                        onPressed: login, // Call the login function
                        child: const Text("LOGIN",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
        
                    // SignUp Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            // Navigate to Sign Up
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUp()),
                            );
                          },
                          child: const Text(
                            "SIGN UP",
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
}
