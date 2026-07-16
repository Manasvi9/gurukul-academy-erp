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
import '../widgets/role_selector.dart';

final class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

final class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthRole _selectedRole = AuthRole.systemAdmin;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.authenticating;

    ref.listen(authControllerProvider, (_, next) {
      final message = next.message;
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: ResponsivePage(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Gurukul Academy',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Sign in to continue.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Login As',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    RoleSelector(
                      selectedRole: _selectedRole,
                      onChanged: (role) {
                        setState(() {
                          _selectedRole = role;
                          _identifierController.clear();
                          _passwordController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _identifierController,
                      keyboardType: _keyboardTypeForRole(_selectedRole),
                      textInputAction: TextInputAction.next,
                      validator: _identifierValidator,
                      decoration: InputDecoration(
                        labelText: _identifierLabel(_selectedRole),
                        prefixIcon: Icon(_identifierIcon(_selectedRole)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PasswordTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      validator: Validators.password,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading ? null : _handleForgotPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: isLoading ? null : _submit,
                      icon: isLoading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
                      label: Text(isLoading ? 'Signing in...' : 'Sign in'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _identifierValidator(String? value) {
    return switch (_selectedRole) {
      AuthRole.systemAdmin ||
      AuthRole.director ||
      AuthRole.principal ||
      AuthRole.teacher =>
        Validators.email(value),
      AuthRole.parent => Validators.mobileNumber(value),
      AuthRole.student => Validators.srNumber(value),
    };
  }

  TextInputType _keyboardTypeForRole(AuthRole role) {
    return switch (role) {
      AuthRole.systemAdmin ||
      AuthRole.director ||
      AuthRole.principal ||
      AuthRole.teacher =>
        TextInputType.emailAddress,
      AuthRole.parent => TextInputType.phone,
      AuthRole.student => TextInputType.text,
    };
  }

  String _identifierLabel(AuthRole role) {
    return switch (role) {
      AuthRole.systemAdmin ||
      AuthRole.director ||
      AuthRole.principal ||
      AuthRole.teacher =>
        'Email',
      AuthRole.parent => 'Mobile Number',
      AuthRole.student => 'SR Number',
    };
  }

  IconData _identifierIcon(AuthRole role) {
    return switch (role) {
      AuthRole.systemAdmin ||
      AuthRole.director ||
      AuthRole.principal ||
      AuthRole.teacher =>
        Icons.email_outlined,
      AuthRole.parent => Icons.phone_android,
      AuthRole.student => Icons.badge_outlined,
    };
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final controller = ref.read(authControllerProvider.notifier);
    final credentials = controller.buildCredentials(
      role: _selectedRole,
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
    );
    final success = await controller.login(credentials);
    if (!mounted || !success) {
      return;
    }

    final state = ref.read(authControllerProvider);
    if (state.mustChangePassword) {
      context.go(AppRoute.changePassword.path);
      return;
    }

    context.go(_dashboardPathForRole(state.user!.role));
  }

  Future<void> _handleForgotPassword() async {
    if (!_selectedRole.usesSupabaseAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please contact the school admin to reset this password.',
          ),
        ),
      );
      return;
    }

    final emailError = Validators.email(_identifierController.text);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError)),
      );
      return;
    }

    final sent = await ref
        .read(authControllerProvider.notifier)
        .sendStaffPasswordResetEmail(_identifierController.text.trim());
    if (!mounted || !sent) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent.')),
    );
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
