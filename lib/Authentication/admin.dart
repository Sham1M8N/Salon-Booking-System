import 'package:flutter/material.dart';
import 'package:face_salon_beauty_booking/Authentication/login.dart';
import 'package:face_salon_beauty_booking/SQLite/sqlite.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchBookings();
  }

  Future<void> _fetchUsers() async {
    final users = await _dbHelper.getAllUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _fetchBookings() async {
    final bookings = await _dbHelper.getAllBookingsWithUserDetails();
    setState(() {
      _bookings = bookings;
    });
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      initialDate = DateTime.parse(controller.text);
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != initialDate) {
      if (pickedDate.isBefore(DateTime.now())) {
        _showErrorDialog('Appointment date cannot be in the past.');
      } else {
        controller.text = "${pickedDate.toLocal()}".split(' ')[0];
      }
    }
  }

 Future<void> _selectTime(TextEditingController controller) async {
  TimeOfDay initialTime = TimeOfDay(hour: 10, minute: 0); // Default to 10:00 AM

  // Show the time picker dialog
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: initialTime,
  );

  // If the user selects a time, validate it
  if (pickedTime != null) {
    // Check if the selected time is between 10 AM and before 5 PM
    if (pickedTime.hour >= 10 && pickedTime.hour < 17) {
      controller.text = pickedTime.format(context); // Use the format method to handle time format
    } else {
      _showErrorDialog('Please select a time between 10:00 AM and before 5:00 PM.');
    }
  }
}




  Future<void> _showUpdateBookingDialog(Map<String, dynamic> booking) async {
  final TextEditingController bookDateController = TextEditingController(text: booking['bookdate']);
  final TextEditingController bookTimeController = TextEditingController(text: booking['booktime']);
  final TextEditingController appointmentDateController = TextEditingController(text: booking['appointmentdate']);
  final TextEditingController appointmentTimeController = TextEditingController(text: booking['appointmenttime']);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Update Booking'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildReadOnlyTextField(bookDateController, 'Booking Date'),
              _buildReadOnlyTextField(bookTimeController, 'Booking Time'),
              _buildEditableTextField(appointmentDateController, 'Appointment Date', () => _selectDate(appointmentDateController)),
              _buildEditableTextField(appointmentTimeController, 'Appointment Time', () => _selectTime(appointmentTimeController)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_validateBookingInputs(appointmentDateController, appointmentTimeController)) {
                final updatedBooking = {
                  'appointmentdate': appointmentDateController.text,
                  'appointmenttime': appointmentTimeController.text,
                };
                await _dbHelper.updateBeautyBook(updatedBooking, booking['bookid']);
                Navigator.pop(context);
                _fetchBookings();
                _showConfirmationDialog('Booking details updated successfully!');
              }
            },
            child: Text('Update'),
          ),
        ],
      );
    },
  );
}



  bool _validateBookingInputs(TextEditingController appointmentDateController, TextEditingController appointmentTimeController) {
    final dateFormatRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (appointmentDateController.text.trim().isEmpty || appointmentTimeController.text.trim().isEmpty) {
      _showErrorDialog('Appointment Date and Time are required.');
      return false;
    }

    if (!dateFormatRegex.hasMatch(appointmentDateController.text.trim())) {
      _showErrorDialog('Please enter a valid date in YYYY-MM-DD format.');
      return false;
    }

    return true;
  }

  TextField _buildReadOnlyTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      readOnly: true,
    );
  }

  TextField _buildEditableTextField(TextEditingController controller, String label, Function onTap) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    readOnly: false,
    onTap: () => onTap(),
  );
}


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _navigateToLoginPage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionTitle('Users'),
            _buildUserList(),
            _buildSectionTitle('Bookings'),
            _buildBookingList(),
          ],
        ),
      ),
    );
  }

  Padding _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pinkAccent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  ListView _buildUserList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          title: Text(user['name']),
          subtitle: Text(user['email']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _showUpdateUserDialog(user),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _showDeleteUserDialog(user['userid']),
              ),
            ],
          ),
        );
      },
    );
  }

  ListView _buildBookingList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return ListTile(
          title: Text(booking['name']),
          subtitle: Text(
              'Booking Date: ${booking['bookdate']} \nPackage: ${booking['facebeautypackage']}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _showUpdateBookingDialog(booking),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _showDeleteBookingDialog(booking['bookid']),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteBookingDialog(int bookid) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Booking'),
          content: Text('Are you sure you want to delete this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _dbHelper.deleteBeautyBook(bookid);
                Navigator.pop(context);
                _fetchBookings();
                _showConfirmationDialog('Booking deleted successfully!');
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteUserDialog(int userid) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete this user and their bookings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Delete all bookings associated with the user first
              await _dbHelper.deleteBeautyBook(userid);

              // Then delete the user
              await _dbHelper.deleteUser(userid);

              Navigator.pop(context);
              _fetchUsers();
              _fetchBookings(); // Refresh bookings list
              _showConfirmationDialog('User and their bookings deleted successfully!');
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );
}


  void _showUpdateUserDialog(Map<String, dynamic> user) {
    final TextEditingController nameController = TextEditingController(text: user['name']);
    final TextEditingController emailController = TextEditingController(text: user['email']);
    final TextEditingController phoneController = TextEditingController(text: user['phone']);
    final TextEditingController usernameController = TextEditingController(text: user['username']);
    final TextEditingController passwordController = TextEditingController(text: user['password']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update User'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(nameController, 'Name'),
                _buildTextField(emailController, 'Email', keyboardType: TextInputType.emailAddress),
                _buildTextField(phoneController, 'Phone', keyboardType: TextInputType.phone),
                _buildTextField(usernameController, 'Username'),
                _buildTextField(passwordController, 'Password'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_validateUserInputs(nameController, emailController, phoneController, usernameController, passwordController)) {
                  final updatedUser = {
                    'name': nameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'username': usernameController.text,
                    'password': passwordController.text,
                  };
                  await _dbHelper.updateUser(updatedUser, user['userid']);
                  Navigator.pop(context);
                  _fetchUsers();
                  _showConfirmationDialog('User details updated successfully!');
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  bool _validateUserInputs(TextEditingController nameController, TextEditingController emailController, TextEditingController phoneController, TextEditingController usernameController, TextEditingController passwordController) {
    if (nameController.text.isEmpty || emailController.text.isEmpty || phoneController.text.isEmpty || usernameController.text.isEmpty || passwordController.text.isEmpty) {
      _showErrorDialog('All fields are required.');
      return false;
    }
    return true;
  }

  TextField _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
    );
  }
}
