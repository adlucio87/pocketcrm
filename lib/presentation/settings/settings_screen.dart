import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketcrm/core/di/auth_state.dart';
import 'package:pocketcrm/core/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketcrm/core/notifications/notification_service.dart';
import 'package:pocketcrm/core/di/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  int _reminderAdvanceMinutes = 30;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _reminderAdvanceMinutes = prefs.getInt('reminder_advance_minutes') ?? 30;
    });
  }

  Future<void> _saveNotificationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });

    if (value) {
      await NotificationService().requestPermission();
      final tasks = ref.read(tasksProvider).value;
      if (tasks != null) {
        await NotificationService().syncTaskNotifications(tasks);
      }
    } else {
      await NotificationService().cancelAll();
    }
  }

  Future<void> _saveReminderAdvance(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_advance_minutes', value);
    setState(() {
      _reminderAdvanceMinutes = value;
    });

    if (_notificationsEnabled) {
      final tasks = ref.read(tasksProvider).value;
      if (tasks != null) {
        await NotificationService().syncTaskNotifications(tasks);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Application Theme',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto),
                label: Text('System'),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode),
                label: Text('Light'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode),
                label: Text('Dark'),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (Set<ThemeMode> newSelection) {
              ref.read(themeModeProvider.notifier).setTheme(newSelection.first);
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Notifiche',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Promemoria task'),
            subtitle: const Text('Ricevi notifica prima della scadenza'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: _saveNotificationEnabled,
            ),
          ),
          ListTile(
            title: const Text('Anticipo promemoria'),
            trailing: DropdownButton<int>(
              value: _reminderAdvanceMinutes,
              items: const [
                DropdownMenuItem(value: 15, child: Text('15 minuti prima')),
                DropdownMenuItem(value: 30, child: Text('30 minuti prima')),
                DropdownMenuItem(value: 60, child: Text('1 ora prima')),
              ],
              onChanged: _notificationsEnabled
                  ? (value) {
                      if (value != null) _saveReminderAdvance(value);
                    }
                  : null,
            ),
          ),
          const SizedBox(height: 48),
          const Divider(),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout / Reset Token',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}
