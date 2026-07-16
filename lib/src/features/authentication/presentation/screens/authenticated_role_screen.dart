import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../domain/entities/auth_role.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state.dart';

final class AuthenticatedRoleScreen extends ConsumerWidget {
  const AuthenticatedRoleScreen({
    required this.expectedRole,
    super.key,
  });

  final AuthRole expectedRole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('${expectedRole.label} Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: authState.status == AuthStatus.authenticating
                ? null
                : () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsivePage(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user?.displayName ?? expectedRole.label}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Authentication is active. Feature dashboards will be implemented in their own approved phases.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
