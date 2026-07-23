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
import '../widgets/google_sign_in_button.dart';
import '../widgets/login_background.dart';
import '../widgets/or_divider.dart';
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

    return LoginBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ResponsivePage(
            maxWidth: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Image.asset('assets/images/logo.png', width: 84),
                const SizedBox(height: 24),
                Text('Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF102A63),
                      letterSpacing: -0.5,
                    ),),
                const SizedBox(height: 8),
                const Text('Sign in to continue to Gurukul Academy',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),),
                const SizedBox(height: 32),
                
                // Login Form Card
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Login As',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                              ),),
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _identifierController,
                            keyboardType: _keyboardTypeForRole(_selectedRole),
                            textInputAction: TextInputAction.next,
                            validator: _identifierValidator,
                            decoration: InputDecoration(
                              labelText: _identifierLabel(_selectedRole),
                              prefixIcon: Icon(_identifierIcon(_selectedRole), size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          PasswordTextField(
                            controller: _passwordController,
                            labelText: 'Password',
                            validator: Validators.password,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isLoading ? null : _handleForgotPassword,
                              child: const Text('Forgot password?', style: TextStyle(color: Color(0xFF102A63))),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 50,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF102A63),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: isLoading ? null : _submit,
                              child: Text(isLoading ? 'Signing in...' : 'Sign in'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const OrDivider(),
                const SizedBox(height: 24),
                GoogleSignInButton(
                  label: 'Coming Soon',
                  onPressed: null,
                ),
              ],
            ),
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
