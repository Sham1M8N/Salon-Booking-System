import 'package:face_salon_beauty_booking/Authentication/userlistpage.dart';
import 'package:flutter/material.dart';
import 'paymentpage.dart';

class PackageSelectionPage extends StatefulWidget {
  final int userId;
  final String name;
  final String phoneNumber;
  final String email;
  final DateTime bookingDate;
  final String serviceDuration;
  final String additionalRequests;
  final int numberOfGuests;
  final List<Map<String, dynamic>> selectedPackages;
  final Map<String, dynamic>? currentPackage;

  PackageSelectionPage({
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.bookingDate,
    required this.serviceDuration,
    required this.additionalRequests,
    required this.numberOfGuests,
    required this.selectedPackages,
    required this.currentPackage,
  });

  @override
  _PackageSelectionPageState createState() => _PackageSelectionPageState();
}

class _PackageSelectionPageState extends State<PackageSelectionPage> {
  final List<Map<String, dynamic>> packages = [
    {
      'name': 'Facial Treatment',
      'price': 50.0,
      'image': 'assets/1.JPG',
      'description': 'A rejuvenating facial treatment to refresh your skin.',
    },
    {
      'name': 'Hair Treatment',
      'price': 70.0,
      'image': 'assets/2.JPG',
      'description': 'A nourishing treatment for your hair.',
    },
    {
      'name': 'Body Massage',
      'price': 80.0,
      'image': 'assets/3.JPG',
      'description': 'A relaxing body massage to relieve stress.',
    },
  ];

  late List<Map<String, dynamic>> selectedPackages;

  @override
  void initState() {
    super.initState();
    selectedPackages = List.from(widget.selectedPackages);
    print(
        'PackageSelectionPage initialized with selectedPackages: $selectedPackages');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Beauty Packages')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
              ),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final package = packages[index];
                final isSelected = selectedPackages.contains(package);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedPackages.remove(package);
                        print('Package deselected: ${package['name']}');
                      } else {
                        selectedPackages.add(package);
                        print('Package selected: ${package['name']}');
                      }
                      print('Current selectedPackages: $selectedPackages');
                    });
                  },
                  child: Card(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              package['image'],
                              fit: BoxFit.cover,
                              height: 100,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image,
                                    size: 100);
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                package['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text('RM${package['price'].toStringAsFixed(2)}'),
                          ],
                        ),
                        if (isSelected)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(Icons.check_circle,
                                color: Colors.green, size: 30),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: selectedPackages.isNotEmpty
                      ? () {
                          // Pass selectedPackages' package names and prices
                          List<String> packageNames = [];
                          List<double> packagePrices = [];

                          for (var package in selectedPackages) {
                            packageNames.add(package['name']);
                            packagePrices.add(package['price']);
                          }

                          print('Navigating to PaymentPage with:');
                          print('Package Names: $packageNames');
                          print('Package Prices: $packagePrices');

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                userId: widget.userId,
                                selectedPackages: selectedPackages,
                                packageNames: packageNames,
                                packagePrices: packagePrices,
                                userName: widget.name,
                                userPhoneNumber: widget.phoneNumber,
                                userEmail: widget.email,
                                bookingDate: widget.bookingDate,
                                serviceDuration: widget.serviceDuration,
                                additionalRequests: widget.additionalRequests,
                                numberOfGuests: widget.numberOfGuests,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Proceed to Payment'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfilePage(
                          currentUserId:
                              widget.userId, // Pass the current user ID
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Profile'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
