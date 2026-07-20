import 'package:flutter/material.dart';

final class AnimatedGoldLoader extends StatefulWidget {
  const AnimatedGoldLoader({super.key});

  @override
  State<AnimatedGoldLoader> createState() => _AnimatedGoldLoaderState();
}

class _AnimatedGoldLoaderState extends State<AnimatedGoldLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return CustomPaint(
              painter: _LoaderPainter(_controller.value),
            );
          },
        ),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  final double progress;

  _LoaderPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..color = const Color(0xffE8E8E8);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(20),
      ),
      background,
    );

    const segmentWidth = 40.0;

    final x = (size.width + segmentWidth) * progress - segmentWidth;

    final rect = Rect.fromLTWH(
      x,
      0,
      segmentWidth,
      size.height,
    );

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xffB8860B),
          Color(0xffD4AF37),
          Color(0xffFFD54F),
        ],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(20),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LoaderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}