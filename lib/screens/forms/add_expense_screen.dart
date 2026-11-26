import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import 'task_form_shared.dart';

// --------------------------------------------------
// DATA
// --------------------------------------------------

/// What the add / edit expense form hands back when saved.
/// The screen pops with this object: `Navigator.pop(context, data)`.
class ExpenseFormData {
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String type; // 'Personal' | 'Case-related'
  final String? linkedCase; // only used when type is Case-related

  const ExpenseFormData({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    required this.linkedCase,
  });
}

const String expenseTypePersonal = 'Personal';
const String expenseTypeCase = 'Case-related';
const List<String> expenseTypes = [expenseTypePersonal, expenseTypeCase];

const String expenseDefaultCategory = 'Travel';

// Replace with real data from your repository / provider later.
const List<String> expenseCategories = [
  'Court fees',
  'Travel',
  'Books',
  'Printing',
  'Office',
  'Other',
];

// --------------------------------------------------
// ADD SCREEN
// --------------------------------------------------

/// Form for creating a new expense. Pops with an [ExpenseFormData] on save.
/// (Editing lives in screens/edit/edit_expense_screen.dart and reuses the
/// same form.)
class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpenseFormScreen(
      title: 'Add Expense',
      saveText: 'Save Expense',
    );
  }
}

// --------------------------------------------------
// SHARED FORM (used by Add and Edit)
// --------------------------------------------------

class ExpenseFormScreen extends StatefulWidget {
  final String title;
  final String saveText;
  final ExpenseFormData? initial;

  const ExpenseFormScreen({
    super.key,
    required this.title,
    required this.saveText,
    this.initial,
  });

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late final String _initialAmountText;

  // Keys used to scroll to the first field with an error.
  final _titleKey = GlobalKey();
  final _amountKey = GlobalKey();

  late DateTime _date;
  late String _category;
  late String _type;
  String? _linkedCase;

  String? _titleError;
  String? _amountError;

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;

    _initialAmountText = initial == null ? '' : _amountToText(initial.amount);
    _titleCtrl = TextEditingController(text: initial?.title ?? '');
    _amountCtrl = TextEditingController(text: _initialAmountText);

    _date = initial?.date ?? _today;
    _category = initial?.category ?? expenseDefaultCategory;
    _type = initial?.type ?? expenseTypePersonal;
    _linkedCase = initial?.linkedCase;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------
  // Helpers
  // ------------------------------------------------

