import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/validation/validators.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../domain/entities/auth_role.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state.dart';
import '../widgets/password_text_field.dart';

final class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

final class _ChangePasswordScreenState
    extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.authenticating;

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SafeArea(
        child: ResponsivePage(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  'Create a new password',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'You must change your initial password before continuing.',
                ),
                const SizedBox(height: AppSpacing.lg),
                PasswordTextField(
                  controller: _currentPasswordController,
                  labelText: 'Current Password',
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordTextField(
                  controller: _newPasswordController,
                  labelText: 'New Password',
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm New Password',
                  validator: _confirmPasswordValidator,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: isLoading ? null : _submit,
                  icon: isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_reset),
                  label: Text(isLoading ? 'Updating...' : 'Update password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _confirmPasswordValidator(String? value) {
    final passwordError = Validators.password(value);
    if (passwordError != null) {
      return passwordError;
    }

    if (value != _newPasswordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success =
        await ref.read(authControllerProvider.notifier).changePassword(
              currentPassword: _currentPasswordController.text,
              newPassword: _newPasswordController.text,
            );
    if (!mounted || !success) {
      return;
    }

    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      context.go(AppRoute.login.path);
      return;
    }
    context.go(_dashboardPathForRole(user.role));
  }

  String _dashboardPathForRole(AuthRole role) {
    return switch (role) {
      AuthRole.systemAdmin => AppRoute.adminDashboard.path,
      AuthRole.director => AppRoute.directorDashboard.path,
      AuthRole.principal => AppRoute.principalDashboard.path,
      AuthRole.teacher => AppRoute.teacherDashboard.path,
      AuthRole.parent => AppRoute.parentDashboard.path,
      AuthRole.student => AppRoute.studentDashboard.path,
    };
  }
}
