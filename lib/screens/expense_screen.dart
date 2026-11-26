import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_snackbar.dart';
import 'edit/edit_expense_screen.dart';
import 'forms/add_expense_screen.dart';

// --------------------------------------------------
// DATA
// --------------------------------------------------

const Color _errorColor = Color(0xFFC0392B);

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

enum _ExpenseAction { edit, remove }

/// 1200 -> "৳1,200", 2500.5 -> "৳2,500.50"
String _formatAmount(double value) {
  final isWhole = value == value.roundToDouble();
  final parts = value.toStringAsFixed(isWhole ? 0 : 2).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '৳$whole${parts.length > 1 ? '.${parts[1]}' : ''}';
}

class _ExpenseItem {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String type;
  final String? linkedCase;

  const _ExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.linkedCase,
  });

  bool get isCaseRelated => type == expenseTypeCase;

  /// e.g. "25 Oct · Court fees · Rahman vs Karim" or "22 Oct · Books"
  String get subtitle {
    final parts = [
      '${date.day} ${_months[date.month - 1]}',
      category,
      if (linkedCase != null) linkedCase!,
    ];
    return parts.join(' · ');
  }

  ExpenseFormData toFormData() => ExpenseFormData(
        title: title,
        amount: amount,
        date: date,
        category: category,
        type: type,
        linkedCase: linkedCase,
      );

  /// Same expense (same id) with the edited form values applied.
  _ExpenseItem updatedWith(ExpenseFormData data) => _ExpenseItem(
        id: id,
        title: data.title,
        amount: data.amount,
        date: data.date,
        category: data.category,
        type: data.type,
        linkedCase: data.linkedCase,
      );
}

// --------------------------------------------------
// SCREEN
// --------------------------------------------------

class ExpenseScreen extends StatefulWidget {
  /// Called when the back arrow is tapped. When this screen is shown inside
  /// MainNavigationScreen, pass a callback that switches back to Home.
  /// When null, it simply pops the route.
  final VoidCallback? onBack;

  const ExpenseScreen({super.key, this.onBack});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  // Replace with real data from your repository / provider later.
  // (Sample dates are placed in the current month so "This month" shows data.)
  late final List<_ExpenseItem> _expenses = _sampleExpenses();

