import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import 'app_icon.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  static const List<Map<String, String>> _actions = [
    {'label': 'New case', 'icon': 'assets/icons/quick_new_case.svg'},
    {'label': 'Clients', 'icon': 'assets/icons/quick_clients.svg'},
    {'label': 'Cases', 'icon': 'assets/icons/quick_cases.svg'},
    {'label': 'Tasks', 'icon': 'assets/icons/quick_tasks.svg'},
    {'label': 'Team', 'icon': 'assets/icons/quick_team.svg'},
    {'label': 'Deadlines', 'icon': 'assets/icons/quick_deadlines.svg'},
    {'label': 'Expenses', 'icon': 'assets/icons/quick_expenses.svg'},
    {'label': 'Export', 'icon': 'assets/icons/quick_export.svg'},
  ];

  static const int _columns = 4;
  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    final rows = (_actions.length / _columns).ceil();

    return SizedBox(
      width: double.infinity,
      height: 144,
      child: Column(
        children: [
          for (int r = 0; r < rows; r++) ...[
            if (r > 0) const SizedBox(height: _gap),
            Expanded(
              child: Row(
                children: [
                  for (int c = 0; c < _columns; c++) ...[
                    if (c > 0) const SizedBox(width: _gap),
                    Expanded(
                      child: _tileAt(r * _columns + c),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tileAt(int index) {
    if (index >= _actions.length) return const SizedBox.shrink();

    final action = _actions[index];
    return _QuickActionTile(
      label: action['label']!,
      icon: action['icon']!,
      isPrimary: index == 0,
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String label;
  final String icon;
  final bool isPrimary;

  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final Color contentColor =
        isPrimary ? const Color(0xFFF5F4F0) : const Color(0xFF172B4D);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: AppIcon(
              asset: icon,
              color: contentColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              color: contentColor,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }
}