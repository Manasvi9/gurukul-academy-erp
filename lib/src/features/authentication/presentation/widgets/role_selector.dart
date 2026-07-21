import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/auth_role.dart';

final class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  final AuthRole selectedRole;
  final ValueChanged<AuthRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<AuthRole>(
      // ignore: deprecated_member_use
      value: selectedRole,
      isExpanded: true,
      menuMaxHeight: 320,
      borderRadius: BorderRadius.circular(18),
      elevation: 6,
      dropdownColor: Colors.white,

      icon: const Icon(
        Icons.expand_more_rounded,
        color: AppColors.navy,
        size: 24,
      ),

      decoration: InputDecoration(
        labelText: 'Select Role',

        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.navy,
            width: 1.6,
          ),
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),

      style: theme.textTheme.bodyLarge?.copyWith(
        color: const Color(0xFF1F2937),
        fontWeight: FontWeight.w600,
      ),

      items: AuthRole.values.map((role) {
        return DropdownMenuItem<AuthRole>(
          value: role,
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForRole(role),
                  size: 20,
                  color: AppColors.navy,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  role.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),

      selectedItemBuilder: (_) {
        return AuthRole.values.map((role) {
          return Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForRole(role),
                  size: 20,
                  color: AppColors.navy,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  role.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        }).toList();
      },

      onChanged: (role) {
        if (role != null) {
          onChanged(role);
        }
      },
    );
  }

  IconData _iconForRole(AuthRole role) {
    return switch (role) {
      AuthRole.systemAdmin => Icons.admin_panel_settings_outlined,
      AuthRole.director => Icons.apartment_outlined,
      AuthRole.principal => Icons.school_outlined,
      AuthRole.teacher => Icons.person_outline_rounded,
      AuthRole.parent => Icons.people_outline_rounded,
      AuthRole.student => Icons.face_outlined,
    };
  }
}