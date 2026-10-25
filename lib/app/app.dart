import 'package:flutter/material.dart';

import '../features/home/presentation/home_page.dart';
import 'theme/app_theme.dart';

class BtcaApp extends StatelessWidget {
  const BtcaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Entraînement BTCA',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
