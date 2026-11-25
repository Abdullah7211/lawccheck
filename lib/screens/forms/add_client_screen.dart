import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';

// --------------------------------------------------
// DATA
// --------------------------------------------------

const List<String> kClientTypes = ['Individual', 'Company'];
const List<String> kContactMethods = ['Phone', 'WhatsApp', 'Email'];

class ClientFormData {
  final String name;
  final String phone;
  final String email;
  final String clientType;
  final String whatsapp;
  final String address;
  final String preferredContact;
  final String notes;

  const ClientFormData({
    required this.name,
    required this.phone,
    this.email = '',
    this.clientType = 'Individual',
    this.whatsapp = '',
    this.address = '',
    this.preferredContact = 'Phone',
    this.notes = '',
  });
}

// --------------------------------------------------
// SCREEN
// --------------------------------------------------

class AddClientScreen extends StatefulWidget {
  /// Pass an existing client to edit it instead of creating a new one.
  final ClientFormData? initial;

  const AddClientScreen({super.key, this.initial});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _whatsapp;
  late final TextEditingController _address;
  late final TextEditingController _notes;

  late String _clientType;
  late String _preferredContact;

  bool _nameError = false;
  bool _phoneError = false;
  bool _emailError = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final d = widget.initial;

    _name = TextEditingController(text: d?.name ?? '');
    _phone = TextEditingController(text: d?.phone ?? '');
    _email = TextEditingController(text: d?.email ?? '');
    _whatsapp = TextEditingController(text: d?.whatsapp ?? '');
    _address = TextEditingController(text: d?.address ?? '');
    _notes = TextEditingController(text: d?.notes ?? '');

    _clientType = kClientTypes.contains(d?.clientType)
        ? d!.clientType
        : kClientTypes.first;
    _preferredContact = kContactMethods.contains(d?.preferredContact)
        ? d!.preferredContact
        : kContactMethods.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _whatsapp.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final email = _email.text.trim();

    setState(() {
      _nameError = name.isEmpty;
      _phoneError = phone.isEmpty;
      _emailError = email.isNotEmpty && !email.contains('@');
    });
    if (_nameError || _phoneError || _emailError) return;

    Navigator.of(context).pop(
      ClientFormData(
        name: name,
        phone: phone,
        email: email,
        clientType: _clientType,
        whatsapp: _whatsapp.text.trim(),
        address: _address.text.trim(),
        preferredContact: _preferredContact,
        notes: _notes.text.trim(),
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
            _FormHeader(
              title: _isEditing ? 'Edit Client' : 'Add Client',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Field(
                      label: 'Full name *',
                      error: _nameError ? 'Full name is required' : null,
                      child: _TextBox(
                        controller: _name,
                        hasError: _nameError,
                        capitalization: TextCapitalization.words,
                        onChanged: (_) {
                          if (_nameError) setState(() => _nameError = false);
                        },
                      ),
                    ),
                    _Field(
                      label: 'Phone *',
                      error: _phoneError ? 'Phone is required' : null,
                      child: _TextBox(
                        controller: _phone,
                        hasError: _phoneError,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
                        ],
                        onChanged: (_) {
                          if (_phoneError) setState(() => _phoneError = false);
                        },
                      ),
                    ),
                    _Field(
                      label: 'Email',
                      error: _emailError ? 'Enter a valid email' : null,
                      child: _TextBox(
                        controller: _email,
                        hasError: _emailError,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) {
                          if (_emailError) setState(() => _emailError = false);
                        },
                      ),
                    ),
                    _Field(
                      label: 'Client type',
                      child: _DropdownBox(
                        value: _clientType,
                        items: kClientTypes,
                        onChanged: (v) => setState(() => _clientType = v),
                      ),
                    ),
                    _Field(
                      label: 'WhatsApp number',
                      child: _TextBox(
                        controller: _whatsapp,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
                        ],
                      ),
                    ),
                    _Field(
                      label: 'Address',
                      child: _TextBox(
                        controller: _address,
                        capitalization: TextCapitalization.words,
                      ),
                    ),
                    _Field(
                      label: 'Preferred contact method',
                      child: _DropdownBox(
                        value: _preferredContact,
                        items: kContactMethods,
                        onChanged: (v) => setState(() => _preferredContact = v),
                      ),
                    ),
                    _Field(
                      label: 'Notes',
                      child: _TextBox(
                        controller: _notes,
                        height: 80,
                        maxLines: 3,
                        capitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pinned save bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(width: 1, color: AppColors.border),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: _isEditing ? 'Save Changes' : 'Save Client',
                  onPressed: _save,
                  height: 48,
                  borderRadius: 8,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// STYLES
// --------------------------------------------------

const Color _errorColor = Color(0xFFB3261E);

const TextStyle _inputStyle = TextStyle(
  color: AppColors.textDark,
  fontSize: 15,
  fontFamily: 'SF Pro',
  fontWeight: FontWeight.w400,
  letterSpacing: -0.23,
);

BoxDecoration _boxDecoration({bool hasError = false}) {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      width: 1,
      color: hasError ? _errorColor : AppColors.border,
    ),
  );
}

// --------------------------------------------------
// HEADER
// --------------------------------------------------

class _FormHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _FormHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(width: 1, color: AppColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: const SizedBox(
              width: 26,
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 24,
                  color: AppColors.textNavy,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textNavy,
                fontSize: 17,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                height: 1.50,
                letterSpacing: -0.43,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// FORM PIECES
// --------------------------------------------------

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  final String? error;

  const _Field({required this.label, required this.child, this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w500,
                height: 1.33,
              ),
            ),
          ),
          child,
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                error!,
                style: const TextStyle(
                  color: _errorColor,
                  fontSize: 12,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TextBox extends StatelessWidget {
  final TextEditingController controller;
  final bool hasError;
  final double height;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization capitalization;
  final ValueChanged<String>? onChanged;

  const _TextBox({
    required this.controller,
    this.hasError = false,
    this.height = 44,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.capitalization = TextCapitalization.none,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final multiline = maxLines > 1;
    return Container(
      height: height,
      width: double.infinity,
      alignment: multiline ? Alignment.topLeft : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: multiline ? 8 : 0),
      decoration: _boxDecoration(hasError: hasError),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        keyboardType: multiline ? TextInputType.multiline : keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: capitalization,
        cursorColor: AppColors.textNavy,
        style: _inputStyle,
        decoration: const InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _DropdownBox extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownBox({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _boxDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: _inputStyle,
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AppColors.textDark,
          ),
          items: [
            for (final item in items)
              DropdownMenuItem<String>(value: item, child: Text(item)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}