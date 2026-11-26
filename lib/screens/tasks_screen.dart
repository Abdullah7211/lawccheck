import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_bottom_nav.dart';
import 'forms/add_task_screen.dart';
import 'edit/edit_task_screen.dart';
import '../widgets/app_snackbar.dart';

// --------------------------------------------------
// DATA
// --------------------------------------------------

const Color _errorColor = Color(0xFFC0392B);

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

enum _TaskPriority {
  high('High', AppColors.priorityHigh),
  medium('Medium', AppColors.priorityMedium),
  low('Low', AppColors.priorityLow);

  const _TaskPriority(this.label, this.color);

  final String label;
  final Color color;

  static _TaskPriority fromLabel(String label) {
    return values.firstWhere(
      (p) => p.label == label,
      orElse: () => _TaskPriority.medium,
    );
  }
}

enum _TaskStatus {
  current('Current'),
  pending('Pending'),
  completed('Completed');

  const _TaskStatus(this.label);

  final String label;
}

enum _TaskAction { edit, changeStatus, remove }

class _TaskItem {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TimeOfDay? time;
  final _TaskPriority priority;
  final _TaskStatus status;
  final String? linkedCase;
  final String assignedTo;

  const _TaskItem({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.priority,
    required this.status,
    this.description = '',
    this.time,
    this.linkedCase,
    this.assignedTo = 'Me',
  });

  /// e.g. "Due 29 Oct" or "Due 29 Oct, 10:30"
  String get dueLabel {
    final date = '${dueDate.day} ${_months[dueDate.month - 1]}';
    final t = time;
    if (t == null) return 'Due $date';

    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return 'Due $date, $hh:$mm';
  }

  _TaskItem copyWith({_TaskStatus? status}) {
    return _TaskItem(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      time: time,
      priority: priority,
      status: status ?? this.status,
      linkedCase: linkedCase,
      assignedTo: assignedTo,
    );
  }

  TaskFormData toFormData() => TaskFormData(
        title: title,
        description: description,
        dueDate: dueDate,
        time: time,
        priority: priority.label,
        linkedCase: linkedCase,
        assignedTo: assignedTo,
      );

  /// Same task (same id / status) with the edited form values applied.
  _TaskItem updatedWith(TaskFormData data) => _TaskItem(
        id: id,
        title: data.title,
        description: data.description,
        dueDate: data.dueDate,
        time: data.time,
        priority: _TaskPriority.fromLabel(data.priority),
        status: status,
        linkedCase: data.linkedCase,
        assignedTo: data.assignedTo,
      );
}

