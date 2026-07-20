import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../shared/widgets/animated_gold_loader.dart';
import '../../domain/entities/auth_role.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state.dart';

final class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

final class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final authState = ref.read(authControllerProvider);

    if (authState.status == AuthStatus.authenticating ||
        authState.status == AuthStatus.initial) {
      Future.delayed(const Duration(milliseconds: 500), _navigate);
      return;
    }

    if (!authState.isAuthenticated) {
      context.go(AppRoute.login.path);
      return;
    }

    if (authState.mustChangePassword) {
      context.go(AppRoute.changePassword.path);
      return;
    }

    switch (authState.user!.role) {
      case final AuthRole role:
        context.go(_dashboardPath(role));
    }
  }

  String _dashboardPath(AuthRole role) {
    switch (role) {
      case AuthRole.systemAdmin:
        return AppRoute.adminDashboard.path;
      case AuthRole.director:
        return AppRoute.directorDashboard.path;
      case AuthRole.principal:
        return AppRoute.principalDashboard.path;
      case AuthRole.teacher:
        return AppRoute.teacherDashboard.path;
      case AuthRole.parent:
        return AppRoute.parentDashboard.path;
      case AuthRole.student:
        return AppRoute.studentDashboard.path;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Upper half: School Building
            Expanded(
              flex: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/school_login.png',
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Lower half: Info
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'GURUKUL',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF102A63),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    'ACADEMY',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFD4AF37),
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Knowledge • Discipline • Growth',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  const AnimatedGoldLoader(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
