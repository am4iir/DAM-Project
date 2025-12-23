import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../pages/splash_screen_page/splash_screen.dart';
import '../../pages/auth/singin_page.dart';
import '../../pages/auth/singup_page.dart';
import '../../pages/admin_page/admin_main.dart';
import '../../pages/student_page/student_main.dart';
import '../../pages/teacher_page/teacher_main.dart';
import '../../pages/waiting_page/waiting_page.dart';

CustomTransitionPage buildSlidePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          buildSlidePage(const SolashScreen(), state),
    ),
    GoRoute(
      path: '/signin',
      pageBuilder: (context, state) =>
          buildSlidePage(const SinginPage(), state),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) =>
          buildSlidePage(const SingupPage(), state),
    ),
    GoRoute(
      path: '/admin',
      pageBuilder: (context, state) => buildSlidePage(const Admin(), state),
    ),
    GoRoute(
      path: '/teacher',
      pageBuilder: (context, state) => buildSlidePage(const Teacher(), state),
    ),
    GoRoute(
      path: '/student',
      pageBuilder: (context, state) => buildSlidePage(const Student(), state),
    ),
    GoRoute(
      path: '/waiting',
      pageBuilder: (context, state) =>
          buildSlidePage(const WaitingPage(), state),
    ),
  ],
);
