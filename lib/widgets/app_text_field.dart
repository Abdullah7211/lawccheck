import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Labeled text field used by the simple form screens.
/// Set [isPassword] to get a show / hide toggle.
class AppTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.maxLines = 1,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  static const Color _error = Color(0xFFD92D20);

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(width: 1, color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.textNavy,
            fontSize: 12,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
            height: 1.33,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.isPassword && _obscured,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          cursorColor: AppColors.textNavy,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
            letterSpacing: -0.23,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.surface,
            hintText: widget.hint,
            hintStyle: const TextStyle(
              color: AppColors.textHint,
              fontSize: 15,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
              letterSpacing: -0.23,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.textNavy),
            errorBorder: _border(_error),
            focusedErrorBorder: _border(_error),
            errorStyle: const TextStyle(
              color: _error,
              fontSize: 11,
              fontFamily: 'SF Pro',
            ),
            suffixIcon: widget.isPassword
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _obscured = !_obscured),
                    child: Icon(
                      _obscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}