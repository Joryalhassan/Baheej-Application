import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*class StarRating extends StatefulWidget {
  final double initialRating;
  final String serviceDocumentId; // Add the service document ID
  final void Function(double) onRatingChanged;

  StarRating({
    required this.initialRating,
    required this.serviceDocumentId,
    required this.onRatingChanged,
  });

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late double currentRating;

  @override
  void initState() {
    super.initState();
    currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => IconButton(
          onPressed: () async {
            double newRating = index + 1.0;
            setState(() {
              currentRating = newRating;
            });

            // Update Firestore with the new rating
            await FirebaseFirestore.instance
                .collection('ServiceBook')
                .doc(widget.serviceDocumentId)
                .update({'userRating': newRating});

            widget.onRatingChanged(newRating);
          },
          icon: Icon(
            index < currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
        ),
      ),
    );
  }
}*/
// Import necessary packages and libraries

class StarRating extends StatefulWidget {
  final String serviceDocumentId;
  final void Function(int) onRatingChanged;
  final int initialRating; // Add this line

  StarRating({
    required this.serviceDocumentId,
    required this.onRatingChanged,
    this.initialRating = 0, // Add this line with a default value
  });

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late int currentRating;

  @override
  void initState() {
    super.initState();
    currentRating = widget.initialRating; // Use initialRating here
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => IconButton(
          onPressed: () async {
            int newRating = index + 1;
            setState(() {
              currentRating = newRating;
            });

            // Update Firestore with the new rating
            await FirebaseFirestore.instance
                .collection('ServiceBook')
                .doc(widget.serviceDocumentId)
                .update({'starsrate': newRating});

            widget.onRatingChanged(newRating);
          },
          icon: Icon(
            index < currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
        ),
      ),
    );
  }
}
