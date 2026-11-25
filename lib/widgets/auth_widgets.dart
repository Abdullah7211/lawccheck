import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

TextStyle _inter(double size, FontWeight weight, Color color, [double? height]) =>
    TextStyle(
      color: color,
      fontSize: size,
      fontFamily: 'Inter',
      fontWeight: weight,
      height: height,
    );

BoxDecoration _boxDecoration({Color? borderColor, double borderWidth = 1}) =>
    BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor ?? AppColors.border, width: borderWidth),
    );

InputDecoration _fieldDecoration(String hint, TextStyle hintStyle, {Widget? suffix}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: hintStyle,
      isDense: true,
      border: InputBorder.none,
      suffixIcon: suffix,
      suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
    );

/// Title + subtitle. Title defaults to the brand name.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.subtitle, this.title = 'LAWBUDS'});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: _inter(23, FontWeight.w600, AppColors.textDark, 1.2)),
          const SizedBox(height: 12),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: _inter(16, FontWeight.w600, AppColors.textMuted, 1.3)),
        ],
      );
}

/// Round back button used on Forgot Password / Verification screens.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: AppColors.textDark),
        ),
      );
}

/// Circular icon badge shown above headers.
class AuthIconBadge extends StatelessWidget {
  const AuthIconBadge({super.key, required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 28, color: AppColors.primary),
      );
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: _inter(12, FontWeight.w600, AppColors.textDark, 1.2));
}

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({super.key, required this.label, required this.hint});
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: _boxDecoration(),
            alignment: Alignment.center,
            child: TextField(
              style: _inter(14, FontWeight.w500, AppColors.textDark),
              decoration: _fieldDecoration(
                  hint, _inter(12, FontWeight.w600, AppColors.textMuted, 1.2)),
            ),
          ),
        ],
      );
}

class PhoneField extends StatelessWidget {
  const PhoneField({super.key});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel('Phone Number'),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 93,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: _boxDecoration(),
                child: Row(
                  children: [
                    Text('🇧🇩',
                        style: _inter(16, FontWeight.w600, const Color(0xFF0F172A), 1.5)),
                    const SizedBox(width: 4),
                    Text('+880',
                        style: _inter(13, FontWeight.w600, AppColors.textMuted, 1.5)),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 14, color: AppColors.textMuted),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: _boxDecoration(),
                  alignment: Alignment.center,
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    style: _inter(14, FontWeight.w500, AppColors.textDark),
                    decoration: _fieldDecoration('01XXXXXXXXX',
                        _inter(14, FontWeight.w500, AppColors.textMuted)),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
}

class PasswordField extends StatefulWidget {
  const PasswordField({super.key, this.trailingLabel});
  final Widget? trailingLabel;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const FieldLabel('Password'),
              if (widget.trailingLabel != null) widget.trailingLabel!,
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.only(left: 12, right: 8),
            decoration: _boxDecoration(),
            alignment: Alignment.center,
            child: TextField(
              obscureText: _obscure,
              style: _inter(14, FontWeight.w400, AppColors.textDark),
              decoration: _fieldDecoration(
                '••••••••',
                _inter(14, FontWeight.w400, AppColors.textMuted),
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

/// 6-box one-time-code input. A hidden TextField captures the digits
/// (so paste / SMS autofill work) and the boxes mirror what's typed.
class OtpField extends StatefulWidget {
  const OtpField({super.key, this.length = 6});
  final int length;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text;
    final activeIndex = text.length >= widget.length ? widget.length - 1 : text.length;

    return GestureDetector(
      onTap: () => _focus.requestFocus(),
      child: Stack(
        children: [
          Row(
            children: [
              for (int i = 0; i < widget.length; i++) ...[
                if (i != 0) const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: _boxDecoration(
                      borderColor: (_focus.hasFocus && i == activeIndex)
                          ? AppColors.primary
                          : AppColors.border,
                      borderWidth: (_focus.hasFocus && i == activeIndex) ? 1.5 : 1,
                    ),
                    child: Text(
                      i < text.length ? text[i] : '',
                      style: _inter(20, FontWeight.w600, AppColors.textDark),
                    ),
                  ),
                ),
              ],
            ],
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                maxLength: widget.length,
                enableInteractiveSelection: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(counterText: '', border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    const line = Expanded(
      child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
    );
    return Row(
      children: [
        line,
        const SizedBox(width: 12),
        Text('or continue with',
            style: _inter(11, FontWeight.w600, AppColors.textMuted, 1.5)),
        const SizedBox(width: 12),
        line,
      ],
    );
  }
}

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x19000000),
                blurRadius: 2,
                offset: Offset(0, 1),
                spreadRadius: -1),
            BoxShadow(
                color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),
        child: Material(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.04),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CustomPaint(painter: _GoogleLogoPainter()),
                  ),
                  const SizedBox(width: 10),
                  Text('Google',
                      style: _inter(
                          14, FontWeight.w600, const Color(0xFF374151), 1.5)),
                ],
              ),
            ),
          ),
        ),
      );
}

/// Draws the multicolour Google "G" (no asset needed).
class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = s * 0.2;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, s - stroke, s - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    double rad(double deg) => deg * 3.1415926535 / 180;

    void arc(Color c, double startDeg, double sweepDeg) {
      paint.color = c;
      canvas.drawArc(rect, rad(startDeg), rad(sweepDeg), false, paint);
    }

    arc(const Color(0xFFFBBC05), 135, 90); // yellow (left)
    arc(const Color(0xFF34A853), 45, 90); // green (bottom)
    arc(const Color(0xFF4285F4), 0, 45); // blue (lower right)
    arc(const Color(0xFFEA4335), -135, 90); // red (top)

    // Blue horizontal bar of the "G".
    canvas.drawRect(
      Rect.fromLTRB(s * 0.5, s * 0.5 - stroke / 2, s, s * 0.5 + stroke / 2),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Footer such as "Already have an account? Log in".
class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({
    super.key,
    required this.prompt,
    required this.action,
    this.onTap,
  });
  final String prompt;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(prompt, style: _inter(12, FontWeight.w400, AppColors.textMuted, 1.5)),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: onTap,
            child: Text(action,
                style: _inter(12, FontWeight.w700, AppColors.primary, 1.5)),
          ),
        ],
      );
}

class SmallLink extends StatelessWidget {
  const SmallLink(this.text, {super.key, this.onTap});
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Text(text,
            textAlign: TextAlign.center,
            style: _inter(12, FontWeight.w600, AppColors.primary, 1.5)),
      );
}

class TermsText extends StatelessWidget {
  const TermsText({super.key});

  @override
  Widget build(BuildContext context) {
    final normal = _inter(11, FontWeight.w400, AppColors.textMuted, 1.63);
    final link = _inter(11, FontWeight.w600, AppColors.primary, 1.63);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 316),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(text: 'By creating an account you agree to our ', style: normal),
          TextSpan(text: 'Terms of Service', style: link),
          TextSpan(text: ' and ', style: normal),
          TextSpan(text: 'Privacy Policy', style: link),
          TextSpan(text: '.', style: normal),
        ]),
        textAlign: TextAlign.center,
      ),
    );
  }
}