import 'package:flutter/material.dart';

import '../../../app/models/cognitive_test_type.dart';
import '../../test_selection/data/test_catalog.dart';
import '../data/settings_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.repository,
    required this.onThemeModeChanged,
    super.key,
  });

  final SettingsRepository repository;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<_SettingsData> _settings;
  final Map<CognitiveTestType, TextEditingController> _controllers = {};
  bool _saving = false;
  String? _saveMessage;
  ThemeMode? _selectedThemeMode;

  @override
  void initState() {
    super.initState();
    _settings = _loadSettings();
  }

  Future<_SettingsData> _loadSettings() async {
    final themeMode = await widget.repository.loadThemeMode();
    final timeLimits = await widget.repository.loadTestTimeLimits();
    if (!mounted) {
      return _SettingsData(themeMode: themeMode, timeLimits: timeLimits);
    }
    _selectedThemeMode = themeMode;
    for (final entry in timeLimits.entries) {
      _controllers[entry.key] = TextEditingController(
        text: entry.value == null
            ? ''
            : (entry.value!.inSeconds / 60).toStringAsFixed(
                entry.value!.inSeconds % 60 == 0 ? 0 : 1,
              ),
      );
    }
    return _SettingsData(themeMode: themeMode, timeLimits: timeLimits);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _changeTheme(ThemeMode mode) async {
    try {
      await widget.repository.saveThemeMode(mode);
      widget.onThemeModeChanged(mode);
      if (mounted) {
        setState(() {
          _selectedThemeMode = mode;
          _saveMessage = 'Thème enregistré.';
        });
      }
    } catch (error) {
      if (mounted) setState(() => _saveMessage = 'Erreur : $error');
    }
  }

  Future<void> _saveTimeLimits() async {
    final timeLimits = <CognitiveTestType, Duration?>{};
    for (final type in CognitiveTestType.values) {
      final text = _controllers[type]!.text.trim().replaceAll(',', '.');
      if (text.isEmpty) {
        timeLimits[type] = null;
        continue;
      }
      final minutes = double.tryParse(text);
      if (minutes == null || !minutes.isFinite || minutes <= 0) {
        setState(() {
          _saveMessage =
              'Entre une durée positive en minutes, ou laisse le champ vide.';
        });
        return;
      }
      final seconds = (minutes * 60).round();
      if (seconds < 1) {
        setState(() {
          _saveMessage = 'La limite minimale est d’une seconde.';
        });
        return;
      }
      timeLimits[type] = Duration(seconds: seconds);
    }

    setState(() {
      _saving = true;
      _saveMessage = null;
    });
    try {
      await widget.repository.saveTestTimeLimits(timeLimits);
      if (mounted) setState(() => _saveMessage = 'Limites enregistrées.');
    } catch (error) {
      if (mounted) setState(() => _saveMessage = 'Erreur : $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: FutureBuilder<_SettingsData>(
        future: _settings,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Impossible de charger les paramètres : ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = snapshot.requireData;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('Apparence', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Choisis le thème de l’application ou suis celui de ton appareil.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              for (final entry in const [
                (ThemeMode.system, 'Selon l’appareil', Icons.brightness_auto),
                (ThemeMode.light, 'Clair', Icons.light_mode_outlined),
                (ThemeMode.dark, 'Sombre', Icons.dark_mode_outlined),
              ])
                RadioListTile<ThemeMode>(
                  value: entry.$1,
                  groupValue: _selectedThemeMode ?? settings.themeMode,
                  title: Text(entry.$2),
                  secondary: Icon(entry.$3),
                  onChanged: (mode) {
                    if (mode != null) _changeTheme(mode);
                  },
                ),
              const SizedBox(height: 24),
              Text('Mode Test', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text(
                'Définis une durée maximale pour chaque test. Le chronomètre '
                'inclut la mémorisation et les réponses. Laisse un champ vide '
                'pour ne pas encore configurer ce test.',
              ),
              const SizedBox(height: 16),
              for (final test in testCatalog) ...[
                TextField(
                  controller: _controllers[test.type],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: test.title,
                    suffixText: 'min',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              FilledButton(
                onPressed: _saving ? null : _saveTimeLimits,
                child: Text(
                  _saving ? 'Enregistrement…' : 'Enregistrer les durées',
                ),
              ),
              if (_saveMessage case final message?) ...[
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              Text(
                'Conseil : commence par des durées confortables, puis ajuste-les '
                'au fil de tes entraînements.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsData {
  const _SettingsData({required this.themeMode, required this.timeLimits});

  final ThemeMode themeMode;
  final Map<CognitiveTestType, Duration?> timeLimits;
}
