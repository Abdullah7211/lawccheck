
import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcon extends StatelessWidget {
  final String asset;
  final Color color;
  final double size;

  const AppIcon({
    super.key,
    required this.asset,
    required this.color,
    this.size = 19,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        color,
        BlendMode.srcIn,
      ),
    );
  }
}
