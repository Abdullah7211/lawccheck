import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';

// Data returned by the form (same idea as CaseFormData).
class TeamFormData {
  final String name;
  final String role;
  final String phone;
  final String email;
  final String amount; // digits only, e.g. "30000"
  final String frequency;
  final String status; // 'Pending' or 'Paid'

  const TeamFormData({
    required this.name,
    required this.role,
    required this.phone,
    this.email = '',
    this.amount = '',
    this.frequency = 'Monthly',
    this.status = 'Pending',
  });

  Color get statusColor =>
      status == 'Paid' ? AppColors.statusActive : AppColors.statusPending;

  TeamFormData copyWith({String? status}) => TeamFormData(
        name: name,
        role: role,
        phone: phone,
        email: email,
        amount: amount,
        frequency: frequency,
        status: status ?? this.status,
      );
}

class AddTeamScreen extends StatefulWidget {
  const AddTeamScreen({
    super.key,
    this.initial,
    this.title = 'Add Team Member',
    this.saveLabel = 'Save Member',
  });

  /// Pre-fills the form (used by EditTeamScreen).
  final TeamFormData? initial;
  final String title;
  final String saveLabel;

  @override
  State<AddTeamScreen> createState() => _AddTeamScreenState();
}

class _AddTeamScreenState extends State<AddTeamScreen> {
  static const _roles = [
    'Senior Lawyer',
    'Junior Lawyer',
    'Paralegal',
    'Clerk',
    'Intern',
    'Office Staff',
  ];
  static const _frequencies = ['Monthly', 'Weekly', 'Per case', 'One-time'];
  static const _statuses = ['Pending', 'Paid'];

  late final TextEditingController _name =
      TextEditingController(text: widget.initial?.name ?? '');
  late final TextEditingController _phone =
      TextEditingController(text: widget.initial?.phone ?? '');
  late final TextEditingController _email =
      TextEditingController(text: widget.initial?.email ?? '');
  late final TextEditingController _amount =
      TextEditingController(text: widget.initial?.amount ?? '');

  late String _role = widget.initial?.role ?? 'Junior Lawyer';
  late String _frequency = widget.initial?.frequency ?? 'Monthly';
  late String _status = widget.initial?.status ?? 'Pending';

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    final phone = _phone.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full name and phone are required')),
      );
      return;
    }

    Navigator.of(context).pop(
      TeamFormData(
        name: name,
        role: _role,
        phone: phone,
        email: _email.text.trim(),
        amount: _amount.text.trim(),
        frequency: _frequency,
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keeps a custom role selectable when editing.
    final roles = _roles.contains(_role) ? _roles : [..._roles, _role];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textNavy,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(width: 1, color: AppColors.border),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textNavy,
          fontSize: 17,
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w600,
          letterSpacing: -0.43,
        ),
        title: Text(widget.title),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Full name *',
                      hint: 'e.g. Tanvir Hasan',
                      controller: _name,
                      capitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 12),
                    _LabeledDropdown(
                      label: 'Role',
                      value: _role,
                      items: roles,
                      onChanged: (v) => setState(() => _role = v),
                    ),
                    const SizedBox(height: 12),
                    _LabeledField(
                      label: 'Phone *',
                      hint: '+880 1XXX XXXXXX',
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      formatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _LabeledField(
                      label: 'Email',
                      hint: 'name@chamber.com',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _LabeledField(
                      label: 'Payment amount (৳)',
                      hint: 'e.g. 30000',
                      controller: _amount,
                      keyboardType: TextInputType.number,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _LabeledDropdown(
                      label: 'Frequency',
                      value: _frequency,
                      items: _frequencies,
                      onChanged: (v) => setState(() => _frequency = v),
                    ),
                    const SizedBox(height: 12),
                    _LabeledDropdown(
                      label: 'Payment status',
                      value: _status,
                      items: _statuses,
                      onChanged: (v) => setState(() => _status = v),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom save bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(width: 1, color: AppColors.border),
                ),
              ),
              child: AppButton(
                text: widget.saveLabel,
                width: double.infinity,
                height: 44,
                borderRadius: 8,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// FIELDS
// --------------------------------------------------

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final TextCapitalization capitalization;

  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.formatters,
    this.capitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          decoration: _boxDecoration,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            textCapitalization: capitalization,
            cursorColor: AppColors.textNavy,
            style: _inputStyle,
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: _hintStyle,
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: _boxDecoration,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(8),
              dropdownColor: AppColors.surface,
              style: _inputStyle,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
              items: [
                for (final item in items)
                  DropdownMenuItem(value: item, child: Text(item)),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w500,
          height: 1.33,
        ),
      ),
    );
  }
}

final BoxDecoration _boxDecoration = BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(width: 1, color: AppColors.border),
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