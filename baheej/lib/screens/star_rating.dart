import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StarRating extends StatefulWidget {
  final String serviceDocumentId;
  final void Function(int) onRatingChanged;
  final int initialRating; // Add this line with a default value

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
  bool hasRated = false;

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
          onPressed: hasRated
              ? null // Disable button if the user has already rated
              : () async {
                  int newRating = index + 1;
                  setState(() {
                    currentRating = newRating;
                    hasRated = true;
                  });

                  try {
                    // Update Firestore with the new rating
                    await FirebaseFirestore.instance
                        .collection('ServiceBook')
                        .doc(widget.serviceDocumentId)
                        .update({'starsrate': newRating}).then((_) {
                      print('Document ID: ${widget.serviceDocumentId}');
                    }).catchError((error) {
                      print('Error updating rating: $error');
                    });

                    widget.onRatingChanged(newRating);

                    // Show a confirmation message using a Dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Thank You!'),
                          content: Text('Your feedback has been submitted.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } catch (e) {
                    // Handle Firestore update error
                    print('Error updating rating: $e');
                  }
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