// --------------------------------------------------
// SCREEN
// --------------------------------------------------

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // Replace with real data from your repository / provider later.
  final List<_TaskItem> _tasks = [
    _TaskItem(
      id: 't1',
      title: 'Renew chamber license',
      dueDate: DateTime(2026, 10, 29),
      priority: _TaskPriority.medium,
      status: _TaskStatus.current,
    ),
    _TaskItem(
      id: 't2',
      title: 'Call Sabina Akter',
      dueDate: DateTime(2026, 10, 31),
      priority: _TaskPriority.low,
      status: _TaskStatus.current,
    ),
    _TaskItem(
      id: 't3',
      title: 'Draft written statement',
      dueDate: DateTime(2026, 10, 28),
      priority: _TaskPriority.high,
      status: _TaskStatus.pending,
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_TaskItem> get _filteredTasks {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _tasks;

    return _tasks.where((task) {
      return task.title.toLowerCase().contains(query);
    }).toList();
  }

  List<_TaskItem> _byStatus(List<_TaskItem> tasks, _TaskStatus status) {
    return tasks.where((task) => task.status == status).toList();
  }

  void _showMessage(String message) => showAppSnackBar(context, message);

  // ------------------------------------------------
  // Actions
  // ------------------------------------------------

  void _setStatus(_TaskItem task, _TaskStatus status) {
    if (task.status == status) return;

    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index == -1) return;
      _tasks[index] = task.copyWith(status: status);
    });
    // TODO: save the new status to your repository / provider.
  }

  // Tapping the circle completes a task, or reopens a completed one.
  void _toggleComplete(_TaskItem task) {
    _setStatus(
      task,
      task.status == _TaskStatus.completed
          ? _TaskStatus.current
          : _TaskStatus.completed,
    );
  }

  Future<void> _addTask() async {
    final result = await Navigator.of(context).push<TaskFormData>(
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
    if (!mounted || result == null) return;

    setState(() {
      _tasks.insert(
        0,
        _TaskItem(
          id: 't${DateTime.now().microsecondsSinceEpoch}',
          title: result.title,
          description: result.description,
          dueDate: result.dueDate,
          time: result.time,
          priority: _TaskPriority.fromLabel(result.priority),
          status: _TaskStatus.current,
          linkedCase: result.linkedCase,
          assignedTo: result.assignedTo,
        ),
      );
    });
    // TODO: create the task in your repository / provider.

    _showMessage('Task added');
  }

  Future<void> _editTask(_TaskItem task) async {
    final result = await Navigator.of(context).push<TaskFormData>(
      MaterialPageRoute(
        builder: (_) => EditTaskScreen(initial: task.toFormData()),
      ),
    );
    if (!mounted || result == null) return;

    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) _tasks[index] = task.updatedWith(result);
    });
    // TODO: save the updated task to your repository / provider.

    _showMessage('Task updated');
  }

  Future<void> _showTaskActions(_TaskItem task) async {
    FocusScope.of(context).unfocus();

    final action = await showModalBottomSheet<_TaskAction>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _TaskActionsSheet(taskTitle: task.title),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case _TaskAction.edit:
        await _editTask(task);
      case _TaskAction.changeStatus:
        await _changeStatus(task);
      case _TaskAction.remove:
        await _confirmRemove(task);
    }
  }

  Future<void> _changeStatus(_TaskItem task) async {
    final status = await showModalBottomSheet<_TaskStatus>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _StatusSheet(current: task.status),
    );
    if (!mounted || status == null || status == task.status) return;

    _setStatus(task, status);
    _showMessage('Moved to ${status.label}');
  }

  Future<void> _confirmRemove(_TaskItem task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Remove task?',
          style: TextStyle(
            color: AppColors.textNavy,
            fontSize: 17,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            letterSpacing: -0.43,
          ),
        ),
        content: Text(
          'Are you sure you want to remove "${task.title}"? '
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

    setState(() => _tasks.removeWhere((t) => t.id == task.id));
    // TODO: delete the task in your repository / provider.

    _showMessage('Task removed');
  }

  // ------------------------------------------------
  // Build
  // ------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tasks = _filteredTasks;
    final bool isSearching = _query.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed top area: title + search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TasksHeader(onAddTask: _addTask),
                  _SearchField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ],
              ),
            ),

            // Scrollable sections
            Expanded(
              child: (isSearching && tasks.isEmpty)
                  ? const _EmptyState()
                  : ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        AppBottomNav.contentBottomSpace(context),
                      ),
                      children: [
                        _TaskSection(
                          title: 'CURRENT',
                          tasks: _byStatus(tasks, _TaskStatus.current),
                          onToggle: _toggleComplete,
                          onMenuTap: _showTaskActions,
                        ),
                        _TaskSection(
                          title: 'PENDING',
                          tasks: _byStatus(tasks, _TaskStatus.pending),
                          onToggle: _toggleComplete,
                          onMenuTap: _showTaskActions,
                        ),
                        _TaskSection(
                          title: 'COMPLETED',
                          tasks: _byStatus(tasks, _TaskStatus.completed),
                          onToggle: _toggleComplete,
                          onMenuTap: _showTaskActions,
                        ),
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

class _TasksHeader extends StatelessWidget {
  final VoidCallback onAddTask;

  const _TasksHeader({required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Tasks',
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
            text: 'Add Task',
            onPressed: onAddTask,
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
// SEARCH (same as Cases and Clients screens)
// --------------------------------------------------

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
                  hintText: 'Search Tasks',
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
// SECTION
// --------------------------------------------------

class _TaskSection extends StatelessWidget {
  final String title;
  final List<_TaskItem> tasks;
  final ValueChanged<_TaskItem> onToggle;
  final ValueChanged<_TaskItem> onMenuTap;

  const _TaskSection({
    required this.title,
    required this.tasks,
    required this.onToggle,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            '$title · ${tasks.length}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
              height: 1.33,
              letterSpacing: 0.30,
            ),
          ),
        ),
        for (int i = 0; i < tasks.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _TaskCard(
            task: tasks[i],
            onToggle: () => onToggle(tasks[i]),
            onMenuTap: () => onMenuTap(tasks[i]),
          ),
        ],
      ],
    );
  }
}

// --------------------------------------------------
// TASK CARD
// --------------------------------------------------

class _TaskCard extends StatelessWidget {
  final _TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onMenuTap;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = task.status == _TaskStatus.completed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox circle (48x48 tap area, 20px circle)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.textNavy : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 1,
                      color: isDone
                          ? AppColors.textNavy
                          : AppColors.textMuted,
                    ),
                  ),
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: AppColors.white,
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Title + due/priority
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDone
                          ? AppColors.textMuted
                          : AppColors.textDark,
                      fontSize: 15,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                      letterSpacing: -0.23,
                      decoration:
                          isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${task.dueLabel} · ',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                            height: 1.33,
                          ),
                        ),
                        TextSpan(
                          text: task.priority.label,
                          style: TextStyle(
                            color: task.priority.color,
                            fontSize: 12,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                            height: 1.33,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Three-dot menu
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
// BOTTOM SHEETS (actions / status)
// --------------------------------------------------

class _TaskActionsSheet extends StatelessWidget {
  final String taskTitle;

  const _TaskActionsSheet({required this.taskTitle});

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
              taskTitle,
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
            onTap: () => Navigator.of(context).pop(_TaskAction.edit),
          ),
          _SheetOption(
            icon: Icons.swap_horiz_rounded,
            label: 'Change status',
            color: AppColors.textDark,
            onTap: () => Navigator.of(context).pop(_TaskAction.changeStatus),
          ),
          _SheetOption(
            icon: Icons.delete_outline_rounded,
            label: 'Remove',
            color: _errorColor,
            onTap: () => Navigator.of(context).pop(_TaskAction.remove),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StatusSheet extends StatelessWidget {
  final _TaskStatus current;

  const _StatusSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Change status',
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
          for (final status in _TaskStatus.values)
            InkWell(
              onTap: () => Navigator.of(context).pop(status),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        status.label,
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 15,
                          fontFamily: 'SF Pro',
                          fontWeight: status == current
                              ? FontWeight.w600
                              : FontWeight.w400,
                          letterSpacing: -0.23,
                        ),
                      ),
                    ),
                    if (status == current)
                      const Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: AppColors.textNavy,
                      ),
                  ],
                ),
              ),
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        AppBottomNav.contentBottomSpace(context),
      ),
      child: const Center(
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
              'No tasks found',
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
              'Try a different search.',
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