import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

enum CalendarView { month, week }

enum CalendarEventType { hearing, task }

class CalendarEvent {
  final DateTime dateTime;
  final String title;
  final String subtitle;
  final CalendarEventType type;
  final bool isHighPriority;

  const CalendarEvent({
    required this.dateTime,
    required this.title,
    required this.subtitle,
    required this.type,
    this.isHighPriority = false,
  });
}

class AppCalendar extends StatefulWidget {
  final List<CalendarEvent> events;
  final ValueChanged<DateTime>? onDayTap;

  const AppCalendar({
    super.key,
    this.events = const [],
    this.onDayTap,
  });

  @override
  State<AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<AppCalendar> {
  late DateTime _focusedDate;

  DateTime? _selectedDate;

  CalendarView _view = CalendarView.month;

  // Fonts from the Figma file (add them to pubspec.yaml).
  static const String _serifFont = 'Fraunces';
  static const String _bodyFont = 'Inter';
  static const String _toggleFont = 'SF Pro';

  @override
  void initState() {
    super.initState();

    // Always open on the current month.
    _focusedDate = DateTime.now();
  }

  static const List<String> _weekdays = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];

  static const List<String> _fullWeekdays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  bool _isSelected(DateTime date) {
    return _selectedDate != null && _isSameDay(date, _selectedDate!);
  }

  bool _hasEvents(DateTime date) {
    return widget.events.any(
      (event) => _isSameDay(event.dateTime, date),
    );
  }

