import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import 'app_bottom_nav.dart';

/// Floating navy message that sits above the bottom nav.
void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textNavy,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          AppBottomNav.contentBottomSpace(context),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
}