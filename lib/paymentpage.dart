import 'package:face_salon_beauty_booking/ratingreviewpage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'packageselection.dart';
import 'sqlite/sqlite.dart'; // Ensure this matches your database helper's path

class PaymentPage extends StatefulWidget {
  final int userId;
  final List<Map<String, dynamic>> selectedPackages;
  final List<String> packageNames;
  final List<double> packagePrices;
  final String userName;
  final String userPhoneNumber;
  final String userEmail;
  DateTime bookingDate;
  String serviceDuration;
  String additionalRequests;
  int numberOfGuests;

  PaymentPage({
    Key? key,
    required this.userId,
    required this.selectedPackages,
    required this.packageNames,
    required this.packagePrices,
    required this.userName,
    required this.userPhoneNumber,
    required this.userEmail,
    required this.bookingDate,
    required this.serviceDuration,
    required this.additionalRequests,
    required this.numberOfGuests,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  double _finalAmount = 0.0;
  Map<String, dynamic>? _userInfo;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _discountCode = '';
  String _errorMessage = '';
  double _discountAmount = 0.0;
  bool _isDiscountUsed = false;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _calculateFinalAmount();
  }

  Future<void> _fetchUserInfo() async {
    final dbHelper = DatabaseHelper();
    final user = await dbHelper.getUserById(widget.userId);
    setState(() {
      _userInfo = user;
      _addressController.text = _userInfo?['address'] ?? '';
    });
  }

  void _calculateFinalAmount() {
    double basePrice = widget.packagePrices.fold(
          0.0,
          (sum, price) => sum + price,
        ) *
        widget.numberOfGuests;
    _finalAmount = basePrice - _discountAmount;
  }

  void _removePackage(int index) {
    setState(() {
      widget.selectedPackages.removeAt(index);
      widget.packageNames.removeAt(index);
      widget.packagePrices.removeAt(index);
    });
    _calculateFinalAmount();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Package removed successfully')),
    );
  }

