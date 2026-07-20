import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
    required this.logo,
  });

  final Widget logo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Logo Container
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: SizedBox(
            width: 54,
            height: 54,
            child: logo,
          ),
        ),

        const SizedBox(height: 28),

        Text(
          'Welcome Back',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
            letterSpacing: -.3,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Sign in to continue to',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Gurukul Academy ERP',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFFD4A017),
            letterSpacing: .2,
          ),
        ),
      ],
    );
  }
}