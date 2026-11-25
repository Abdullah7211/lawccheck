import 'package:material_ui/material_ui.dart';

import '../main.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/auth_widgets.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 64, 16, 24),
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
                  const AuthHeader(subtitle: 'Log in and Play your Buds'),
                  const SizedBox(height: 40),
                  const PhoneField(),
                  const SizedBox(height: 16),
                  PasswordField(
                    trailingLabel: SmallLink(
                      'Forgot Password?',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen()),
                      ),
                    ),
                  ),
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
                      text: 'Log In',
                      width: double.infinity,
                      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const MainNavigationScreen()),
                        (route) => false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const OrDivider(),
                  const SizedBox(height: 16),
                  const GoogleButton(),
                  const SizedBox(height: 16),
                  AuthSwitchLink(
                    prompt: 'No account yet?',
                    action: 'Sign up free',
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}