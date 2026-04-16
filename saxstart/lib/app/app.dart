import 'package:flutter/material.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class SaxStartApp extends StatelessWidget {
  const SaxStartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SaxStart',
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      routerConfig: router,
    );
  }
}
