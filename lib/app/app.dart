import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';
import '../core/security/app_lock.dart';
import '../features/auth/presentation/lock_screen.dart';

class PayLiteApp extends ConsumerStatefulWidget {
  const PayLiteApp({super.key});

  @override
  ConsumerState<PayLiteApp> createState() => _PayLiteAppState();
}

class _PayLiteAppState extends ConsumerState<PayLiteApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Trigger background biometric app lock (Baseline B2)
      ref.read(appLockProvider.notifier).onAppPaused();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final appLock = ref.watch(appLockProvider);

    return MaterialApp.router(
      title: 'PayLite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        // Overlay LockScreen when app is locked on background resume
        return Stack(
          children: [
            if (child != null) child,
            if (appLock.isLocked) const Positioned.fill(child: LockScreen()),
          ],
        );
      },
    );
  }
}
