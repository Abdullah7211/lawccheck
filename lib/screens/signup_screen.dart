import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/auth_widgets.dart';
import 'login_screen.dart';
import 'two_step_verification_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/icons/logo.png',
                    height: 96,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  const AuthHeader(subtitle: 'Sign up and Start your Buds'),
                  const SizedBox(height: 40),
                  const LabeledTextField(
                      label: 'Full Name', hint: 'e.g. Rahim Uddin'),
                  const SizedBox(height: 16),
                  const PhoneField(),
                  const SizedBox(height: 16),
                  const PasswordField(),
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AppButton(
                      text: 'Create Free Account',
                      width: double.infinity,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const TwoStepVerificationScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const OrDivider(),
                  const SizedBox(height: 16),
                  const GoogleButton(),
                  const SizedBox(height: 16),
                  AuthSwitchLink(
                    prompt: 'Already have an account?',
                    action: 'Log in',
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(child: TermsText()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}