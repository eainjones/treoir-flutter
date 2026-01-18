import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/presentation/providers/auth_provider.dart';

/// User preferences provider (simple state for now)
final useImperialUnitsProvider = StateProvider<bool>((ref) => false);
final defaultRestTimerProvider = StateProvider<int>((ref) => AppConstants.defaultRestTimerSeconds);
final timerSoundEnabledProvider = StateProvider<bool>((ref) => true);
final timerVibrationEnabledProvider = StateProvider<bool>((ref) => true);

/// Settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useImperial = ref.watch(useImperialUnitsProvider);
    final restTimer = ref.watch(defaultRestTimerProvider);
    final soundEnabled = ref.watch(timerSoundEnabledProvider);
    final vibrationEnabled = ref.watch(timerVibrationEnabledProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Units section
          _SectionHeader(title: 'Units'),
          SwitchListTile(
            title: const Text('Use Imperial Units'),
            subtitle: Text(useImperial ? 'lbs, miles' : 'kg, km'),
            value: useImperial,
            onChanged: (value) {
              ref.read(useImperialUnitsProvider.notifier).state = value;
            },
          ),
          const Divider(),

          // Timer section
          _SectionHeader(title: 'Rest Timer'),
          ListTile(
            title: const Text('Default Rest Duration'),
            subtitle: Text('${restTimer}s'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRestTimerPicker(context, ref),
          ),
          SwitchListTile(
            title: const Text('Timer Sound'),
            subtitle: const Text('Play sound when timer ends'),
            value: soundEnabled,
            onChanged: (value) {
              ref.read(timerSoundEnabledProvider.notifier).state = value;
            },
          ),
          SwitchListTile(
            title: const Text('Timer Vibration'),
            subtitle: const Text('Vibrate when timer ends'),
            value: vibrationEnabled,
            onChanged: (value) {
              ref.read(timerVibrationEnabledProvider.notifier).state = value;
            },
          ),
          const Divider(),

          // Account section
          _SectionHeader(title: 'Account'),
          ListTile(
            title: const Text('Email'),
            subtitle: Text(authState.user?.email ?? 'Not signed in'),
            leading: const Icon(Icons.email_outlined),
          ),
          ListTile(
            title: const Text('Sign Out'),
            leading: const Icon(Icons.logout),
            onTap: () => _showSignOutDialog(context, ref),
          ),
          const Divider(),

          // About section
          _SectionHeader(title: 'About'),
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info_outline),
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            leading: const Icon(Icons.privacy_tip_outlined),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () {
              // TODO: Open privacy policy URL
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            leading: const Icon(Icons.description_outlined),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () {
              // TODO: Open terms URL
            },
          ),

          const SizedBox(height: 32),

          // Delete account (danger zone)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => _showDeleteAccountDialog(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Delete Account'),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showRestTimerPicker(BuildContext context, WidgetRef ref) {
    final currentValue = ref.read(defaultRestTimerProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Default Rest Duration',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...AppConstants.restTimerOptions.map((seconds) => ListTile(
                  title: Text('${seconds}s'),
                  trailing: seconds == currentValue
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    ref.read(defaultRestTimerProvider.notifier).state = seconds;
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion is not yet implemented'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
