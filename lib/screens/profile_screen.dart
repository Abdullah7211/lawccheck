import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/sub_page_header.dart';

import 'forms/change_password_screen.dart';
import 'edit/edit_profile_screen.dart';
import 'details/help_support_screen.dart';
import 'details/language_screen.dart';
import 'details/privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _danger = Color(0xFFD92D20);

  // Replace with real user data from your repository / provider later.
  ProfileFormData _profile = const ProfileFormData(
    name: 'Sakib',
    email: 'sakib@example.com',
    phone: '+880 1700-000000',
    barNumber: '',
    address: '',
  );

  String _language = 'English';

  bool _pushNotifications = true;
  bool _hearingReminders = true;
  bool _emailUpdates = false;

  Future<void> _editProfile() async {
    final result = await Navigator.of(context).push<ProfileFormData>(
      MaterialPageRoute(builder: (_) => EditProfileScreen(initial: _profile)),
    );
    if (!mounted || result == null) return;
    setState(() => _profile = result);
  }

  Future<void> _changeLanguage() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => LanguageScreen(selected: _language)),
    );
    if (!mounted || result == null) return;
    setState(() => _language = result);
    // TODO: apply the locale across the app.
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _rateApp() {
    // TODO: open the store review (in_app_review package).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks for your support!')),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Log out?',
          style: TextStyle(
            color: AppColors.textNavy,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        content: const Text(
          'You will need to sign in again to use the app.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontFamily: 'SF Pro',
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out', style: TextStyle(color: _danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // TODO: clear the session / token, then go to your login screen, e.g.
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (_) => const LoginScreen()),
    //   (route) => false,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SubPageHeader(title: 'Profile'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  24 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile image + name
                    Center(
                      child: Column(
                        children: [
                          ProfileAvatar(name: _profile.name),
                          const SizedBox(height: 12),
                          Text(
                            _profile.name,
                            style: const TextStyle(
                              color: AppColors.textNavy,
                              fontSize: 19,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              height: 1.20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _profile.email,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontFamily: 'SF Pro',
                              height: 1.33,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _profile.phone,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontFamily: 'SF Pro',
                              height: 1.33,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ACCOUNT
                    _SettingsGroup(
                      title: 'ACCOUNT',
                      children: [
                        _SettingsTile(
                          icon: Icons.person_outline_rounded,
                          label: 'Edit profile',
                          onTap: _editProfile,
                        ),
                        _SettingsTile(
                          icon: Icons.lock_outline_rounded,
                          label: 'Change password',
                          onTap: () => _open(const ChangePasswordScreen()),
                        ),
                        _SettingsTile(
                          icon: Icons.language_rounded,
                          label: 'Language',
                          value: _language,
                          onTap: _changeLanguage,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // PREFERENCES
                    _SettingsGroup(
                      title: 'PREFERENCES',
                      children: [
                        _SwitchTile(
                          icon: Icons.notifications_none_rounded,
                          label: 'Push notifications',
                          value: _pushNotifications,
                          onChanged: (v) =>
                              setState(() => _pushNotifications = v),
                        ),
                        _SwitchTile(
                          icon: Icons.gavel_rounded,
                          label: 'Hearing reminders',
                          value: _hearingReminders,
                          onChanged: (v) =>
                              setState(() => _hearingReminders = v),
                        ),
                        _SwitchTile(
                          icon: Icons.mail_outline_rounded,
                          label: 'Email updates',
                          value: _emailUpdates,
                          onChanged: (v) => setState(() => _emailUpdates = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // SUPPORT
                    _SettingsGroup(
                      title: 'SUPPORT',
                      children: [
                        _SettingsTile(
                          icon: Icons.help_outline_rounded,
                          label: 'Help & support',
                          onTap: () => _open(const HelpSupportScreen()),
                        ),
                        _SettingsTile(
                          icon: Icons.privacy_tip_outlined,
                          label: 'Privacy policy',
                          onTap: () => _open(const PrivacyPolicyScreen()),
                        ),
                        _SettingsTile(
                          icon: Icons.star_outline_rounded,
                          label: 'Rate the app',
                          onTap: _rateApp,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // LOG OUT
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _confirmLogout,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _danger,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Log out',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.31,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Law Note · v1.0.0',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontFamily: 'SF Pro',
                          height: 1.33,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// SETTINGS GROUP + TILES
// --------------------------------------------------

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 1, color: AppColors.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i != 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 56,
                    color: AppColors.border,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TileIcon extends StatelessWidget {
  final IconData icon;

  const _TileIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: AppColors.textNavy),
    );
  }
}

const TextStyle _labelStyle = TextStyle(
  color: AppColors.textDark,
  fontSize: 14,
  fontFamily: 'SF Pro',
  fontWeight: FontWeight.w500,
  height: 1.43,
  letterSpacing: -0.15,
);

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            _TileIcon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: _labelStyle)),
            if (value != null) ...[
              Text(
                value!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontFamily: 'SF Pro',
                ),
              ),
              const SizedBox(width: 4),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          _TileIcon(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: _labelStyle)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.textNavy,
          ),
        ],
      ),
    );
  }
}