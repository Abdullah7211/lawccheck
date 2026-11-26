import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Circle avatar with the user's initial. Optional camera badge.
/// Swap the child for an Image when you have a real photo URL.
class ProfileAvatar extends StatelessWidget {
  final String name;
  final double size;
  final bool showCamera;
  final VoidCallback? onCameraTap;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.size = 88,
    this.showCamera = false,
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF0D294E),
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: TextStyle(
                color: const Color(0xFFF5F4F0),
                fontSize: size * 0.4,
                fontFamily: 'Fraunces',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (showCamera)
            Positioned(
              right: -2,
              bottom: -2,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onCameraTap,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(width: 1, color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 16,
                    color: AppColors.textNavy,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}