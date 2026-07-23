import 'package:flutter/material.dart';

final class LoginBackground extends StatelessWidget {
  const LoginBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 300),
            painter: _WavePainter(),
          ),
          SafeArea(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Soft Peach Gradient: #FFDAB9 to #FFEFDB
    final gradient = LinearGradient(
      colors: [
        const Color(0xFFFFDAB9).withValues(alpha: 0.6),
        const Color(0xFFFFEFDB).withValues(alpha: 0.4),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height * 0.7,);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.4, size.width, size.height * 0.6,);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
