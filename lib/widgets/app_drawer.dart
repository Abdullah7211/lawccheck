import 'dart:ui' show ImageFilter;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../screens/login_screen.dart';
import '../screens/placeholder_screen.dart';
import '../screens/profile_screen.dart';

import '../theme/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
    this.userName = 'Sakib',
    this.userImage,
  });

  /// Index of the tab currently shown in MainNavigationScreen.
  final int currentIndex;

  /// Called with 0..6 (Home, Cases, Clients, Tasks, PDF, Team, Monthly schedule).
  final ValueChanged<int> onSelectTab;

  final String userName;

  /// e.g. NetworkImage(url) or AssetImage('assets/image/user.png').
  /// When null, the first letter of the name is shown.
  final ImageProvider? userImage;

  // ── Glass settings (tweak these) ──
  static const double _blurSigma = 20; // higher = blurrier
  static const Color _glassTint = Color(0x8CF5F4F0); // cream @ ~55% opacity
  static const Color _glassEdge = Color(0x66FFFFFF); // light right-edge line
  static const Color _divider = Color(0x26202B38);

  // Your own SVG icons (same files as the bottom nav).
  static const _tabs = <_DrawerEntry>[
    _DrawerEntry('Home', asset: 'assets/icons/home.svg'),
    _DrawerEntry('Cases', asset: 'assets/icons/cases.svg'),
    _DrawerEntry('Clients', asset: 'assets/icons/clients.svg'),
    _DrawerEntry('Tasks', asset: 'assets/icons/tasks.svg'),
    _DrawerEntry('PDF', asset: 'assets/icons/pdf.svg'),
  ];

  // Default Material icons.
  static const _extras = <_DrawerEntry>[
    _DrawerEntry('Expenses', icon: Icons.receipt_long_outlined, index: 7),
    _DrawerEntry('Team', icon: Icons.groups_outlined, index: 5),
    _DrawerEntry('Monthly Schedule',
        icon: Icons.calendar_month_outlined, index: 6),
  ];

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: const Color(0x00000000), // transparent: glass shows through
      elevation: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
          child: Container(
            decoration: const BoxDecoration(
              color: _glassTint,
              border: Border(right: BorderSide(color: _glassEdge, width: 1)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ── Profile (tap to open the profile page) ──
                  Material(
                    color: const Color(0x00000000),
                    child: InkWell(
                      onTap: () {
                        navigator.pop(); // close drawer
                        navigator.push(MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.primary,
                              backgroundImage: userImage,
                              child: userImage == null
                                  ? Text(
                                      userName.isEmpty
                                          ? '?'
                                          : userName[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFFF5F4F0),
                                        fontSize: 22,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF0D294E),
                                      fontSize: 19,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'View profile',
                                    style: TextStyle(
                                      color: Color(0xFF727B86),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.33,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 22,
                              color: Color(0xFF727B86),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: _divider),

                  // ── Menu ──
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: [
                        for (int i = 0; i < _tabs.length; i++)
                          _DrawerItem(
                            entry: _tabs[i],
                            selected: i == currentIndex,
                            onTap: () {
                              navigator.pop(); // close drawer
                              onSelectTab(i);
                            },
                          ),
                        for (final e in _extras)
                          _DrawerItem(
                            entry: e,
                            selected: e.index == currentIndex,
                            onTap: () {
                              navigator.pop();
                              final index = e.index;

                              if (index != null) {
                                onSelectTab(index); // opens inside the main shell
                              } else {
                                navigator.push(MaterialPageRoute(
                                  builder: (_) => PlaceholderScreen(title: e.label),
                                ));
                              }
                            },
                          ),
                      ],
                    ),
                  ),

                  // ── Sign out ──
                  const Divider(height: 1, color: _divider),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _DrawerItem(
                      entry: const _DrawerEntry('Sign out',
                          icon: Icons.logout_rounded),
                      selected: false,
                      color: const Color(0xFFB3261E),
                      onTap: () => navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One sidebar row. Give it either [asset] (your SVG) or [icon] (Material).
class _DrawerEntry {
  final String label;
  final String? asset;
  final IconData? icon;

  /// Index in MainNavigationScreen._screenFor. When null, the row opens a
  /// placeholder page until you build that screen.
  final int? index;

  const _DrawerEntry(this.label, {this.asset, this.icon, this.index})
      : assert(asset != null || icon != null,
            'Provide either an asset path or an IconData');
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.entry,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final _DrawerEntry entry;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fg = color ??
        (selected ? const Color(0xFF0D294E) : const Color(0xFF202B38));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        // Slightly stronger highlight so it reads on the glass.
        color: selected ? const Color(0x1F0D294E) : const Color(0x00000000),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: entry.asset != null
                        ? SvgPicture.asset(
                            entry.asset!,
                            width: 22,
                            height: 22,
                            fit: BoxFit.contain,
                            colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
                          )
                        : Icon(entry.icon, size: 22, color: fg),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      entry.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}