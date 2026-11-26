import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/sub_page_header.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // Placeholder text: replace with your real privacy policy.
  static const List<(String, String)> _sections = [
    (
      'Information we collect',
      'We collect the information you enter into the app, such as your profile details, cases, clients, and tasks, so that the app can work for you.',
    ),
    (
      'How we use your information',
      'Your information is used to show your schedule, send hearing reminders, and keep your records in sync. We do not sell your data.',
    ),
    (
      'Data storage and security',
      'Your data is stored securely and is only accessible to you and the people you choose to share it with.',
    ),
    (
      'Your choices',
      'You can edit your profile, manage notifications, or request deletion of your account at any time by contacting support.',
    ),
    (
      'Contact',
      'If you have questions about this policy, contact us from Help & support.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SubPageHeader(title: 'Privacy policy'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  const Text(
                    'Last updated: October 2026',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontFamily: 'SF Pro',
                      height: 1.33,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final section in _sections) ...[
                    Text(
                      section.$1,
                      style: const TextStyle(
                        color: AppColors.textNavy,
                        fontSize: 16,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        letterSpacing: -0.31,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.$2,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}