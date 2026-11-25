import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';

// --------------------------------------------------
// DATA + HELPERS
// --------------------------------------------------

class CaseExpense {
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String type;

  const CaseExpense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
  });
}

const List<String> kExpenseCategories = [
  'Travel',
  'Court fees',
  'Printing',
  'Stationery',
  'Other',
];

const List<String> kExpenseTypes = ['Personal', 'Client'];

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// 25 Oct
String formatShortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

/// ৳2,500
String formatTaka(double value) {
  final isWhole = value == value.roundToDouble();
  final parts = value.toStringAsFixed(isWhole ? 0 : 2).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '৳$whole${parts.length > 1 ? '.${parts[1]}' : ''}';
}

// --------------------------------------------------
// SCREEN
// --------------------------------------------------

class AddCaseExpenseScreen extends StatefulWidget {
  /// Pass an existing expense to edit it instead of creating a new one.
  final CaseExpense? initial;

  const AddCaseExpenseScreen({super.key, this.initial});

  @override
  State<AddCaseExpenseScreen> createState() => _AddCaseExpenseScreenState();
}

class _AddCaseExpenseScreenState extends State<AddCaseExpenseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  DateTime? _date;
  String _category = kExpenseCategories.first;
  String _type = kExpenseTypes.first;

  bool _titleError = false;
  bool _amountError = false;

  bool get _isEditing => widget.initial != null;

  late final List<String> _categories;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;

    _categories = [
      ...kExpenseCategories,
      if (e != null && !kExpenseCategories.contains(e.category)) e.category,
    ];

    if (e != null) {
      _titleController.text = e.title;
      _amountController.text =
          e.amount.toStringAsFixed(e.amount == e.amount.roundToDouble() ? 0 : 2);
      _date = e.date;
      _category = e.category;
      _type = kExpenseTypes.contains(e.type) ? e.type : kExpenseTypes.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    setState(() {
      _titleError = title.isEmpty;
      _amountError = amount == null || amount <= 0;
    });
    if (_titleError || _amountError) return;

    Navigator.of(context).pop(
      CaseExpense(
        title: title,
        amount: amount!,
        date: _date ?? DateTime.now(),
        category: _category,
        type: _type,
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
              title: _isEditing ? 'Edit Expense' : 'Add Expense',
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
                      label: 'Title *',
                      error: _titleError ? 'Title is required' : null,
                      child: _TextBox(
                        controller: _titleController,
                        textCapitalization: TextCapitalization.sentences,
                        hasError: _titleError,
                        onChanged: (_) {
                          if (_titleError) setState(() => _titleError = false);
                        },
                      ),
                    ),
                    _Field(
                      label: 'Amount (BDT) *',
                      error: _amountError ? 'Enter a valid amount' : null,
                      child: _TextBox(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        hasError: _amountError,
                        onChanged: (_) {
                          if (_amountError) {
                            setState(() => _amountError = false);
                          }
                        },
                      ),
                    ),
                    _Field(
                      label: 'Date',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _pickDate,
                        child: Container(
                          height: 44,
                          width: double.infinity,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: _boxDecoration(),
                          child: Text(
                            _date == null
                                ? 'Select date'
                                : formatShortDate(_date!),
                            style: _date == null ? _hintStyle : _inputStyle,
                          ),
                        ),
                      ),
                    ),
                    _Field(
                      label: 'Category',
                      child: _DropdownBox(
                        value: _category,
                        items: _categories,
                        onChanged: (v) => setState(() => _category = v),
                      ),
                    ),
                    _Field(
                      label: 'Type',
                      child: _DropdownBox(
                        value: _type,
                        items: kExpenseTypes,
                        onChanged: (v) => setState(() => _type = v),
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
                  text: _isEditing ? 'Save Changes' : 'Save Expense',
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

BoxDecoration _boxDecoration({bool hasError = false}) {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      width: 1,
      color: hasError ? const Color(0xFFB3261E) : AppColors.border,
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
                  color: Color(0xFFB3261E),
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
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool hasError;
  final ValueChanged<String>? onChanged;

  const _TextBox({
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.hasError = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _boxDecoration(hasError: hasError),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
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