import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/gold_button.dart';
import '../../../core/services/auth_service.dart';
import '../../../features/onboarding/providers/onboarding_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _dailyReminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 18, minute: 0);

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Profile section
            AppCard(
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.gold,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                      auth.displayName ?? 'Saxophonist',
                      style: AppTypography.displaySmall.copyWith(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    auth.email ?? _levelLabel(onboarding.level),
                    style: AppTypography.bodySmall,
                  ),
                  if (auth.isGuest) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Guest account',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.gold),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Practice Reminders
            Text('PRACTICE REMINDERS', style: AppTypography.label),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Daily Reminder', style: AppTypography.bodyMedium),
                      Switch(
                        value: _dailyReminder,
                        onChanged: (v) => setState(() => _dailyReminder = v),
                        activeThumbColor: AppColors.gold,
                        activeTrackColor: AppColors.gold.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                  if (_dailyReminder) ...[
                    const Divider(color: AppColors.borderSubtle),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Reminder Time',
                          style: AppTypography.bodyMedium),
                      trailing: GestureDetector(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _reminderTime,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppColors.gold,
                                    surface: AppColors.surface,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) {
                            setState(() => _reminderTime = time);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _reminderTime.format(context),
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.gold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Appearance
            Text('APPEARANCE', style: AppTypography.label),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dark Mode', style: AppTypography.bodyMedium),
                  Switch(
                    value: true,
                    onChanged: null, // Always dark for v1
                    activeThumbColor: AppColors.gold,
                    activeTrackColor: AppColors.gold.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Subscription
            Text('SUBSCRIPTION', style: AppTypography.label),
            const SizedBox(height: 12),
            AppCard(
              highlighted: true,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.gold, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Free Plan',
                                style: AppTypography.bodyLarge
                                    .copyWith(fontWeight: FontWeight.w600)),
                            Text('Module 1 + basic tools',
                                style: AppTypography.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GoldButton(
                    label: 'Upgrade to SaxStart Pro',
                    onPressed: () {
                      // TODO: Show paywall
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$7.99/month or \$49.99/year',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account actions
            Text('ACCOUNT', style: AppTypography.label),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.restore_rounded,
                    label: 'Restore Purchases',
                    onTap: () {},
                  ),
                  const Divider(color: AppColors.borderSubtle),
                  _SettingsTile(
                    icon: Icons.privacy_tip_rounded,
                    label: 'Privacy Policy',
                    onTap: () {},
                  ),
                  const Divider(color: AppColors.borderSubtle),
                  _SettingsTile(
                    icon: Icons.description_rounded,
                    label: 'Terms of Service',
                    onTap: () {},
                  ),
                  const Divider(color: AppColors.borderSubtle),
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    onTap: () async {
                      await ref.read(authProvider.notifier).signOut();
                      if (context.mounted) context.go('/welcome');
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'SaxStart v1.0.0',
                style: AppTypography.caption,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _levelLabel(String? level) {
    switch (level) {
      case 'beginner':
        return 'Absolute Beginner';
      case 'returning':
        return 'Returning Player';
      case 'school_band':
        return 'School Band Starter';
      default:
        return 'Beginner';
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
        size: 20,
      ),
      title: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textDisabled,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
