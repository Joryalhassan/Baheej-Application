import 'package:flutter/material.dart';

class CustomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.shader = LinearGradient(
      colors: [
        Colors.pink,
        Colors.blue,
        Colors.white,
      ],
      stops: [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height));

    var path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.6,
      size.width * 0.5,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.4,
      size.width,
      size.height * 0.5,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class MyWaveContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: CustomPaint(
        painter: CustomWavePainter(),
      ),
    );
  }
}
