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
  bool canEditRating = true;
  bool ratingSubmitted = false;

  @override
  void initState() {
    super.initState();
    currentRating = widget.initialRating; // Use initialRating here
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (index) => IconButton(
              onPressed: canEditRating
                  ? () {
                      int newRating = index + 1;
                      setState(() {
                        currentRating = newRating;
                      });
                    }
                  : null,
              icon: Icon(
                index < currentRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: canEditRating
                ? () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm Rating'),
                          content: Text('Do you want to save your rating?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Update Firestore with the new rating
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('ServiceBook')
                                      .doc(widget.serviceDocumentId)
                                      .update({'starsrate': currentRating});

                                  widget.onRatingChanged(currentRating);

                                  // Close the confirmation dialog
                                  Navigator.of(context).pop();

                                  // Disable further rating changes
                                  setState(() {
                                    canEditRating = false;
                                  });

                                  // Show a thank-you message
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Thank You!'),
                                        content: Text(
                                            'Your feedback has been saved.'),
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
                              child: Text(
                                'Save',
                                style: TextStyle(
                                    fontSize:
                                        16.0), // Adjust the font size here
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                : null,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Color.fromARGB(255, 59, 138, 207)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            child: Text(
              'Submit Rating',
              style: TextStyle(fontSize: 15.0), // Adjust the font size here
            ),
          ),
        ),
      ],
    );
  }
}
