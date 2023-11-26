import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final Color? color;
  final bool bold;

  AppText({required this.text, this.color, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: color ?? Colors.black,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
