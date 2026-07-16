import 'package:flutter/material.dart';

import '../../domain/entities/auth_role.dart';

final class RoleSelector extends StatelessWidget {
  const RoleSelector({
    required this.selectedRole,
    required this.onChanged,
    super.key,
  });

  final AuthRole selectedRole;
  final ValueChanged<AuthRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<AuthRole>(
        segments: AuthRole.values.map((role) {
          return ButtonSegment<AuthRole>(
            value: role,
            label: Text(role.label),
          );
        }).toList(),
        selected: {selectedRole},
        onSelectionChanged: (selection) {
          onChanged(selection.single);
        },
        showSelectedIcon: false,
        multiSelectionEnabled: false,
      ),
    );
  }
}
