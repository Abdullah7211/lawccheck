import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_bottom_nav.dart';

// --------------------------------------------------
// DATA
// --------------------------------------------------

enum _EntryType { hearing, deadline, task }

class _ScheduleEntry {
  final DateTime date;
  final String? time; // HH:mm, optional
  final _EntryType type;

  // Hearing fields
  final String? title;
  final String? caseNumber;
  final String? client;
  final String? venue;

  // Deadline / task label
  final String? label;

  const _ScheduleEntry.hearing({
    required this.date,
    required this.time,
    required String this.title,
    required String this.caseNumber,
    required String this.client,
    required String this.venue,
  })  : type = _EntryType.hearing,
        label = null;

  const _ScheduleEntry.deadline({
    required this.date,
    required String this.label,
  })  : type = _EntryType.deadline,
        time = null,
        title = null,
        caseNumber = null,
        client = null,
        venue = null;

  const _ScheduleEntry.task({
    required this.date,
    required String this.label,
    this.time,
  })  : type = _EntryType.task,
        title = null,
        caseNumber = null,
        client = null,
        venue = null;

  /// "8 Oct"
  String get dateLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  /// Everything after the bold date, e.g. " 10:00 · Rahman vs Karim ..."
  String get detailText {
    final timePart = time == null ? '' : ' $time';

    switch (type) {
      case _EntryType.hearing:
        return '$timePart · $title ($caseNumber) · $client · $venue';
      case _EntryType.deadline:
        return '$timePart · Deadline: $label';
      case _EntryType.task:
        return '$timePart · Task: $label';
    }
  }

  bool matches(String query) {
    final haystack = [
      title,
      caseNumber,
      client,
      venue,
      label,
    ].whereType<String>().join(' ').toLowerCase();
    return haystack.contains(query);
  }
}

// --------------------------------------------------
// SCREEN
// --------------------------------------------------

class MonthlyScheduleScreen extends StatefulWidget {
  /// Called when the back arrow is tapped. When this screen is shown inside
  /// MainNavigationScreen, pass a callback that switches back to Home.
  /// When null, it simply pops the route.
  final VoidCallback? onBack;

  const MonthlyScheduleScreen({super.key, this.onBack});

  @override
  State<MonthlyScheduleScreen> createState() => _MonthlyScheduleScreenState();
}

class _MonthlyScheduleScreenState extends State<MonthlyScheduleScreen> {
  // Replace with real data from your repository / provider later.
  static final List<_ScheduleEntry> _allEntries = [
    _ScheduleEntry.hearing(
      date: DateTime(2026, 10, 8),
      time: '10:00',
      title: 'Rahman vs Karim',
      caseNumber: 'CS-2024/118',
      client: 'Rafiq Rahman',
      venue: 'District Court, Dhaka, Court 4',
    ),
    _ScheduleEntry.deadline(
      date: DateTime(2026, 10, 28),
      label: 'File reply to injunction',
    ),
    _ScheduleEntry.hearing(
      date: DateTime(2026, 10, 28),
      time: '10:30',
      title: 'Rahman vs Karim',
      caseNumber: 'CS-2024/118',
      client: 'Rafiq Rahman',
      venue: 'District Court, Dhaka, Court 4',
    ),
    _ScheduleEntry.hearing(
      date: DateTime(2026, 10, 28),
      time: '12:00',
      title: 'Property Ownership Dispute',
      caseNumber: 'CS-2023/402',
      client: 'Nusrat Traders Ltd',
      venue: 'High Court Division, Bench 2',
    ),
    _ScheduleEntry.hearing(
      date: DateTime(2026, 10, 28),
      time: '14:30',
      title: 'Commercial Contract Matter',
      caseNumber: 'CS-2024/077',
      client: 'Nusrat Traders Ltd',
      venue: 'Commercial Court, Room 11',
    ),
    _ScheduleEntry.task(
      date: DateTime(2026, 10, 28),
      time: '16:00',
      label: 'Draft written statement',
    ),
    _ScheduleEntry.task(
      date: DateTime(2026, 10, 29),
      label: 'Renew chamber license',
    ),
    _ScheduleEntry.hearing(
      date: DateTime(2026, 10, 30),
      time: '13:00',
      title: 'Commercial Contract Matter',
      caseNumber: 'CS-2024/077',
      client: 'Nusrat Traders Ltd',
      venue: 'Commercial Court, Room 11',
    ),
    _ScheduleEntry.task(
      date: DateTime(2026, 10, 31),
      time: '11:00',
      label: 'Call Sabina Akter',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  bool _showTasks = true;

  // Month shown in the card title.
  final DateTime _month = DateTime(2026, 10);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _monthTitle {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return 'Schedule — ${months[_month.month - 1]} ${_month.year}';
  }

  List<_ScheduleEntry> get _filteredEntries {
    final query = _query.trim().toLowerCase();

    final list = _allEntries.where((entry) {
      if (entry.date.year != _month.year || entry.date.month != _month.month) {
        return false;
      }
      if (!_showTasks && entry.type == _EntryType.task) return false;
      if (query.isNotEmpty && !entry.matches(query)) return false;
      return true;
    }).toList();

    // Sort by date, then by time (entries without time first).
    list.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      if (byDate != 0) return byDate;
      return (a.time ?? '').compareTo(b.time ?? '');
    });

    return list;
  }

