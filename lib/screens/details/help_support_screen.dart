import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/sub_page_header.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const List<(String, String)> _faqs = [
    (
      'How do I add a new case?',
      'Go to the Cases tab and tap "Add Case". Fill in the case details and save.',
    ),
    (
      'How do I print or save my monthly schedule?',
      'Open Monthly schedule and tap "Print / Save PDF" at the top right.',
    ),
    (
      'How do I reset my password?',
      'Open Profile → Change password and follow the steps.',
    ),
    (
      'Why am I not getting hearing reminders?',
      'Check that Push notifications and Hearing reminders are turned on in Profile → Preferences, and that notifications are allowed in your phone settings.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SubPageHeader(title: 'Help & support'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  const _SectionLabel('FREQUENTLY ASKED'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 1, color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < _faqs.length; i++) ...[
                          if (i != 0)
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.border,
                            ),
                          _FaqTile(question: _faqs[i].$1, answer: _faqs[i].$2),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('CONTACT US'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 1, color: AppColors.border),
                    ),
                    child: const Column(
                      children: [
                        _ContactTile(
                          icon: Icons.mail_outline_rounded,
                          label: 'Email',
                          value: 'support@lawnote.app', // TODO: real address
                        ),
                        Divider(height: 1, thickness: 1, color: AppColors.border),
                        _ContactTile(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: '+880 1XXX-XXXXXX', // TODO: real number
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.centerLeft,
        iconColor: AppColors.textNavy,
        collapsedIconColor: AppColors.textMuted,
        title: Text(
          question,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
            height: 1.43,
          ),
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textNavy),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'SF Pro',
                    height: 1.33,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}