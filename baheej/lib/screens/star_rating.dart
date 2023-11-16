import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;

  StarRating({required this.initialRating, required this.onRatingChanged});

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
          onPressed: () {
            double newRating = index + 1.0;
            setState(() {
              currentRating = newRating;
            });
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
