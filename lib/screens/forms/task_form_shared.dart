import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';

// --------------------------------------------------
// DATA
// --------------------------------------------------

/// What the add / edit form hands back when saved.
/// The screen pops with this object: `Navigator.pop(context, data)`.
class TaskFormData {
  final String title;
  final String description;
  final DateTime dueDate;
  final TimeOfDay? time;
  final String priority; // 'High' | 'Medium' | 'Low'
  final String? linkedCase; // null = no linked case
  final String assignedTo;

  const TaskFormData({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.time,
    required this.priority,
    required this.linkedCase,
    required this.assignedTo,
  });
}

const List<String> taskPriorityOptions = ['High', 'Medium', 'Low'];
const String taskDefaultPriority = 'Medium';
const String taskDefaultAssignee = 'Me';
const String taskNoCaseLabel = 'None';

// Replace with real data from your repository / provider later.
const List<String> taskCases = [
  'Rahman vs Karim',
  'Property Ownership Dispute',
  'Commercial Contract Matter',
  'Akter Family Settlement',
];
const List<String> taskAssignees = [
  taskDefaultAssignee,
  'Junior Associate',
  'Clerk',
];

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatTaskDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

// --------------------------------------------------
// SHARED STYLES
// --------------------------------------------------

const Color taskErrorColor = Color(0xFFC0392B);

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
  color: taskErrorColor,
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
      color: hasError ? taskErrorColor : AppColors.border,
    ),
  );
}

// --------------------------------------------------
// SHARED HELPERS
// --------------------------------------------------

/// Theme wrapper for date / time pickers.
Widget taskPickerTheme(BuildContext context, Widget? child) {
  final theme = Theme.of(context);
  return Theme(
    data: theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        primary: AppColors.textNavy,
        onPrimary: AppColors.white,
        surface: AppColors.surface,
      ),
    ),
    child: child!,
  );
}

Future<String?> showTaskOptionSheet(
  BuildContext context, {
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
    builder: (_) => TaskOptionSheet(
      title: title,
      options: options,
      selected: selected,
    ),
  );
}

/// Asks the user whether to throw away unsaved changes.
Future<bool> confirmDiscardTaskChanges(
  BuildContext context, {
  required String message,
}) async {
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
      content: Text(
        message,
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
            'Keep editing',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text(
            'Discard',
            style: TextStyle(color: taskErrorColor),
          ),
        ),
      ],
    ),
  );
  return discard == true;
}

// --------------------------------------------------
// HEADER
// --------------------------------------------------

class TaskFormHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const TaskFormHeader({super.key, required this.title, required this.onBack});

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
// FORM FIELDS
// --------------------------------------------------

class TaskFormField extends StatelessWidget {
  final String label;
  final Widget child;
  final String? errorText;

  const TaskFormField({
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

class TaskTextInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool hasError;
  final bool multiline;
  final TextCapitalization textCapitalization;

  const TaskTextInput({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hasError = false,
    this.multiline = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: multiline ? 80 : 44,
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
        keyboardType: multiline ? TextInputType.multiline : TextInputType.text,
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

/// Tappable field that shows a value (or placeholder) and opens a picker.
class TaskSelectField extends StatelessWidget {
  final String? text;
  final String placeholder;
  final VoidCallback onTap;
  final bool hasError;
  final IconData trailingIcon;

  const TaskSelectField({
    super.key,
    required this.text,
    required this.placeholder,
    required this.onTap,
    this.hasError = false,
    this.trailingIcon = Icons.keyboard_arrow_down_rounded,
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
        decoration: _fieldDecoration(hasError: hasError),
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
            Icon(
              trailingIcon,
              size: trailingIcon == Icons.keyboard_arrow_down_rounded ? 20 : 18,
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

class TaskOptionSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;

  const TaskOptionSheet({
    super.key,
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

class TaskSaveBar extends StatelessWidget {
  final String text;
  final VoidCallback onSave;

  const TaskSaveBar({super.key, required this.text, required this.onSave});

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
          text: text,
          onPressed: onSave,
          height: 44,
          borderRadius: 8,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}