  void _changePackage(int index) async {
    final currentPackage = {
      'name': widget.packageNames[index],
      'price': widget.packagePrices[index],
    };

    final updatedPackage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackageSelectionPage(
          userId: widget.userId,
          name: widget.userName,
          phoneNumber: widget.userPhoneNumber,
          email: widget.userEmail,
          bookingDate: widget.bookingDate,
          serviceDuration: widget.serviceDuration,
          additionalRequests: widget.additionalRequests,
          numberOfGuests: widget.numberOfGuests,
          selectedPackages: widget.selectedPackages,
          currentPackage: currentPackage,
        ),
      ),
    );

    if (updatedPackage != null) {
      setState(() {
        widget.selectedPackages[index] = updatedPackage;
        widget.packageNames[index] = updatedPackage['name'];
        widget.packagePrices[index] = updatedPackage['price'];
      });
      _calculateFinalAmount();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Package updated successfully')),
      );
    }
  }

  Future<void> _selectBookingDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime tomorrow = now
        .add(Duration(days: 1)); // Set the minimum selectable date to tomorrow

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tomorrow, // Start the date picker with tomorrow's date
      firstDate: tomorrow, // Prevent selecting today and past dates
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectBookingTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      // Check if the picked time is within the 10 AM to 5 PM range
      if (picked.hour >= 10 && picked.hour < 17) {
        setState(() {
          _selectedTime = picked;
        });
      } else {
        _showErrorDialog(
            'Please select a time between 10:00 AM and before 5:00 PM.');
      }
    }
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

  void _applyDiscount() {
    setState(() {
      _errorMessage = '';
      _discountCode = _discountController.text.trim();

      double basePrice = widget.packagePrices.fold(
        0.0,
        (sum, price) => sum + price * widget.numberOfGuests,
      );

      // Check if the discount code has already been used
      if (_discountCode.isNotEmpty) {
        if (_discountCode == 'DISCOUNT10') {
          if (_isDiscountUsed) {
            // If the discount is already used, show an error message and do nothing
            _errorMessage = 'Discount code already used';
          } else {
            // Apply the discount for the first time
            _discountAmount = basePrice * 0.1; // 10% discount
            _finalAmount = basePrice - _discountAmount;
            _isDiscountUsed = true; // Mark the discount code as used
          }
        } else {
          // Invalid discount code logic
          _errorMessage = 'Invalid discount code';
          _discountAmount = 0.0;
          _finalAmount = basePrice;
        }
      } else {
        // No discount code entered
        _discountAmount = 0.0;
        _finalAmount = basePrice;
      }
    });
  }

  void _navigateToRatingReviewPage() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your address.')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a booking date.')),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a booking time.')),
      );
      return;
    }

    if (widget.numberOfGuests <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Number of guests must be greater than 0.')),
      );
      return;
    }

    // Get the current date and time for the booking
    DateTime now = DateTime.now();
    String currentDate = DateFormat('yyyy-MM-dd').format(now);
    String currentTime =
        DateFormat('hh:mm a').format(now); // 12-hour format with a.m. or p.m.

    // Create the booking details map
    Map<String, dynamic> bookingDetails = {
      'userid': widget.userId,
      'bookdate': currentDate, // Use the current date
      'booktime':
          currentTime, // Use the current time in 12-hour format with a.m./p.m.
      'appointmentdate': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'appointmenttime': _selectedTime != null
          ? _selectedTime!.format(context)
          : 'No time selected',
      'facebeautypackage': widget.packageNames
          .join(', '), // Assuming multiple packages are selected
      'numguest': widget.numberOfGuests,
      'packageprice': _finalAmount,
    };

    // Save the booking details into the database
    final dbHelper = DatabaseHelper();
    int result = await dbHelper.createBeautyBook(bookingDetails);

    if (result > 0) {
      // If booking is successful, navigate to the RatingReviewPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RatingReviewPage(
            packageName: widget.packageNames.isNotEmpty
                ? widget.packageNames.first
                : 'No Package Selected',
            totalPayment: _finalAmount,
            onReviewSubmitted: (rating, comment) {
              print('Rating: $rating, Comment: $comment');
            },
            existingReviews: const [],
          ),
        ),
      );
    } else {
      // If booking fails, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save booking details.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _userInfo == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Information',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text('Name: ${_userInfo!['name']}'),
                    Text('Phone: ${_userInfo!['phone']}'),
                    Text('Email: ${_userInfo!['email']}'),
                    const SizedBox(height: 16),
                    const Text(
                      'Address:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'Enter your address',
                        border: OutlineInputBorder(),
                        errorText: _addressController.text.trim().isEmpty
                            ? 'Address is required'
                            : null,
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        setState(() {}); // Update the UI dynamically
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Booking Date:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(_selectedDate == null
                            ? 'No date chosen!'
                            : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectBookingDate(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Booking Time:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(_selectedTime == null
                            ? 'No time chosen!'
                            : _selectedTime!.format(context)),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () => _selectBookingTime(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Service Duration:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: widget.serviceDuration.isNotEmpty &&
                              ['2 hours', '3 hours', '4 hours']
                                  .contains(widget.serviceDuration)
                          ? widget.serviceDuration
                          : '2 hours', // Default value if invalid
                      items: <String>['2 hours', '3 hours', '4 hours']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          widget.serviceDuration = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Additional Requests:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      initialValue: widget.additionalRequests,
                      decoration: InputDecoration(
                        hintText: 'Enter additional requests',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        widget.additionalRequests = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Number of Guests:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      initialValue: widget.numberOfGuests.toString(),
                      decoration: const InputDecoration(
                        hintText: 'Enter number of guests',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          widget.numberOfGuests = int.tryParse(value) ??
                              1; // Default to 1 if invalid
                          _calculateFinalAmount(); // Recalculate final amount
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Discount Code:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      controller: _discountController,
                      decoration: InputDecoration(
                        hintText: 'Enter discount code',
                        border: OutlineInputBorder(),
                        errorText: _errorMessage.isEmpty ? null : _errorMessage,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _applyDiscount,
                      child: const Text('Apply Discount'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Packages:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.packageNames.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(widget.packageNames[index]),
                          subtitle: Text(
                              'RM${widget.packagePrices[index].toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _changePackage(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removePackage(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_discountAmount > 0) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Discount Applied: RM${_discountAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'RM${_finalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _navigateToRatingReviewPage,
                      child: const Text('Proceed to Payment'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
