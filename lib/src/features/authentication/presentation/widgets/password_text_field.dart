import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_text_field.dart';

final class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final FormFieldValidator<String> validator;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

final class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.labelText,
      validator: widget.validator,
      obscureText: _obscureText,
      textInputAction: TextInputAction.done,
      prefixIcon: Icons.lock_outline_rounded,
      suffixIcon: IconButton(
        splashRadius: 20,
        tooltip: _obscureText
            ? 'Show password'
            : 'Hide password',
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            key: ValueKey(_obscureText),
            color: const Color(0xFF6B7280),
          ),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}