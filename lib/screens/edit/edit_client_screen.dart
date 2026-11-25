import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../forms/add_client_screen.dart' show ClientFormData;

// --------------------------------------------------
// DATA
// --------------------------------------------------

const List<String> _clientTypes = ['Individual', 'Company'];
const List<String> _contactOptions = ['Phone', 'WhatsApp', 'Email', 'SMS'];

/// Makes sure a value that is already saved on the client (but isn't in our
/// default list) still shows up as an option instead of disappearing.
List<String> _withCurrent(List<String> base, String current) {
  if (current.isEmpty || base.contains(current)) return base;
  return [...base, current];
}

// --------------------------------------------------
// SHARED STYLES
// --------------------------------------------------

const Color _errorColor = Color(0xFFC0392B);

const TextStyle _labelStyle = TextStyle(
  color: AppColors.textMuted,
  fontSize: 12,
  fontFamily: 'SF Pro',
  fontWeight: FontWeight.w500,
  height: 1.33,
);

const TextStyle _inputStyle = TextStyle(
  color: AppColors.textDark,
  fontSize: 15,
  fontFamily: 'SF Pro',
  fontWeight: FontWeight.w400,
  letterSpacing: -0.23,
);

const TextStyle _hintStyle = TextStyle(
  color: AppColors.textHint,
  fontSize: 15,
  fontFamily: 'SF Pro',
  fontWeight: FontWeight.w400,
  letterSpacing: -0.23,
);

const TextStyle _errorStyle = TextStyle(
  color: _errorColor,
  fontSize: 11,
  fontFamily: 'SF Pro',
  fontWeight: FontWeight.w400,
  height: 1.4,
);

