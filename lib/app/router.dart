import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/state/session_provider.dart';
import '../features/account/presentation/home_screen.dart';
import '../features/pay/presentation/scan_screen.dart';
import '../features/pay/presentation/pay_screen.dart';
import '../features/pay/presentation/review_screen.dart';
import '../features/pay/presentation/pin_screen.dart';
import '../features/pay/presentation/status_screen.dart';
import '../features/requests/presentation/requests_screen.dart';
import '../features/split/presentation/split_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/history/presentation/receipt_screen.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final sessionState = ref.watch(sessionProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final isLoggedIn = sessionState.value != null;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      // Deep links while logged out redirect to login (Baseline B3)
      if (!isLoggedIn && !isLoggingIn) {
        return AppRoutes.login;
      }

      // If already logged in, do not stay on login screen
      if (isLoggedIn && isLoggingIn) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.scan,
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: AppRoutes.pay,
        builder: (context, state) {
          final vpa = state.uri.queryParameters['vpa'];
          final amStr = state.uri.queryParameters['am'];
          final double? fixedAmount = amStr != null ? double.tryParse(amStr) : null;
          return PayScreen(initialVpa: vpa, fixedAmountRupees: fixedAmount);
        },
      ),
      GoRoute(
        path: AppRoutes.payReview,
        builder: (context, state) => const ReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.payPin,
        builder: (context, state) => const PinScreen(),
      ),
      GoRoute(
        path: AppRoutes.payStatus,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return StatusScreen(paymentId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.requests,
        builder: (context, state) => const RequestsScreen(),
      ),
      GoRoute(
        path: AppRoutes.split,
        builder: (context, state) => const SplitScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.receipt,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ReceiptScreen(paymentId: id);
        },
      ),
    ],
  );
});
