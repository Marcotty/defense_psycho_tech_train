import 'package:flutter/material.dart';

import '../features/history/presentation/history_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/settings/presentation/settings_page.dart';
import 'theme/app_theme.dart';

class BtcaApp extends StatefulWidget {
  const BtcaApp({super.key});

  @override
  State<BtcaApp> createState() => _BtcaAppState();
}

class _BtcaAppState extends State<BtcaApp> {
  final SettingsRepository _settingsRepository = const SettingsRepository();
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final mode = await _settingsRepository.loadThemeMode();
    if (mounted) setState(() => _themeMode = mode);
  }

  void _updateThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Entraînement BTCA',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      routes: {
        '/history': (_) => const HistoryPage(),
        '/settings': (_) => SettingsPage(
          repository: _settingsRepository,
          onThemeModeChanged: _updateThemeMode,
        ),
      },
      home: const HomePage(),
    );
  }
}