  List<CalendarEvent> _eventsForDay(DateTime date) {
    return widget.events
        .where((event) => _isSameDay(event.dateTime, date))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  int get _hearingCount {
    return widget.events
        .where(
          (event) =>
              event.type == CalendarEventType.hearing &&
              event.dateTime.year == _focusedDate.year &&
              event.dateTime.month == _focusedDate.month,
        )
        .length;
  }

  int get _taskCount {
    return widget.events
        .where(
          (event) =>
              event.type == CalendarEventType.task &&
              event.dateTime.year == _focusedDate.year &&
              event.dateTime.month == _focusedDate.month,
        )
        .length;
  }

  void _changeMonth(int amount) {
    setState(() {
      _focusedDate = DateTime(
        _focusedDate.year,
        _focusedDate.month + amount,
        1,
      );
    });
  }

  void _changeWeek(int amount) {
    setState(() {
      final currentDate = _selectedDate ?? _focusedDate;

      _focusedDate = currentDate.add(Duration(days: amount * 7));
      _selectedDate = _focusedDate;
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _focusedDate = date;
    });

    widget.onDayTap?.call(date);
  }

  @override
  Widget build(BuildContext context) {
    // Figma frame: 393 wide, 16px horizontal padding, centered column.
    // Remove this Padding if the parent screen already adds 16px.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          if (_view == CalendarView.month)
            _buildMonthView()
          else
            _buildWeekView(),
          const SizedBox(height: 16),
          _buildDayAgenda(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildChevron(
                  icon: Icons.chevron_left,
                  onPressed: () => _view == CalendarView.month
                      ? _changeMonth(-1)
                      : _changeWeek(-1),
                ),
                _buildMonthTitle(),
                _buildChevron(
                  icon: Icons.chevron_right,
                  onPressed: () => _view == CalendarView.month
                      ? _changeMonth(1)
                      : _changeWeek(1),
                ),
              ],
            ),
            Text(
              '$_hearingCount hearings · $_taskCount tasks this month',
              style: const TextStyle(
                fontFamily: _bodyFont,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 13.2 / 11,
                color: AppColors.calendarMutedText,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildViewToggle()),
      ],
    );
  }

  Widget _buildChevron({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: AppColors.calendarText,
        ),
      ),
    );
  }

  /// "October" in navy + "2026" in muted grey, Fraunces 16 / 600.
  /// Tapping opens the quick month / year picker.
  Widget _buildMonthTitle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _showMonthYearPicker,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${_months[_focusedDate.month - 1]} ',
                    style: const TextStyle(color: AppColors.primary),
                  ),
                  TextSpan(
                    text: '${_focusedDate.year}',
                    style: const TextStyle(color: AppColors.calendarMutedText),
                  ),
                ],
                style: const TextStyle(
                  fontFamily: _serifFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 24 / 16,
                ),
              ),
              maxLines: 1,
              softWrap: false,
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: AppColors.calendarText,
            ),
          ],
        ),
      ),
    );
  }

  /// Samsung-Calendar-style quick picker: year with arrows on top,
  /// 4 x 3 month grid below. Tapping a month applies it immediately.
  void _showMonthYearPicker() {
    int pickerYear = _focusedDate.year;
    final now = DateTime.now();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Year row:  <   2026   >
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () =>
                                setDialogState(() => pickerYear--),
                            icon: const Icon(
                              Icons.chevron_left,
                              color: AppColors.calendarText,
                            ),
                          ),
                          Text(
                            '$pickerYear',
                            style: const TextStyle(
                              fontFamily: _serifFont,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                setDialogState(() => pickerYear++),
                            icon: const Icon(
                              Icons.chevron_right,
                              color: AppColors.calendarText,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Month grid: 4 columns x 3 rows
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.5,
                        children: List.generate(12, (index) {
                          final month = index + 1;

                          final isSelected =
                              pickerYear == _focusedDate.year &&
                              month == _focusedDate.month;

                          final isCurrentMonth =
                              pickerYear == now.year && month == now.month;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _focusedDate = DateTime(pickerYear, month, 1);
                                _selectedDate = null;
                              });
                              Navigator.pop(dialogContext);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                border: isCurrentMonth && !isSelected
                                    ? Border.all(
                                        color: AppColors.primary,
                                        width: 1.3,
                                      )
                                    : null,
                              ),
                              child: Text(
                                _months[index].substring(0, 3),
                                style: TextStyle(
                                  fontFamily: _bodyFont,
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.calendarText,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 4),

                      // Footer actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _focusedDate = DateTime.now();
                                _selectedDate = null;
                              });
                              Navigator.pop(dialogContext);
                            },
                            child: const Text(
                              'Today',
                              style: TextStyle(
                                fontFamily: _bodyFont,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: _bodyFont,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.calendarMutedText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.calendarBorder,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleButton('Month', CalendarView.month)),
          Expanded(child: _buildToggleButton('Week', CalendarView.week)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, CalendarView view) {
    final isSelected = _view == view;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _view = view),
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.calendarToggleBackground
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 2,
                    spreadRadius: -1,
                    offset: const Offset(0, 1),
                  ),
                ]
              : const [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: _toggleFont,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 16 / 12,
            color: isSelected
                ? AppColors.navActiveIcon
                : AppColors.navInactive,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Month view
  // ---------------------------------------------------------------------------

  // Grid spec from Figma: 361 wide, 7 columns of 49px with 3px gaps
  // (7 * 49 + 6 * 3 = 361). Each date cell is 49 x 61.8, 3px gap between rows.
  static const double _cellWidth = 49;
  static const double _cellHeight = 61.8;
  static const double _gap = 3;

  Widget _buildMonthView() {
    final firstDay = DateTime(_focusedDate.year, _focusedDate.month, 1);

    final daysInMonth =
        DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;

    // Sunday is the first column.
    final leadingDays = firstDay.weekday % 7;

    final totalCells = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;
    final rows = totalCells ~/ 7;

    return Center(
      child: SizedBox(
        width: 361,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Weekday labels
            Row(
              children: List.generate(7, (column) {
                return Padding(
                  padding: EdgeInsets.only(left: column == 0 ? 0 : _gap),
                  child: SizedBox(
                    width: _cellWidth,
                    height: 50,
                    child: Center(
                      child: Text(
                        _weekdays[column],
                        style: const TextStyle(
                          fontFamily: _bodyFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 19.2 / 16,
                          color: AppColors.calendarText,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            ...List.generate(rows, (row) {
              return Padding(
                padding: const EdgeInsets.only(top: _gap),
                child: Row(
                  children: List.generate(7, (column) {
                    final index = row * 7 + column;
                    final dayNumber = index - leadingDays + 1;

                    final date = DateTime(
                      _focusedDate.year,
                      _focusedDate.month,
                      dayNumber,
                    );

                    return Padding(
                      padding: EdgeInsets.only(left: column == 0 ? 0 : _gap),
                      child: _buildDayCell(date),
                    );
                  }),
                ),
              );
            }),

            // Bottom gap
            const SizedBox(height: _gap),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isCurrentMonth = date.month == _focusedDate.month;
    final isSelected = _isSelected(date);
    final isToday = _isToday(date);
    final hasEvent = _hasEvents(date);

    Color background;
    if (isSelected) {
      background = AppColors.calendarSelectedDay; // #C8C8C8
    } else if (!isCurrentMonth) {
      background = AppColors.calendarOutsideDay; // #F5F4F0
    } else {
      background = AppColors.white;
    }

    Border? border;
    if (!isSelected && !isCurrentMonth) {
      // Previous / next month days: 1.5px inside border.
      border = Border.all(color: AppColors.calendarBorder, width: 1.5);
    } else if (!isSelected && isToday) {
      // Today gets a navy outline.
      border = Border.all(color: AppColors.primary, width: 1.3);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectDate(date),
      child: Container(
        width: _cellWidth,
        height: _cellHeight,
        // Figma: padding 10, content pinned to the top, centered horizontally.
        // Bottom padding is 0 so number (19.2) + gap (10) + dot (16) fits
        // inside the 61.8px cell.
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(32),
          border: border,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${date.day}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: _bodyFont,
                fontSize: 16,
                height: 19.2 / 16,
                fontWeight:
                    isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.calendarText,
              ),
            ),
            if (hasEvent) ...[
              const SizedBox(height: 10),
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.calendarEventGreen, // #09B100
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Day agenda (selected day heading + event cards)
  // ---------------------------------------------------------------------------

  Widget _buildDayAgenda() {
    final day = _selectedDate ?? DateTime.now();
    final dayEvents = _eventsForDay(day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // "Wednesday 28 October"
        Text(
          '${_fullWeekdays[day.weekday % 7]} ${day.day} ${_months[day.month - 1]}',
          style: const TextStyle(
            color: AppColors.calendarText, // #202B38
            fontSize: 19,
            fontFamily: _bodyFont,
            fontWeight: FontWeight.w600,
            height: 1.20,
          ),
        ),

        // "2 Case" (hidden on empty days, the empty card is shown instead)
        if (dayEvents.isNotEmpty)
          Text(
            '${dayEvents.length} Case',
            style: const TextStyle(
              color: AppColors.navInactive, // #727B86
              fontSize: 12,
              fontFamily: _toggleFont,
              fontWeight: FontWeight.w400,
              height: 1.33,
            ),
          ),

        const SizedBox(height: 12),

        if (dayEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildEmptyAgendaCard(
              _isToday(day) ? 'No Task For Today' : 'No Task For This Day',
            ),
          )
        else
          ...dayEvents.map(
            (event) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildAgendaCard(event),
            ),
          ),
      ],
    );
  }

  /// Same card style as an event card, shown only when the day has no events.
  Widget _buildEmptyAgendaCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary, // #0D294E
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 2,
              decoration: BoxDecoration(
                color: AppColors.calendarOutsideDay, // #F5F4F0
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.calendarOutsideDay, // #F5F4F0
                    fontSize: 15,
                    fontFamily: _toggleFont,
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                    letterSpacing: -0.23,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaCard(CalendarEvent event) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary, // #0D294E
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(
              width: 2,
              decoration: BoxDecoration(
                color: AppColors.calendarOutsideDay, // #F5F4F0
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.calendarOutsideDay, // #F5F4F0
                      fontSize: 15,
                      fontFamily: _toggleFont,
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                      letterSpacing: -0.23,
                    ),
                  ),
                  if (event.subtitle.isNotEmpty)
                    Text(
                      event.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.navInactive, // #727B86
                        fontSize: 12,
                        fontFamily: _toggleFont,
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Week view
  // ---------------------------------------------------------------------------

  Widget _buildWeekView() {
    // Week starts on Sunday, same as the month view.
    final referenceDate = _selectedDate ?? _focusedDate;

    final sunday = referenceDate.subtract(
      Duration(days: referenceDate.weekday % 7),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(7, (index) {
          final date = sunday.add(Duration(days: index));
          final events = _eventsForDay(date);

          final isSelected = _isSelected(date);
          final isToday = _isToday(date);

          return GestureDetector(
            onTap: () => _selectDate(date),
            child: Container(
              width: 122,
              height: 260,
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.calendarBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(color: AppColors.primary, width: 1.3)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontFamily: _bodyFont,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.calendarText,
                          ),
                        ),
                        Text(
                          _weekdays[date.weekday % 7],
                          style: TextStyle(
                            fontFamily: _bodyFont,
                            fontSize: 10,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.calendarMutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: events.isEmpty
                        ? const SizedBox.shrink()
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: events.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 6),
                            itemBuilder: (context, eventIndex) {
                              return _buildEventCard(
                                events[eventIndex],
                                isSelected,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event, bool selectedDay) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: selectedDay
            ? AppColors.primary
            : AppColors.calendarEventGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selectedDay
              ? AppColors.primary
              : AppColors.calendarEventGreen.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontFamily: _bodyFont,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: selectedDay
                  ? AppColors.white
                  : AppColors.calendarEventGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            event.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: _bodyFont,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selectedDay ? AppColors.white : AppColors.navActiveIcon,
            ),
          ),
          if (event.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              event.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: _bodyFont,
                fontSize: 9,
                color: selectedDay
                    ? AppColors.white.withValues(alpha: 0.7)
                    : AppColors.calendarMutedText,
              ),
            ),
          ],
          if (event.isHighPriority) ...[
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.calendarPriorityRed,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'HIGH',
                style: TextStyle(
                  fontFamily: _bodyFont,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}