  static String _amountToText(double amount) {
    return amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  double? get _parsedAmount =>
      double.tryParse(_amountCtrl.text.trim().replaceAll(',', ''));

  bool get _hasChanges {
    final i = widget.initial;
    return _titleCtrl.text.trim() != (i?.title ?? '') ||
        _amountCtrl.text.trim() != _initialAmountText ||
        !_sameDay(_date, i?.date ?? _today) ||
        _category != (i?.category ?? expenseDefaultCategory) ||
        _type != (i?.type ?? expenseTypePersonal) ||
        _linkedCase != i?.linkedCase;
  }

  void _onTextChanged() {
    if (_titleError == null && _amountError == null) return;

    final titleOk = _titleCtrl.text.trim().isNotEmpty;
    final amount = _parsedAmount;
    final amountOk = amount != null && amount > 0;

    setState(() {
      if (titleOk) _titleError = null;
      if (amountOk) _amountError = null;
    });
  }

  // ------------------------------------------------
  // Pickers
  // ------------------------------------------------

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final today = _today;

    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(today.year - 5),
      lastDate: DateTime(today.year + 1, 12, 31),
      builder: taskPickerTheme,
    );
    if (!mounted || picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _pickCategory() async {
    FocusScope.of(context).unfocus();
    final value = await showTaskOptionSheet(
      context,
      title: 'Category',
      options: expenseCategories,
      selected: _category,
    );
    if (!mounted || value == null) return;
    setState(() => _category = value);
  }

  Future<void> _pickType() async {
    FocusScope.of(context).unfocus();
    final value = await showTaskOptionSheet(
      context,
      title: 'Type',
      options: expenseTypes,
      selected: _type,
    );
    if (!mounted || value == null) return;
    setState(() => _type = value);
  }

  Future<void> _pickLinkedCase() async {
    FocusScope.of(context).unfocus();
    final value = await showTaskOptionSheet(
      context,
      title: 'Linked case',
      options: [taskNoCaseLabel, ...taskCases],
      selected: _linkedCase ?? taskNoCaseLabel,
    );
    if (!mounted || value == null) return;
    setState(() => _linkedCase = value == taskNoCaseLabel ? null : value);
  }

  // ------------------------------------------------
  // Validation + save
  // ------------------------------------------------

  bool _validate() {
    final amount = _parsedAmount;

    final titleError =
        _titleCtrl.text.trim().isEmpty ? 'Enter an expense title' : null;
    final amountError = (amount == null || amount <= 0)
        ? 'Enter a valid amount'
        : null;

    setState(() {
      _titleError = titleError;
      _amountError = amountError;
    });

    final GlobalKey? firstInvalid = titleError != null
        ? _titleKey
        : amountError != null
            ? _amountKey
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

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    // TODO (backend): send this to the API / repository if you save here.
    // The caller also receives it, so you can save from either place.
    Navigator.of(context).pop(
      ExpenseFormData(
        title: _titleCtrl.text.trim(),
        amount: _parsedAmount!,
        date: _date,
        category: _category,
        type: _type,
        linkedCase: _type == expenseTypeCase ? _linkedCase : null,
      ),
    );
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

    final discard = await confirmDiscardTaskChanges(
      context,
      message: widget.initial == null
          ? 'This expense has not been saved yet.'
          : 'Your changes have not been saved yet.',
    );
    if (!mounted || !discard) return;
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
              TaskFormHeader(title: widget.title, onBack: _handleBack),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      TaskFormField(
                        key: _titleKey,
                        label: 'Title *',
                        errorText: _titleError,
                        child: TaskTextInput(
                          controller: _titleCtrl,
                          hasError: _titleError != null,
                          onChanged: (_) => _onTextChanged(),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      TaskFormField(
                        key: _amountKey,
                        label: 'Amount (BDT) *',
                        errorText: _amountError,
                        child: _AmountInput(
                          controller: _amountCtrl,
                          hasError: _amountError != null,
                          onChanged: (_) => _onTextChanged(),
                        ),
                      ),
                      TaskFormField(
                        label: 'Date',
                        child: TaskSelectField(
                          text: formatTaskDate(_date),
                          placeholder: 'Select date',
                          trailingIcon: Icons.calendar_today_rounded,
                          onTap: _pickDate,
                        ),
                      ),
                      TaskFormField(
                        label: 'Category',
                        child: TaskSelectField(
                          text: _category,
                          placeholder: 'Select category',
                          onTap: _pickCategory,
                        ),
                      ),
                      TaskFormField(
                        label: 'Type',
                        child: TaskSelectField(
                          text: _type,
                          placeholder: 'Select type',
                          onTap: _pickType,
                        ),
                      ),
                      if (_type == expenseTypeCase)
                        TaskFormField(
                          label: 'Linked case',
                          child: TaskSelectField(
                            text: _linkedCase ?? taskNoCaseLabel,
                            placeholder: 'Select case',
                            onTap: _pickLinkedCase,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              TaskSaveBar(text: widget.saveText, onSave: _save),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// AMOUNT INPUT (numeric keyboard, same look as the other fields)
// --------------------------------------------------

class _AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool hasError;

  const _AmountInput({
    required this.controller,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 1,
          color: hasError ? taskErrorColor : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const Text(
            '৳',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 15,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: AppColors.textNavy,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 15,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                letterSpacing: -0.23,
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}