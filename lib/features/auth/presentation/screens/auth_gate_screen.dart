import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';

/// Decides whether to show the login screen or the app shell.
class AuthGateScreen extends ConsumerStatefulWidget {
  const AuthGateScreen({super.key});

  @override
  ConsumerState<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends ConsumerState<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate once the tree is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate());
  }

  void _navigate() {
    if (!mounted) return;
    final session = ref.read(authSessionProvider);
    final location = GoRouterState.of(context).uri.path;

    if (session == null) {
      // Still restoring (null session that may become non-null) -> stay.
      // The AuthSessionNotifier.restore sets state; providers re-run.
      if (location != '/login') {
        context.go('/login');
      }
    } else {
      if (location != '/home') {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watching here keeps this screen rebuilt whenever auth state changes,
    // which re-triggers _navigate.
    ref.watch(authSessionProvider);
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}