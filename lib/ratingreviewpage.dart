import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:face_salon_beauty_booking/Authentication/login.dart';

class RatingReviewPage extends StatefulWidget {
  final String packageName;
  final Function(double, String) onReviewSubmitted;
  final List<Map<String, dynamic>> existingReviews;

  const RatingReviewPage({
    required this.packageName,
    required this.onReviewSubmitted,
    required this.existingReviews,
    super.key,
    required double totalPayment,
  });

  @override
  _RatingReviewPageState createState() => _RatingReviewPageState();
}

class _RatingReviewPageState extends State<RatingReviewPage> {
  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    // Initialize with existing reviews
    _reviews = List.from(widget.existingReviews);
  }

  void _submitReview() {
    if (_reviewController.text.isNotEmpty && _rating > 0) {
      // Create a new review
      final newReview = {
        'rating': _rating,
        'comment': _reviewController.text,
      };

      // Call the onReviewSubmitted callback
      widget.onReviewSubmitted(_rating, _reviewController.text);

      // Add the new review to the list
      setState(() {
        _reviews.add(newReview);
        _reviewController.clear();
        _rating = 0.0;
      });
    } else {
      // Show an error message if the review or rating is not valid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and a review.')),
      );
    }
  }

  void _logout() {
    // Navigate to the Login Page and clear navigation stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()), // Replace with your Login Page widget
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate & Review ${widget.packageName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // Call the logout function
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rate this Package', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            RatingBar(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 40.0,
              ratingWidget: RatingWidget(
                full: const Icon(Icons.star, color: Colors.amber),
                half: const Icon(Icons.star_half, color: Colors.amber),
                empty: const Icon(Icons.star_border, color: Colors.amber),
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                labelText: 'Write your review',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitReview,
              child: const Text('Submit Review'),
            ),
            const SizedBox(height: 20),
            const Text('Existing Reviews:', style: TextStyle(fontSize: 20)),
            Expanded(
              child: _reviews.isEmpty
                  ? const Center(child: Text('No reviews yet.'))
                  : ListView.builder(
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Rating: ${_reviews[index]['rating']}'),
                          subtitle: Text(_reviews[index]['comment']),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
