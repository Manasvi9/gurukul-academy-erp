import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            ListTile(
              title: const Text('Theme'),
              subtitle: Text(settings.theme.name.toUpperCase()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show theme selection dialog
              },
            ),
            SwitchListTile(
              title: const Text('Notifications'),
              value: settings.notificationsEnabled,
              onChanged: (value) {
                // Update notifications
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('About'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Gurukul Academy ERP',
                  applicationVersion: '1.0.0',
                  children: [
                    const Text('Designed & Developed by Manasvi Joshi'),
                  ],
                );
              },
            ),
            ListTile(title: const Text('Privacy Policy'), onTap: () {}),
            ListTile(title: const Text('Terms & Conditions'), onTap: () {}),
            ListTile(title: const Text('Contact Support'), onTap: () {}),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
