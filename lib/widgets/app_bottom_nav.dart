
import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(label: 'Home', asset: 'assets/icons/home.svg'),
    _NavItemData(label: 'Cases', asset: 'assets/icons/cases.svg'),
    _NavItemData(label: 'Clients', asset: 'assets/icons/clients.svg'),
    _NavItemData(label: 'Tasks', asset: 'assets/icons/tasks.svg'),
    _NavItemData(label: 'PDF', asset: 'assets/icons/pdf.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 370,
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final isSelected = currentIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  height: 53.5,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.navActiveBackground
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(
                        asset: item.asset,
                        size: 19,
                        color: isSelected
                            ? AppColors.navActiveIcon
                            : AppColors.navInactive,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.navActiveIcon
                              : AppColors.navInactive,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final String asset;

  const _NavItemData({
    required this.label,
    required this.asset,
  });
}
