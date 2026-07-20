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
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.navy,
      ),

      decoration: InputDecoration(
        labelText: 'Select Role',

        filled: true,
        fillColor: Colors.white,

        prefixIcon: const Icon(
          Icons.person_outline_rounded,
          color: Color(0xFF6B7280),
        ),

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
      AuthRole.systemAdmin => Icons.admin_panel_settings_rounded,
      AuthRole.director => Icons.business_center_rounded,
      AuthRole.principal => Icons.school_rounded,
      AuthRole.teacher => Icons.menu_book_rounded,
      AuthRole.parent => Icons.family_restroom_rounded,
      AuthRole.student => Icons.badge_rounded,
    };
  }
}