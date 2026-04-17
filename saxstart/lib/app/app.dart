import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/firestore_sync.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class SaxStartApp extends ConsumerWidget {
  const SaxStartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Activate Firestore sync controller for the lifetime of the app.
    // It listens to auth, progress, and drill state and mirrors them to
    // Cloud Firestore.
    ref.watch(firestoreSyncProvider);

    return MaterialApp.router(
      title: 'SaxStart',
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      routerConfig: router,
    );
  }
}
