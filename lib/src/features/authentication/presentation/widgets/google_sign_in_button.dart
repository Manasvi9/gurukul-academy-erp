import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    this.onPressed,
    this.label = 'Sign in with Google',
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: onPressed == null ? Colors.grey.shade100 : Colors.white,
          elevation: 0,
          side: BorderSide(
            color: Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: SizedBox(
          width: 24,
          height: 24,
          child: Image.asset('assets/images/google.jpg', 
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata)),
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: onPressed == null ? Colors.grey : const Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }
}