import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../features/ticket/presentation/screens/ticket_list_screen.dart';
import '../../features/ticket/presentation/screens/create_ticket_screen.dart';
import '../../features/ticket/presentation/screens/ticket_detail_screen.dart';
import '../../features/ticket/presentation/screens/ticket_history_screen.dart';
import '../../features/ticket/presentation/screens/ticket_tracking_screen.dart';
import '../../features/notification/presentation/screens/notification_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

class AppRouter {
  const AppRouter._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  static const String dashboard = '/dashboard';
  static const String tickets = '/tickets';
  static const String ticketDetail = '/tickets/:id';
  static const String ticketCreate = '/tickets/create';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String adminDashboard = '/admin/dashboard';
  static const String ticketHistory = '/tickets/history';
  static const String ticketTracking = '/tickets/tracking/:id';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRouter.splash,
    routes: [
      GoRoute(
        path: AppRouter.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRouter.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRouter.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRouter.resetPassword,
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRouter.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRouter.tickets,
        name: 'tickets',
        builder: (context, state) => const TicketListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'ticket-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TicketDetailScreen(ticketId: id);
            },
          ),
          GoRoute(
            path: 'create',
            name: 'ticket-create',
            builder: (context, state) => const CreateTicketScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRouter.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: AppRouter.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRouter.adminDashboard,
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRouter.ticketHistory,
        name: 'ticket-history',
        builder: (context, state) => const TicketHistoryScreen(),
      ),
      GoRoute(
        path: AppRouter.ticketTracking,
        name: 'ticket-tracking',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TicketTrackingScreen(ticketId: id);
        },
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final role = authState.role;
      final location = state.uri.toString();

      final isAuthRoute = location == AppRouter.splash ||
          location == AppRouter.login ||
          location == AppRouter.register ||
          location == AppRouter.resetPassword;

      if (authState.status == AuthStatus.initial) return null;

      if (!isLoggedIn && !isAuthRoute) return AppRouter.login;

      if (isLoggedIn && isAuthRoute) return AppRouter.dashboard;

      if (location.startsWith('/admin') && role != 'admin' && role != 'helpdesk') {
        return AppRouter.dashboard;
      }

      return null;
    },
  );
});