  void _onPrintPdf() {
    // TODO: generate the PDF from `_filteredEntries`
    // (e.g. with the `pdf` + `printing` packages).
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ScheduleHeader(
              onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
              onPrint: _onPrintPdf,
            ),

            // Search + Tasks toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
              child: Row(
                children: [
                  Expanded(
                    child: _SearchField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _TasksCheckbox(
                    value: _showTasks,
                    onChanged: (value) => setState(() => _showTasks = value),
                  ),
                ],
              ),
            ),

            // Schedule card
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  AppBottomNav.contentBottomSpace(context),
                ),
                child: _ScheduleCard(
                  title: _monthTitle,
                  entries: entries,
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
// HEADER
// --------------------------------------------------

class _ScheduleHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onPrint;

  const _ScheduleHeader({required this.onBack, required this.onPrint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(width: 1, color: AppColors.border),
        ),
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
              'Monthly schedule',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
            text: 'Print / Save PDF',
            onPressed: onPrint,
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
// SEARCH
// --------------------------------------------------

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            size: 16,
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
                hintText: 'Search Name',
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
    );
  }
}

// --------------------------------------------------
// TASKS CHECKBOX
// --------------------------------------------------

class _TasksCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TasksCheckbox({required this.value, required this.onChanged});

  static const Color _blue = Color(0xFF0075FF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: SizedBox(
        height: 44,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: value ? _blue : Colors.white,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  width: 1,
                  color: value ? _blue : const Color(0xFF767676),
                ),
              ),
              child: value
                  ? const Icon(Icons.check_rounded, size: 11, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            const Text(
              'Tasks',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                height: 1.43,
                letterSpacing: -0.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// SCHEDULE CARD
// --------------------------------------------------

class _ScheduleCard extends StatelessWidget {
  final String title;
  final List<_ScheduleEntry> entries;

  const _ScheduleCard({required this.title, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(width: 1, color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
              height: 1.56,
              letterSpacing: -0.44,
            ),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const _EmptyState()
          else
            for (int i = 0; i < entries.length; i++)
              _ScheduleRow(
                entry: entries[i],
                showDivider: i != entries.length - 1,
              ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final _ScheduleEntry entry;
  final bool showDivider;

  const _ScheduleRow({required this.entry, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          top: const BorderSide(width: 1, color: AppColors.border),
          bottom: showDivider
              ? BorderSide.none
              : const BorderSide(width: 1, color: AppColors.border),
        ),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: entry.dateLabel,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 12,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            TextSpan(
              text: entry.detailText,
              style: const TextStyle(
                color: AppColors.textDark,
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

// --------------------------------------------------
// EMPTY STATE
// --------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
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
              'Nothing scheduled',
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