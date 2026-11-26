import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/sub_page_header.dart';

class ProfileFormData {
  final String name;
  final String email;
  final String phone;
  final String barNumber;
  final String address;

  const ProfileFormData({
    required this.name,
    required this.email,
    required this.phone,
    required this.barNumber,
    required this.address,
  });
}

class EditProfileScreen extends StatefulWidget {
  final ProfileFormData initial;

  const EditProfileScreen({super.key, required this.initial});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _barNumber;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial.name);
    _email = TextEditingController(text: widget.initial.email);
    _phone = TextEditingController(text: widget.initial.phone);
    _barNumber = TextEditingController(text: widget.initial.barNumber);
    _address = TextEditingController(text: widget.initial.address);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _barNumber.dispose();
    _address.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: send the updated profile to your backend / repository.
    Navigator.of(context).pop(
      ProfileFormData(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        barNumber: _barNumber.text.trim(),
        address: _address.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SubPageHeader(title: 'Edit profile'),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      ListenableBuilder(
                        listenable: _name,
                        builder: (_, _) => ProfileAvatar(
                          name: _name.text,
                          showCamera: true,
                          onCameraTap: () {
                            // TODO: pick a photo (image_picker).
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: 'Full name',
                        controller: _name,
                        hint: 'Your full name',
                        validator: (v) => _required(v, 'Name'),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Email',
                        controller: _email,
                        hint: 'name@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Phone',
                        controller: _phone,
                        hint: '+880 1XXX-XXXXXX',
                        keyboardType: TextInputType.phone,
                        validator: (v) => _required(v, 'Phone'),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Bar enrollment number',
                        controller: _barNumber,
                        hint: 'Optional',
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Chamber address',
                        controller: _address,
                        hint: 'Optional',
                        maxLines: 2,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: 'Save changes',
                          onPressed: _save,
                          height: 48,
                          borderRadius: 8,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ],
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