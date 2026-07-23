import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../features/authentication/domain/entities/auth_role.dart';
import '../../features/authentication/presentation/providers/auth_providers.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final role = user?.role;

    final menuItems = _getMenuItems(role);

    return NavigationDrawer(
      selectedIndex: _getSelectedIndex(context, menuItems),
      onDestinationSelected: (index) {
        context.pop();
        context.go(menuItems[index].route.path);
      },
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Color(0xFF1A237E), // Dark Navy
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 32),
                  const SizedBox(width: 10),
                  const Text('Gurukul Academy', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  context.pop();
                  context.go(AppRoute.profile.path);
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.displayName ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(role?.label ?? '', style: const TextStyle(color: Color(0xFFFFC107), fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...menuItems.map((item) => NavigationDrawerDestination(
          icon: Icon(item.icon),
          label: Text(item.title),
        ),),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ),
      ],
    );
  }

  List<_MenuItem> _getMenuItems(AuthRole? role) {
    if (role == null) return [];

    final Map<AuthRole, List<_MenuItem>> menuMap = {
      AuthRole.systemAdmin: [
        _MenuItem('Dashboard', Icons.dashboard_rounded, AppRoute.adminDashboard),
        _MenuItem('User Management', Icons.manage_accounts_rounded, AppRoute.notFound),
        _MenuItem('Students', Icons.people_rounded, AppRoute.students),
        _MenuItem('Teachers', Icons.person_pin_rounded, AppRoute.teachers),
        _MenuItem('Attendance', Icons.event_available_rounded, AppRoute.students),
        _MenuItem('Examinations', Icons.quiz_rounded, AppRoute.exams),
        _MenuItem('Fees', Icons.payments_rounded, AppRoute.fees),
        _MenuItem('Timetable', Icons.calendar_month_rounded, AppRoute.timetable),
        _MenuItem('Notice Board', Icons.notifications_active_rounded, AppRoute.notFound),
        _MenuItem('Reports', Icons.analytics_rounded, AppRoute.notFound),
        _MenuItem('Academic Sessions', Icons.school_rounded, AppRoute.notFound),
        _MenuItem('Settings', Icons.settings_rounded, AppRoute.settings),
      ],
      AuthRole.director: [
        _MenuItem('Dashboard', Icons.dashboard_rounded, AppRoute.directorDashboard),
        _MenuItem('Students', Icons.people_rounded, AppRoute.students),
        _MenuItem('Teachers', Icons.person_pin_rounded, AppRoute.teachers),
        _MenuItem('Attendance', Icons.event_available_rounded, AppRoute.students),
        _MenuItem('Fees', Icons.payments_rounded, AppRoute.fees),
        _MenuItem('Examinations', Icons.quiz_rounded, AppRoute.exams),
        _MenuItem('Timetable', Icons.calendar_month_rounded, AppRoute.timetable),
        _MenuItem('Notice Board', Icons.notifications_active_rounded, AppRoute.notFound),
        _MenuItem('Reports', Icons.analytics_rounded, AppRoute.notFound),
        _MenuItem('Settings', Icons.settings_rounded, AppRoute.settings),
      ],
      AuthRole.principal: [
        _MenuItem('Dashboard', Icons.dashboard_rounded, AppRoute.principalDashboard),
        _MenuItem('Students', Icons.people_rounded, AppRoute.students),
        _MenuItem('Teachers', Icons.person_pin_rounded, AppRoute.teachers),
        _MenuItem('Attendance', Icons.event_available_rounded, AppRoute.students),
        _MenuItem('Fees', Icons.payments_rounded, AppRoute.fees),
        _MenuItem('Examinations', Icons.quiz_rounded, AppRoute.exams),
        _MenuItem('Timetable', Icons.calendar_month_rounded, AppRoute.timetable),
        _MenuItem('Notice Board', Icons.notifications_active_rounded, AppRoute.notFound),
        _MenuItem('Reports', Icons.analytics_rounded, AppRoute.notFound),
        _MenuItem('Settings', Icons.settings_rounded, AppRoute.settings),
      ],
      AuthRole.teacher: [
        _MenuItem('Dashboard', Icons.dashboard_rounded, AppRoute.teacherDashboard),
        _MenuItem('My Classes', Icons.class_rounded, AppRoute.classes),
        _MenuItem('Students', Icons.people_rounded, AppRoute.students),
        _MenuItem('Attendance', Icons.event_available_rounded, AppRoute.students),
        _MenuItem('Homework', Icons.book_rounded, AppRoute.homework),
        _MenuItem('Results', Icons.grade_rounded, AppRoute.exams),
        _MenuItem('Timetable', Icons.calendar_month_rounded, AppRoute.timetable),
        _MenuItem('Notice Board', Icons.notifications_active_rounded, AppRoute.notFound),
        _MenuItem('Profile', Icons.person_rounded, AppRoute.profile),
        _MenuItem('Settings', Icons.settings_rounded, AppRoute.settings),
      ],
      AuthRole.parent: [
        _MenuItem('Dashboard', Icons.dashboard_rounded, AppRoute.parentDashboard),
        _MenuItem('My Children', Icons.family_restroom_rounded, AppRoute.students),
        _MenuItem('Attendance', Icons.event_available_rounded, AppRoute.students),
        _MenuItem('Homework', Icons.book_rounded, AppRoute.homework),
        _MenuItem('Fees', Icons.payments_rounded, AppRoute.fees),
        _MenuItem('Timetable', Icons.calendar_month_rounded, AppRoute.timetable),
        _MenuItem('Results', Icons.grade_rounded, AppRoute.exams),
        _MenuItem('Notice Board', Icons.notifications_active_rounded, AppRoute.notFound),
        _MenuItem('Profile', Icons.person_rounded, AppRoute.profile),
        _MenuItem('Settings', Icons.settings_rounded, AppRoute.settings),
      ],
      AuthRole.student: [
        _MenuItem('Dashboard', Icons.dashboard_rounded, AppRoute.studentDashboard),
        _MenuItem('Attendance', Icons.event_available_rounded, AppRoute.students),
        _MenuItem('Homework', Icons.book_rounded, AppRoute.homework),
        _MenuItem('Timetable', Icons.calendar_month_rounded, AppRoute.timetable),
        _MenuItem('Results', Icons.grade_rounded, AppRoute.exams),
        _MenuItem('Examinations', Icons.quiz_rounded, AppRoute.exams),
        _MenuItem('Notice Board', Icons.notifications_active_rounded, AppRoute.notFound),
        _MenuItem('Profile', Icons.person_rounded, AppRoute.profile),
        _MenuItem('Settings', Icons.settings_rounded, AppRoute.settings),
      ],
    };

    return menuMap[role] ?? [];
  }

  int _getSelectedIndex(BuildContext context, List<_MenuItem> items) {
    final currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
    final index = items.indexWhere((item) => currentPath.startsWith(item.route.path));
    return index == -1 ? 0 : index;
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final AppRoute route;

  _MenuItem(this.title, this.icon, this.route);
}
