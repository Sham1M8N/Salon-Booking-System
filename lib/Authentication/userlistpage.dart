import 'package:face_salon_beauty_booking/Authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:face_salon_beauty_booking/SQLite/sqlite.dart';

class UserProfilePage extends StatefulWidget {
  final int currentUserId;

  const UserProfilePage({super.key, required this.currentUserId});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic>? _user;
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _phone = '';
  String _username = '';
  String _password = '';
  late int _currentUserId;
  bool _isPasswordVisible = false; // Variable to control password visibility

  @override
  void initState() {
    super.initState();
    _currentUserId = widget.currentUserId;
    _fetchUserProfile();
  }

  void _fetchUserProfile() async {
    Map<String, dynamic>? user = await _dbHelper.getUserById(_currentUserId);
    setState(() {
      _user = user;
    });
  }

  void _updateUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Map<String, dynamic> updatedUser = {
        'name': _name,
        'email': _email,
        'phone': _phone,
        'username': _username,
        'password': _password,
      };

      try {
        await _dbHelper.updateUser(updatedUser, _currentUserId);
        _fetchUserProfile();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    }
  }

  void _logOut() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _deleteUserProfile() async {
    try {
      await _dbHelper.deleteUser(_currentUserId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile deleted successfully!')));
      _logOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Your Profile'),
          backgroundColor: Colors.pinkAccent,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _user!['username'],
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _username = value!,
                validator: (value) => value!.isEmpty ? 'Please enter username' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _user!['name'],
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _name = value!,
                validator: (value) => value!.isEmpty ? 'Please enter name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _user!['email'],
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _email = value!,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _user!['phone'],
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _phone = value!,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter phone number';
                  } else if (!RegExp(r'^\d{10,}$').hasMatch(value)) {
                    return 'Phone number must be at least 10 digits';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _user!['password'],
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible, // Toggle visibility
                onSaved: (value) => _password = value!,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter password';
                  } else if (value.length < 4) {
                    return 'Password must be at least 4 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text('Save Changes'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _deleteUserProfile,
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 255, 115, 162)),
                child: Text('Delete Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
