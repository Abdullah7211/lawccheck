import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/auth_widgets.dart';
import 'two_step_verification_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(alignment: Alignment.centerLeft, child: AuthBackButton()),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AuthIconBadge(icon: Icons.lock_reset_rounded),
                        const SizedBox(height: 24),
                        const AuthHeader(
                          title: 'Forgot Password?',
                          subtitle:
                              "Enter your phone number and we'll send you a code to reset your password.",
                        ),
                        const SizedBox(height: 40),
                        const PhoneField(),
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'Send Code',
                          width: double.infinity,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const TwoStepVerificationScreen()),
                          ),
                        ),
                        const SizedBox(height: 24),
                        AuthSwitchLink(
                          prompt: 'Remembered your password?',
                          action: 'Log in',
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}