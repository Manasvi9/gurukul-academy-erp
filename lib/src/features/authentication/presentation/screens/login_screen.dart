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
import '../widgets/login_background.dart';
import '../widgets/or_divider.dart';

final class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

final class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

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
          SnackBar(
            content: Text(message),
          ),
        );
      }
    });

    return LoginBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ResponsivePage(
            maxWidth: 390,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF102A63),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue to Gurukul Academy',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _identifierController,
                        decoration: InputDecoration(
                          hintText: 'Email / Mobile',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: const Icon(Icons.visibility_off_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading ? null : _handleForgotPassword,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Color(0xFF102A63)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF102A63),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading ? null : _submit,
                          child: Text(isLoading ? 'Signing In...' : 'Sign In'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const OrDivider(),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Image.asset('assets/images/logo.png', width: 20),
                  label: const Text('Sign in with Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  '© 2026 Gurukul Academy',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final controller = ref.read(authControllerProvider.notifier);

    // Assuming a default role or handled differently now
    final credentials = controller.buildCredentials(
      role: AuthRole.systemAdmin,
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
