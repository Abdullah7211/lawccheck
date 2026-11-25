import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/auth_widgets.dart';

class TwoStepVerificationScreen extends StatelessWidget {
  const TwoStepVerificationScreen({super.key, this.phoneNumber = '01XXXXXXXXX'});

  /// Shown in the subtitle. Pass the real number once auth is wired up.
  final String phoneNumber;

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
                        const AuthIconBadge(icon: Icons.verified_user_outlined),
                        const SizedBox(height: 24),
                        AuthHeader(
                          title: '2-Step Verification',
                          subtitle:
                              'Enter the 6-digit code we sent to +880 $phoneNumber',
                        ),
                        const SizedBox(height: 40),
                        const OtpField(),
                        const SizedBox(height: 24),
                        AppButton(
                          text: 'Verify',
                          width: double.infinity,
                          onPressed: () {},
                        ),
                        const SizedBox(height: 24),
                        const AuthSwitchLink(
                          prompt: "Didn't get a code?",
                          action: 'Resend',
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