  List<_ExpenseItem> _sampleExpenses() {
    final now = DateTime.now();
    DateTime day(int d) => DateTime(now.year, now.month, d > now.day ? now.day : d);

    return [
      _ExpenseItem(
        id: 'e1',
        title: 'Court filing fee',
        amount: 2500,
        date: day(25),
        category: 'Court fees',
        type: expenseTypeCase,
        linkedCase: 'Rahman vs Karim',
      ),
      _ExpenseItem(
        id: 'e2',
        title: 'Law journal subscription',
        amount: 1200,
        date: day(22),
        category: 'Books',
        type: expenseTypePersonal,
      ),
      _ExpenseItem(
        id: 'e3',
        title: 'Travel to High Court',
        amount: 800,
        date: day(27),
        category: 'Travel',
        type: expenseTypeCase,
        linkedCase: 'Property Ownership Dispute',
      ),
    ];
  }

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // null means the "All" chip is selected.
  String? _selectedType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ExpenseItem> get _filteredExpenses {
    final query = _query.trim().toLowerCase();

    final list = _expenses.where((item) {
      final matchesType = _selectedType == null || item.type == _selectedType;

      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          (item.linkedCase?.toLowerCase().contains(query) ?? false);

      return matchesType && matchesQuery;
    }).toList();

    // Newest first.
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double _thisMonthTotal({required bool Function(_ExpenseItem) where}) {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.year == now.year && e.date.month == now.month && where(e))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // ------------------------------------------------
  // Actions
  // ------------------------------------------------

  Future<void> _addExpense() async {
    final result = await Navigator.of(context).push<ExpenseFormData>(
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
    if (!mounted || result == null) return;

    setState(() {
      _expenses.insert(
        0,
        _ExpenseItem(
          id: 'e${DateTime.now().microsecondsSinceEpoch}',
          title: result.title,
          amount: result.amount,
          date: result.date,
          category: result.category,
          type: result.type,
          linkedCase: result.linkedCase,
        ),
      );
    });
    // TODO: create the expense in your repository / provider.

    showAppSnackBar(context, 'Expense added');
  }

  Future<void> _editExpense(_ExpenseItem item) async {
    final result = await Navigator.of(context).push<ExpenseFormData>(
      MaterialPageRoute(
        builder: (_) => EditExpenseScreen(initial: item.toFormData()),
      ),
    );
    if (!mounted || result == null) return;

    setState(() {
      final index = _expenses.indexWhere((e) => e.id == item.id);
      if (index != -1) _expenses[index] = item.updatedWith(result);
    });
    // TODO: save the updated expense to your repository / provider.

    showAppSnackBar(context, 'Expense updated');
  }

  Future<void> _showExpenseActions(_ExpenseItem item) async {
    FocusScope.of(context).unfocus();

    final action = await showModalBottomSheet<_ExpenseAction>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ExpenseActionsSheet(expenseTitle: item.title),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case _ExpenseAction.edit:
        await _editExpense(item);
      case _ExpenseAction.remove:
        await _confirmRemove(item);
    }
  }

  Future<void> _confirmRemove(_ExpenseItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Remove expense?',
          style: TextStyle(
            color: AppColors.textNavy,
            fontSize: 17,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            letterSpacing: -0.43,
          ),
        ),
        content: Text(
          'Are you sure you want to remove "${item.title}"? '
          "This can't be undone.",
          style: const TextStyle(
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
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Remove',
              style: TextStyle(color: _errorColor),
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    setState(() => _expenses.removeWhere((e) => e.id == item.id));
    // TODO: delete the expense in your repository / provider.

    showAppSnackBar(context, 'Expense removed');
  }

  // ------------------------------------------------
  // Build
  // ------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final expenses = _filteredExpenses;

    final personalTotal =
        _thisMonthTotal(where: (e) => e.type == expenseTypePersonal);
    final caseTotal = _thisMonthTotal(where: (e) => e.isCaseRelated);

    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ExpenseHeader(
              onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
              onAdd: _addExpense,
            ),

            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  AppBottomNav.contentBottomSpace(context),
                ),
                children: [
                  _SearchField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  _SummaryCard(
                    personal: personalTotal,
                    caseRelated: caseTotal,
                  ),
                  _TypeFilters(
                    selected: _selectedType,
                    onSelected: (type) => setState(() => _selectedType = type),
                  ),
                  if (expenses.isEmpty)
                    const _EmptyState()
                  else
                    for (int i = 0; i < expenses.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _ExpenseCard(
                        item: expenses[i],
                        onMenuTap: () => _showExpenseActions(expenses[i]),
                      ),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// HEADER
// --------------------------------------------------

class _ExpenseHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onAdd;

  const _ExpenseHeader({required this.onBack, required this.onAdd});

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
              width: 29,
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: AppColors.textNavy,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Expenses',
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
          AppButton(
            text: 'Add',
            onPressed: onAdd,
            height: 36,
            borderRadius: 8,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// SEARCH (same as Cases / Clients / Tasks screens)
// --------------------------------------------------

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 17),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              size: 20,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                cursorColor: AppColors.textNavy,
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
                  hintText: 'Search title, case, or client',
                  hintStyle: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 15,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.23,
                  ),
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  controller.clear();
                  onChanged('');
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textMuted,
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
// SUMMARY CARD
// --------------------------------------------------

class _SummaryCard extends StatelessWidget {
  final double personal;
  final double caseRelated;

  const _SummaryCard({required this.personal, required this.caseRelated});

  @override
  Widget build(BuildContext context) {
    const mutedStyle = TextStyle(
      color: AppColors.textMuted,
      fontSize: 12,
      fontFamily: 'SF Pro',
      fontWeight: FontWeight.w400,
      height: 1.33,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This month', style: mutedStyle),
          Text(
            _formatAmount(personal + caseRelated),
            style: const TextStyle(
              color: AppColors.textNavy,
              fontSize: 24,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
              height: 1.33,
              letterSpacing: 0.07,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 24,
            runSpacing: 2,
            children: [
              Text('Personal ${_formatAmount(personal)}', style: mutedStyle),
              Text(
                'Case-related ${_formatAmount(caseRelated)}',
                style: mutedStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// TYPE FILTER CHIPS
// --------------------------------------------------

class _TypeFilters extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _TypeFilters({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: selected == null,
              onTap: () => onSelected(null),
            ),
            for (final type in expenseTypes) ...[
              const SizedBox(width: 8),
              _FilterChip(
                label: type,
                isSelected: selected == type,
                onTap: () => onSelected(type),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textNavy : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            width: 1,
            color: isSelected ? AppColors.textNavy : AppColors.border,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textMuted,
            fontSize: 12,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
            height: 1.33,
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// EXPENSE CARD
// --------------------------------------------------

class _ExpenseCard extends StatelessWidget {
  final _ExpenseItem item;
  final VoidCallback onMenuTap;

  const _ExpenseCard({required this.item, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                    letterSpacing: -0.31,
                  ),
                ),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatAmount(item.amount),
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
              height: 1.50,
              letterSpacing: -0.31,
            ),
          ),
          // Three-dot menu (Edit / Remove)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onMenuTap,
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Icon(
                Icons.more_vert_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// ACTIONS BOTTOM SHEET (Edit / Remove)
// --------------------------------------------------

class _ExpenseActionsSheet extends StatelessWidget {
  final String expenseTitle;

  const _ExpenseActionsSheet({required this.expenseTitle});

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
              expenseTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
          _SheetOption(
            icon: Icons.edit_outlined,
            label: 'Edit',
            color: AppColors.textDark,
            onTap: () => Navigator.of(context).pop(_ExpenseAction.edit),
          ),
          _SheetOption(
            icon: Icons.delete_outline_rounded,
            label: 'Remove',
            color: _errorColor,
            onTap: () => Navigator.of(context).pop(_ExpenseAction.remove),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                letterSpacing: -0.23,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// EMPTY STATE
// --------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 32,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 8),
            Text(
              'No expenses found',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                height: 1.50,
                letterSpacing: -0.31,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Try a different search or filter.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                height: 1.33,
              ),
            ),
          ],
        ),
      ),
    );
  }
}