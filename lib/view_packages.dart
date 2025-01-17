import 'package:flutter/material.dart';

class ViewPackagesPage extends StatelessWidget {
  // Sample data for beauty packages with detailed pricing
  final List<Map<String, dynamic>> packages = [
    {
      'name': 'Facial Treatment',
      'Price': 50.0,
      'description': 'A rejuvenating facial treatment to refresh your skin.',
      'image': 'assets/1.JPG',
    },
    {
      'name': 'Hair Treatment',
      'Price': 70.0,
      'description': 'A nourishing treatment for your hair.',
      'image': 'assets/2.JPG',
    },
    {
      'name': 'Body Massage',
      'Price': 80.0,
      'description': 'A relaxing body massage to relieve stress.',
      'image': 'assets/3.JPG',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beauty Packages')),
      body: ListView.builder(
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final package = packages[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: Image.asset(
                package['image'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 50);
                },
              ),
              title: Text(package['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price: RM${package['Price'].toStringAsFixed(2)}'),
                ],
              ),
              onTap: () {
                // Show detailed view in a dialog
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(package['name']),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            package['image'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 100);
                            },
                          ),
                          const SizedBox(height: 10),
                          Text('Price: RM${package['Price'].toStringAsFixed(2)}'),
                          const SizedBox(height: 10),
                          Text(package['description']),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
