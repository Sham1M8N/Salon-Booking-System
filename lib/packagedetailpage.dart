import 'package:flutter/material.dart';
import 'paymentpage.dart';

class PackageDetailPage extends StatelessWidget {
  final Map<String, dynamic> package;
  final List<Map<String, dynamic>> selectedPackages;
  final int userId;
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final DateTime bookingDate;
  final String serviceDuration;
  final String additionalRequests;
  final int numberOfGuests;

  const PackageDetailPage({
    Key? key,
    required this.package,
    required this.userId,
    required this.selectedPackages,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.bookingDate,
    required this.serviceDuration,
    required this.additionalRequests,
    required this.numberOfGuests,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(package['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display package image
              Image.asset(
                package['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 100);
                },
              ),
              const SizedBox(height: 10),

              // Display package name
              Text(
                package['name'],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Display package price
              Text(
                'RM${package['price'].toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
              const SizedBox(height: 10),

              // Display package description
              Text(
                package['description'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Display techniques
              const Text(
                'Techniques:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...package['techniques'].map<Widget>((technique) {
                return Text('- $technique');
              }).toList(),
              const SizedBox(height: 20),

              // Display benefits
              const Text(
                'Benefits:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...package['benefits'].map<Widget>((benefit) {
                return Text('- $benefit');
              }).toList(),
              const SizedBox(height: 20),

              // Button to navigate to PaymentPage
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(
                        userId: userId, // Pass userId to PaymentPage
                        selectedPackages: selectedPackages,
                        packageNames: selectedPackages
                            .map((package) => package['name'] as String)
                            .toList(),
                        packagePrices: selectedPackages
                            .map((package) => package['price'] as double)
                            .toList(),
                        userName: name,
                        userPhoneNumber: phoneNumber,
                        userEmail: email,
                        bookingDate: bookingDate,
                        serviceDuration: serviceDuration,
                        additionalRequests: additionalRequests,
                        numberOfGuests: numberOfGuests,
                      ),
                    ),
                  );
                },
                child: const Text('Proceed to Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
