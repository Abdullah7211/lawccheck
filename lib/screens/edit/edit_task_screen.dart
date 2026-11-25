import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../forms/task_form_shared.dart';

/// Form for editing an existing task.
/// Pops with the updated [TaskFormData], or with nothing if the user saved
/// without changing anything.
class EditTaskScreen extends StatefulWidget {
  final TaskFormData initial;

  const EditTaskScreen({super.key, required this.initial});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;

  // Keys used to scroll to the first field with an error.
  final _titleKey = GlobalKey();
  final _dueKey = GlobalKey();

  late DateTime? _dueDate;
  late TimeOfDay? _time;
  late String _priority;
  late String? _linkedCase;
  late String _assignedTo;

  String? _titleError;
  String? _dueError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleCtrl = TextEditingController(text: initial.title);
    _descriptionCtrl = TextEditingController(text: initial.description);
    _dueDate = initial.dueDate;
    _time = initial.time;
    _priority = initial.priority;
    _linkedCase = initial.linkedCase;
    _assignedTo = initial.assignedTo;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------
  // State helpers
  // ------------------------------------------------

  /// True when anything differs from the saved task.
  bool get _hasChanges {
    final initial = widget.initial;
    return _titleCtrl.text.trim() != initial.title.trim() ||
        _descriptionCtrl.text.trim() != initial.description.trim() ||
        _dueDate != initial.dueDate ||
        _time != initial.time ||
        _priority != initial.priority ||
        _linkedCase != initial.linkedCase ||
        _assignedTo != initial.assignedTo;
  }

  void _onTextChanged() {
    if (_titleError == null) return;
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _titleError = null);
  }

  // ------------------------------------------------
  // Pickers
  // ------------------------------------------------

  Future<void> _pickDueDate() async {
    FocusScope.of(context).unfocus();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final current = _dueDate;

    // Editing an overdue task: still allow its existing date.
    final firstDate =
        (current != null && current.isBefore(todayDate)) ? current : todayDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? todayDate,
      firstDate: firstDate,
      lastDate: DateTime(today.year + 10),
      builder: taskPickerTheme,
    );
    if (!mounted || picked == null) return;

    setState(() {
      _dueDate = picked;
      _dueError = null;
    });
  }

  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 10, minute: 0),
      builder: taskPickerTheme,
    );
    if (!mounted || picked == null) return;
    setState(() => _time = picked);
  }

  Future<void> _pickPriority() async {
    FocusScope.of(context).unfocus();
    final value = await showTaskOptionSheet(
      context,
      title: 'Priority',
      options: taskPriorityOptions,
      selected: _priority,
    );
    if (!mounted || value == null) return;
    setState(() => _priority = value);
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

  Future<void> _pickAssignee() async {
    FocusScope.of(context).unfocus();
    final value = await showTaskOptionSheet(
      context,
      title: 'Assign to',
      options: taskAssignees,
      selected: _assignedTo,
    );
    if (!mounted || value == null) return;
    setState(() => _assignedTo = value);
  }

  // ------------------------------------------------
  // Validation + save
  // ------------------------------------------------

  bool _validate() {
    final titleError =
        _titleCtrl.text.trim().isEmpty ? 'Enter a task title' : null;
    final dueError = _dueDate == null ? 'Pick a due date' : null;

    setState(() {
      _titleError = titleError;
      _dueError = dueError;
    });

    final GlobalKey? firstInvalid = titleError != null
        ? _titleKey
        : dueError != null
            ? _dueKey
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

    // Nothing changed: just close, no result.
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    // TODO (backend): send this to the API / repository if you save here.
    // The caller also receives it, so you can save from either place.
    Navigator.of(context).pop(
      TaskFormData(
        title: _titleCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        dueDate: _dueDate!,
        time: _time,
        priority: _priority,
        linkedCase: _linkedCase,
        assignedTo: _assignedTo,
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
      message: 'Your changes to this task will be lost.',
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
              TaskFormHeader(title: 'Edit Task', onBack: _handleBack),
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
                        label: 'Description',
                        child: TaskTextInput(
                          controller: _descriptionCtrl,
                          onChanged: (_) {},
                          multiline: true,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Expanded(
                            child: TaskFormField(
                              key: _dueKey,
                              label: 'Due date *',
                              errorText: _dueError,
                              child: TaskSelectField(
                                text: _dueDate == null
                                    ? null
                                    : formatTaskDate(_dueDate!),
                                placeholder: 'Select date',
                                hasError: _dueError != null,
                                trailingIcon: Icons.calendar_today_rounded,
                                onTap: _pickDueDate,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TaskFormField(
                              label: 'Time',
                              child: TaskSelectField(
                                text: _time?.format(context),
                                placeholder: 'Select time',
                                trailingIcon: Icons.access_time_rounded,
                                onTap: _pickTime,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TaskFormField(
                        label: 'Priority',
                        child: TaskSelectField(
                          text: _priority,
                          placeholder: 'Select priority',
                          onTap: _pickPriority,
                        ),
                      ),
                      TaskFormField(
                        label: 'Linked case',
                        child: TaskSelectField(
                          text: _linkedCase ?? taskNoCaseLabel,
                          placeholder: 'Select case',
                          onTap: _pickLinkedCase,
                        ),
                      ),
                      TaskFormField(
                        label: 'Assign to',
                        child: TaskSelectField(
                          text: _assignedTo,
                          placeholder: 'Select assignee',
                          onTap: _pickAssignee,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TaskSaveBar(text: 'Save Changes', onSave: _save),
            ],
          ),
        ),
      ),
    );
  }
}