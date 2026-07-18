import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/academic_structure/presentation/screens/classes_screen.dart';
import '../../features/academic_structure/presentation/screens/sections_screen.dart';
import '../../features/academic_structure/presentation/screens/subjects_screen.dart';
import '../../features/authentication/domain/entities/auth_role.dart';
import '../../features/authentication/presentation/providers/auth_providers.dart';
import '../../features/authentication/presentation/providers/auth_state.dart';
import '../../features/authentication/presentation/screens/change_password_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/examinations/presentation/exam_form_screen.dart';
import '../../features/examinations/presentation/exams_screen.dart';
import '../../features/fees/presentation/screens/fee_dashboard_screen.dart';
import '../../features/fees/presentation/screens/fee_student_ledger_screen.dart';
import '../../features/fees/presentation/screens/fee_student_search_screen.dart';
import '../../features/homework/presentation/screens/homework_screen.dart';
import '../../features/students/presentation/screens/student_class_list_screen.dart';
import '../../features/students/presentation/screens/student_details_screen.dart';
import '../../features/students/presentation/screens/student_form_screen.dart';
import '../../features/students/presentation/screens/student_list_screen.dart';
import '../../features/students/presentation/screens/student_search_screen.dart';
import '../../features/students/presentation/screens/student_section_list_screen.dart';
import '../../features/students/presentation/screens/students_home_screen.dart';
import '../../features/teachers/presentation/screens/teachers_screen.dart';
import '../../shared/screens/not_found_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.login.path,
    refreshListenable: ref.watch(authRouteRefreshProvider),
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.uri.path;
      final isLoginRoute = location == AppRoute.login.path;
      final isChangePasswordRoute = location == AppRoute.changePassword.path;

      if (authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.authenticating) {
        return null;
      }

      if (!authState.isAuthenticated) {
        return isLoginRoute ? null : AppRoute.login.path;
      }

      if (authState.mustChangePassword) {
        return isChangePasswordRoute ? null : AppRoute.changePassword.path;
      }

      if (isLoginRoute || isChangePasswordRoute) {
        return _dashboardPathForRole(authState.user!.role);
      }

      final expectedRole = _roleForDashboardPath(location);
      if (expectedRole != null && expectedRole != authState.user!.role) {
        return _dashboardPathForRole(authState.user!.role);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.changePassword.path,
        name: AppRoute.changePassword.name,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoute.adminDashboard.path,
        name: AppRoute.adminDashboard.name,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoute.directorDashboard.path,
        name: AppRoute.directorDashboard.name,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoute.principalDashboard.path,
        name: AppRoute.principalDashboard.name,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoute.teacherDashboard.path,
        name: AppRoute.teacherDashboard.name,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoute.parentDashboard.path,
        name: AppRoute.parentDashboard.name,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoute.studentDashboard.path,
        name: AppRoute.studentDashboard.name,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoute.students.path,
        name: AppRoute.students.name,
        builder: (context, state) => const StudentsHomeScreen(),
      ),
      GoRoute(
        path: AppRoute.teachers.path,
        name: AppRoute.teachers.name,
        builder: (context, state) => const TeachersScreen(),
      ),
      GoRoute(
        path: AppRoute.classes.path,
        name: AppRoute.classes.name,
        builder: (context, state) => const ClassesScreen(),
      ),
      GoRoute(
        path: AppRoute.sections.path,
        name: AppRoute.sections.name,
        builder: (context, state) => const SectionsScreen(),
      ),
      GoRoute(
        path: AppRoute.subjects.path,
        name: AppRoute.subjects.name,
        builder: (context, state) => const SubjectsScreen(),
      ),
      GoRoute(
        path: AppRoute.addStudent.path,
        name: AppRoute.addStudent.name,
        builder: (context, state) => const StudentFormScreen(),
      ),
      GoRoute(
        path: AppRoute.studentSearch.path,
        name: AppRoute.studentSearch.name,
        builder: (context, state) => const StudentSearchScreen(),
      ),
      GoRoute(
        path: AppRoute.studentClasses.path,
        name: AppRoute.studentClasses.name,
        builder: (context, state) => StudentClassListScreen(
          academicYearId: state.uri.queryParameters['academicYearId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoute.studentClassSections.path,
        name: AppRoute.studentClassSections.name,
        builder: (context, state) => StudentSectionListScreen(
          academicYearId: state.uri.queryParameters['academicYearId'] ?? '',
          classId: state.pathParameters['classId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoute.studentList.path,
        name: AppRoute.studentList.name,
        builder: (context, state) => StudentListScreen(
          academicYearId: state.uri.queryParameters['academicYearId'] ?? '',
          classId: state.pathParameters['classId'] ?? '',
          sectionId: state.pathParameters['sectionId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoute.editStudent.path,
        name: AppRoute.editStudent.name,
        builder: (context, state) => StudentFormScreen(
          studentId: state.pathParameters['studentId'],
        ),
      ),
      GoRoute(
        path: AppRoute.fees.path,
        name: AppRoute.fees.name,
        builder: (context, state) => const FeeDashboardScreen(),
      ),
      GoRoute(
        path: AppRoute.feeSearch.path,
        name: AppRoute.feeSearch.name,
        builder: (context, state) => const FeeStudentSearchScreen(),
      ),
      GoRoute(
        path: AppRoute.feeStudentLedger.path,
        name: AppRoute.feeStudentLedger.name,
        builder: (context, state) => FeeStudentLedgerScreen(
          studentId: state.pathParameters['studentId'] ?? '',
          academicYearId: state.uri.queryParameters['academicYearId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoute.homework.path,
        name: AppRoute.homework.name,
        builder: (context, state) => const HomeworkScreen(),
      ),
      GoRoute(
        path: AppRoute.exams.path,
        name: AppRoute.exams.name,
        builder: (context, state) => const ExamsScreen(),
      ),
      GoRoute(
        path: AppRoute.addExam.path,
        name: AppRoute.addExam.name,
        builder: (context, state) => const ExamFormScreen(),
      ),
      GoRoute(
        path: AppRoute.editExam.path,
        name: AppRoute.editExam.name,
        builder: (context, state) => ExamFormScreen(
          examId: state.pathParameters['examId'],
        ),
      ),
      GoRoute(
        path: AppRoute.studentDetails.path,
        name: AppRoute.studentDetails.name,
        builder: (context, state) => StudentDetailsScreen(
          studentId: state.pathParameters['studentId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoute.notFound.path,
        name: AppRoute.notFound.name,
        builder: (context, state) => const NotFoundScreen(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});

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

AuthRole? _roleForDashboardPath(String path) {
  if (path == AppRoute.adminDashboard.path) {
    return AuthRole.systemAdmin;
  }
  if (path == AppRoute.directorDashboard.path) {
    return AuthRole.director;
  }
  if (path == AppRoute.principalDashboard.path) {
    return AuthRole.principal;
  }
  if (path == AppRoute.teacherDashboard.path) {
    return AuthRole.teacher;
  }
  if (path == AppRoute.parentDashboard.path) {
    return AuthRole.parent;
  }
  if (path == AppRoute.studentDashboard.path) {
    return AuthRole.student;
  }
  return null;
}