BoxDecoration _fieldDecoration({bool hasError = false}) {
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
// SCREEN
// --------------------------------------------------

/// Edit form for an existing client.
///
/// Pops with the updated [ClientFormData] when the user saves, or with null
/// when they leave without saving. The caller is responsible for sending the
/// result to the backend and updating its own UI.
class EditClientScreen extends StatefulWidget {
  final ClientFormData initial;

  /// Shown read-only at the top of the form (e.g. "CL-001").
  final String? clientId;

  const EditClientScreen({super.key, required this.initial, this.clientId});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;

  final _nameKey = GlobalKey();
  final _phoneKey = GlobalKey();
  final _emailKey = GlobalKey();
  final _whatsappKey = GlobalKey();

  late String _clientType;
  late String _preferredContact;

  String? _nameError;
  String? _phoneError;
  String? _emailError;
  String? _whatsappError;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _nameCtrl = TextEditingController(text: c.name);
    _phoneCtrl = TextEditingController(text: c.phone);
    _emailCtrl = TextEditingController(text: c.email);
    _whatsappCtrl = TextEditingController(text: c.whatsapp);
    _addressCtrl = TextEditingController(text: c.address);
    _notesCtrl = TextEditingController(text: c.notes);
    _clientType = c.clientType;
    _preferredContact = c.preferredContact;
  }

  @override
  void dispose() {
    for (final controller in [
      _nameCtrl,
      _phoneCtrl,
      _emailCtrl,
      _whatsappCtrl,
      _addressCtrl,
      _notesCtrl,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  // ------------------------------------------------
  // State helpers
  // ------------------------------------------------

  /// True when anything differs from what the screen was opened with.
  bool get _hasChanges {
    final c = widget.initial;
    return _nameCtrl.text.trim() != c.name.trim() ||
        _phoneCtrl.text.trim() != c.phone.trim() ||
        _emailCtrl.text.trim() != c.email.trim() ||
        _whatsappCtrl.text.trim() != c.whatsapp.trim() ||
        _addressCtrl.text.trim() != c.address.trim() ||
        _notesCtrl.text.trim() != c.notes.trim() ||
        _clientType != c.clientType ||
        _preferredContact != c.preferredContact;
  }

  /// Clears an error as soon as the user edits the field it belongs to.
  void _onTextChanged() {
    if (_nameError == null &&
        _phoneError == null &&
        _emailError == null &&
        _whatsappError == null) {
      return;
    }
    setState(() {
      if (_nameError != null) _nameError = null;
      if (_phoneError != null) _phoneError = null;
      if (_emailError != null) _emailError = null;
      if (_whatsappError != null) _whatsappError = null;
    });
  }

  // ------------------------------------------------
  // Pickers
  // ------------------------------------------------

  Future<String?> _showOptionSheet({
    required String title,
    required List<String> options,
    String? selected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _OptionSheet(
        title: title,
        options: options,
        selected: selected,
      ),
    );
  }

  Future<void> _pickClientType() async {
    FocusScope.of(context).unfocus();
    final value = await _showOptionSheet(
      title: 'Client type',
      options: _withCurrent(_clientTypes, widget.initial.clientType),
      selected: _clientType,
    );
    if (!mounted || value == null) return;
    setState(() => _clientType = value);
  }

  Future<void> _pickPreferredContact() async {
    FocusScope.of(context).unfocus();
    final value = await _showOptionSheet(
      title: 'Preferred contact',
      options: _withCurrent(_contactOptions, widget.initial.preferredContact),
      selected: _preferredContact,
    );
    if (!mounted || value == null) return;
    setState(() => _preferredContact = value);
  }

  // ------------------------------------------------
  // Validation + save
  // ------------------------------------------------

  static final RegExp _phoneChars = RegExp(r'^[\d\s+\-()]+$');
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Returns an error message, or null when the number looks valid.
  String? _phoneProblem(String value, {required String emptyMessage}) {
    if (value.isEmpty) return emptyMessage;
    if (!_phoneChars.hasMatch(value)) return 'Use digits, spaces, + or - only';
    final digits = value.replaceAll(RegExp(r'[^\d]'), '').length;
    if (digits < 7 || digits > 15) return 'Enter a valid phone number';
    return null;
  }

  bool _validate() {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final whatsapp = _whatsappCtrl.text.trim();

    final nameError = name.isEmpty ? 'Enter the client name' : null;
    final phoneError =
        _phoneProblem(phone, emptyMessage: 'Enter a phone number');
    final emailError = (email.isNotEmpty && !_emailPattern.hasMatch(email))
        ? 'Enter a valid email address'
        : null;
    final whatsappError = whatsapp.isEmpty
        ? null
        : _phoneProblem(whatsapp, emptyMessage: '');

    setState(() {
      _nameError = nameError;
      _phoneError = phoneError;
      _emailError = emailError;
      _whatsappError = whatsappError;
    });

    final GlobalKey? firstInvalid = nameError != null
        ? _nameKey
        : phoneError != null
            ? _phoneKey
            : emailError != null
                ? _emailKey
                : whatsappError != null
                    ? _whatsappKey
                    : null;

    if (firstInvalid != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final targetContext = firstInvalid.currentContext;
        if (targetContext == null) return;
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 250),
          alignment: 0.1,
        );
      });
    }

    return firstInvalid == null;
  }

  ClientFormData _buildFormData() {
    return ClientFormData(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      clientType: _clientType,
      whatsapp: _whatsappCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      preferredContact: _preferredContact,
      notes: _notesCtrl.text.trim(),
    );
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    // Nothing changed: just close, no result.
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pop(_buildFormData());
  }

  // ------------------------------------------------
  // Back / discard handling
  // ------------------------------------------------

  Future<void> _handleBack() async {
    FocusScope.of(context).unfocus();
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Discard changes?',
          style: TextStyle(
            color: AppColors.textNavy,
            fontSize: 17,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            letterSpacing: -0.43,
          ),
        ),
        content: const Text(
          'Your changes to this client will be lost.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
            height: 1.43,
            letterSpacing: -0.15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Keep editing',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Discard',
              style: TextStyle(color: _errorColor),
            ),
          ),
        ],
      ),
    );

    if (!mounted || discard != true) return;
    Navigator.of(context).pop();
  }

  // ------------------------------------------------
  // Build
  // ------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _EditClientHeader(onBack: _handleBack),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      if (widget.clientId != null)
                        _FormField(
                          label: 'Client ID',
                          child: _ReadOnlyField(text: widget.clientId!),
                        ),
                      _FormField(
                        key: _nameKey,
                        label: 'Full name *',
                        errorText: _nameError,
                        child: _TextInput(
                          controller: _nameCtrl,
                          hasError: _nameError != null,
                          onChanged: (_) => _onTextChanged(),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      _FormField(
                        label: 'Client type',
                        child: _SelectField(
                          text: _clientType,
                          placeholder: 'Select client type',
                          onTap: _pickClientType,
                        ),
                      ),
                      _FormField(
                        key: _phoneKey,
                        label: 'Phone *',
                        errorText: _phoneError,
                        child: _TextInput(
                          controller: _phoneCtrl,
                          hasError: _phoneError != null,
                          onChanged: (_) => _onTextChanged(),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      _FormField(
                        key: _emailKey,
                        label: 'Email',
                        errorText: _emailError,
                        child: _TextInput(
                          controller: _emailCtrl,
                          hasError: _emailError != null,
                          onChanged: (_) => _onTextChanged(),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      _FormField(
                        key: _whatsappKey,
                        label: 'WhatsApp number',
                        errorText: _whatsappError,
                        child: _TextInput(
                          controller: _whatsappCtrl,
                          hasError: _whatsappError != null,
                          onChanged: (_) => _onTextChanged(),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      _FormField(
                        label: 'Address',
                        child: _TextInput(
                          controller: _addressCtrl,
                          onChanged: (_) => _onTextChanged(),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      _FormField(
                        label: 'Preferred contact',
                        child: _SelectField(
                          text: _preferredContact,
                          placeholder: 'Select contact method',
                          onTap: _pickPreferredContact,
                        ),
                      ),
                      _FormField(
                        label: 'Notes',
                        child: _TextInput(
                          controller: _notesCtrl,
                          onChanged: (_) => _onTextChanged(),
                          multiline: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _SaveBar(onSave: _save),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// HEADER
// --------------------------------------------------

class _EditClientHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _EditClientHeader({required this.onBack});

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
              width: 30,
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 22,
                  color: AppColors.textNavy,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Edit Client',
              style: TextStyle(
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
// FORM FIELDS
// --------------------------------------------------

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  final String? errorText;

  const _FormField({
    super.key,
    required this.label,
    required this.child,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 4),
        child,
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(errorText!, style: _errorStyle),
          ),
      ],
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool hasError;
  final bool multiline;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  const _TextInput({
    required this.controller,
    required this.onChanged,
    this.hasError = false,
    this.multiline = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: multiline ? 96 : 44,
      padding: EdgeInsets.symmetric(
        horizontal: multiline ? 10 : 12,
        vertical: multiline ? 10 : 0,
      ),
      alignment: multiline ? Alignment.topLeft : Alignment.centerLeft,
      decoration: _fieldDecoration(hasError: hasError),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: AppColors.textNavy,
        style: _inputStyle,
        textCapitalization: textCapitalization,
        textInputAction:
            multiline ? TextInputAction.newline : TextInputAction.next,
        keyboardType: multiline
            ? TextInputType.multiline
            : (keyboardType ?? TextInputType.text),
        maxLines: multiline ? null : 1,
        expands: multiline,
        textAlignVertical: multiline ? TextAlignVertical.top : null,
        decoration: const InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintStyle: _hintStyle,
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String text;

  const _ReadOnlyField({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: AppColors.border),
      ),
      child: Text(
        text,
        style: _inputStyle.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  final String? text;
  final String placeholder;
  final VoidCallback onTap;

  const _SelectField({
    required this.text,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = text != null && text!.isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: _fieldDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? text! : placeholder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: hasValue ? _inputStyle : _hintStyle,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// OPTION BOTTOM SHEET
// --------------------------------------------------

class _OptionSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;

  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
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
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option == selected;

                return InkWell(
                  onTap: () => Navigator.of(context).pop(option),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 15,
                              fontFamily: 'SF Pro',
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              letterSpacing: -0.23,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: AppColors.textNavy,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// SAVE BAR
// --------------------------------------------------

class _SaveBar extends StatelessWidget {
  final VoidCallback onSave;

  const _SaveBar({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(width: 1, color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: AppButton(
          text: 'Save Changes',
          onPressed: onSave,
          height: 44,
          borderRadius: 8,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}