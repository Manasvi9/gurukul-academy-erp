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
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFE4E1).withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFE4E1).withValues(alpha: 0.5),
              ),
            ),
          ),
          SafeArea(
            child: child,
          ),
        ],
      ),
    );
  }
}
