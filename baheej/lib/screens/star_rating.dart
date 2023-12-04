import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StarRating extends StatefulWidget {
  final String serviceDocumentId;
  final void Function(int) onRatingChanged;
  final int initialRating;

  StarRating({
    required this.serviceDocumentId,
    required this.onRatingChanged,
    this.initialRating = 0,
  });

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late int currentRating;

  @override
  void initState() {
    super.initState();
    currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.max, // Adjusted mainAxisSize
        mainAxisAlignment: MainAxisAlignment.center, // Center the content
        children: List.generate(
          5,
          (index) => IconButton(
            onPressed: () async {
              int newRating = index + 1;
              setState(() {
                currentRating = newRating;
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
              _getFaceIcon(index),
              color: currentRating > index
                  ? (index == 2
                      ? Color.fromARGB(217, 233, 184, 8) // Neutral (Orange)
                      : (index == 0
                          ? const Color.fromARGB(255, 255, 17, 0) // Dark Red
                          : (index == 1
                              ? Color.fromARGB(255, 255, 136, 0) // Light Red
                              : (index == 3
                                  ? Colors.lightGreen // Light Green
                                  : Colors.green) // Dark Green
                          )))
                  : Colors.black,
              size: 40.0, // Customize the size as needed
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFaceIcon(int index) {
    switch (index) {
      case 0:
        return Icons.sentiment_very_dissatisfied; // Very Sad
      case 1:
        return Icons.sentiment_dissatisfied; // Sad
      case 2:
        return Icons.sentiment_neutral; // Neutral
      case 3:
        return Icons.sentiment_satisfied; // Satisfied
      case 4:
        return Icons.sentiment_very_satisfied; // Very Satisfied
      default:
        return Icons.sentiment_neutral;
    }
  }
}