import 'package:material_ui/material_ui.dart';

import '../forms/add_expense_screen.dart';

/// Edit form for an existing expense. Opens pre-filled with [initial] and
/// pops with the updated [ExpenseFormData] on save.
class EditExpenseScreen extends StatelessWidget {
  final ExpenseFormData initial;

  const EditExpenseScreen({super.key, required this.initial});

  @override
  Widget build(BuildContext context) {
    return ExpenseFormScreen(
      title: 'Edit Expense',
      saveText: 'Save changes',
      initial: initial,
    );
  }
}