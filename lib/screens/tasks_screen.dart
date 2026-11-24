import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_bottom_nav.dart';

// --------------------------------------------------
// DATA
// --------------------------------------------------

enum _TaskPriority {
  high('High', AppColors.priorityHigh),
  medium('Medium', AppColors.priorityMedium),
  low('Low', AppColors.priorityLow);

  const _TaskPriority(this.label, this.color);

  final String label;
  final Color color;
}

enum _TaskStatus { current, pending, completed }

class _TaskItem {
  final String id;
  final String title;
  final String due;
  final _TaskPriority priority;
  final _TaskStatus status;

  const _TaskItem({
    required this.id,
    required this.title,
    required this.due,
    required this.priority,
    required this.status,
  });

  _TaskItem copyWith({_TaskStatus? status}) {
    return _TaskItem(
      id: id,
      title: title,
      due: due,
      priority: priority,
      status: status ?? this.status,
    );
  }
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
    const _TaskItem(
      id: 't1',
      title: 'Renew chamber license',
      due: 'Due 29 Oct',
      priority: _TaskPriority.medium,
      status: _TaskStatus.current,
    ),
    const _TaskItem(
      id: 't2',
      title: 'Call Sabina Akter',
      due: 'Due 31 Oct',
      priority: _TaskPriority.low,
      status: _TaskStatus.current,
    ),
    const _TaskItem(
      id: 't3',
      title: 'Draft written statement',
      due: 'Due 28 Oct',
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

  // Tapping the circle completes a task, or reopens a completed one.
  void _toggleComplete(_TaskItem task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index == -1) return;

      _tasks[index] = task.copyWith(
        status: task.status == _TaskStatus.completed
            ? _TaskStatus.current
            : _TaskStatus.completed,
      );
    });
  }

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
                  _TasksHeader(
                    onAddTask: () {
                      // TODO: open the Add Task screen.
                    },
                  ),
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
                        ),
                        _TaskSection(
                          title: 'PENDING',
                          tasks: _byStatus(tasks, _TaskStatus.pending),
                          onToggle: _toggleComplete,
                        ),
                        _TaskSection(
                          title: 'COMPLETED',
                          tasks: _byStatus(tasks, _TaskStatus.completed),
                          onToggle: _toggleComplete,
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

  const _TaskSection({
    required this.title,
    required this.tasks,
    required this.onToggle,
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

  const _TaskCard({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final bool isDone = task.status == _TaskStatus.completed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(right: 12),
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
                          text: '${task.due} · ',
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
        ],
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