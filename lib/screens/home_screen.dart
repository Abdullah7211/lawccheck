
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../widgets/app_bottom_nav.dart';

import '../widgets/app_calendar.dart';
import '../widgets/quick_actions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F4F0),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            AppBottomNav.contentBottomSpace(context),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeader(),
              SizedBox(height: 10),
              _NextHearingCard(),
              SizedBox(height: 10),
              _WeeklyWorkload(),
              SizedBox(height: 16),
              AppCalendar(),
              SizedBox(height: 16),
              QuickActions(),
              SizedBox(height: 16),
              _RecentActivity(),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// HEADER
// --------------------------------------------------

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF0D294E),
              shape: BoxShape.circle,
            ),
            child: const Text(
              'S',
              style: TextStyle(
                color: Color(0xFFF5F4F0),
                fontSize: 14,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                height: 1.43,
                letterSpacing: -0.15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good afternoon',
                  style: TextStyle(
                    color: Color(0xFF727B86),
                    fontSize: 12,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
                Text(
                  'Sakib',
                  style: TextStyle(
                    color: Color(0xFF0D294E),
                    fontSize: 19,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.20,
                  ),
                ),
              ],
            ),
          ),
          const _HeaderIcon(icon: Icons.notifications_none_rounded),
          const _HeaderIcon(icon: Icons.search_rounded),
          const _HeaderIcon(icon: Icons.more_horiz_rounded),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;

  const _HeaderIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Icon(
        icon,
        size: 22,
        color: const Color(0xFF0D294E),
      ),
    );
  }
}

// --------------------------------------------------
// NEXT HEARING CARD
// --------------------------------------------------

class _NextHearingCard extends StatefulWidget {
  const _NextHearingCard();

  @override
  State<_NextHearingCard> createState() => _NextHearingCardState();
}

class _NextHearingCardState extends State<_NextHearingCard> {
  late DateTime _currentDateTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Get the phone's current local date and time.
    _currentDateTime = DateTime.now();

    // Refresh the displayed time every second.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _currentDateTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    // Stop the timer when this widget is removed.
    _timer?.cancel();
    super.dispose();
  }

  // Format current time as HH:mm.
  String get _currentTime {
    final hour = _currentDateTime.hour % 12 == 0
        ? 12
        : _currentDateTime.hour % 12;

    final minute = _currentDateTime.minute.toString().padLeft(2, '0');

    final period = _currentDateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // Format current date as Wednesday, 28 October.
  String get _currentDate {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
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

    return '${weekdays[_currentDateTime.weekday - 1]}, '
        '${_currentDateTime.day} '
        '${months[_currentDateTime.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 206,
      padding: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF0D294E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // BACKGROUND IMAGE
          Positioned(
            right: -35,
            bottom: -95,
            width: 340,
            height: 340,
            child: Image.asset(
              'assets/image/back.png',
              fit: BoxFit.contain,
            ),
          ),

          // CARD TEXT CONTENT
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading and countdown
              Row(
                children: [
                  const Text(
                    'NEXT HEARING',
                    style: TextStyle(
                      color: Color(0xFFF5F4F0),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.33,
                      letterSpacing: 1.20,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F4F0),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'in 1h 40m',
                      style: TextStyle(
                        color: Color(0xFF202B38),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 1.33,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 7),

              // CURRENT PHONE TIME
              Text(
                _currentTime,
                style: const TextStyle(
                  color: Color(0xFFF5F4F0),
                  fontSize: 72,
                  fontFamily: 'Fraunces',
                  fontWeight: FontWeight.w600,
                  height: 0.85,
                ),
              ),

              const SizedBox(height: 3),

              // CURRENT PHONE DATE
              Text(
                _currentDate,
                style: const TextStyle(
                  color: Color(0xFFF5F4F0),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),

              const Spacer(),

              // Case title
              const Text(
                'Commercial Contract Matter',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFFF5F4F0),
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.40,
                ),
              ),

              const SizedBox(height: 4),

              // Case number and room
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'CS-2024/077 · Nusrat Traders Ltd',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFFF5F4F0),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Room 11',
                    style: TextStyle(
                      color: Color(0xFFF5F4F0),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// WEEKLY WORKLOAD
// --------------------------------------------------

class _WeeklyWorkload extends StatelessWidget {
  const _WeeklyWorkload();

  static const List<double> _barHeights = [
    33,
    22,
    44,
    11,
    55,
    4.39,
    22,
  ];

  static const List<String> _days = [
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 136,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Workload this week',
                style: TextStyle(
                  color: Color(0xFF0D294E),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
              Text(
                '20 items',
                style: TextStyle(
                  color: Color(0xFF0D294E),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final bool isToday = index == 3;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: _barHeights[index],
                        decoration: BoxDecoration(
                          color: isToday
                              ? const Color(0xFF0D294E)
                              : const Color(0xFFC8C8C8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _days[index],
                        style: const TextStyle(
                          color: Color(0xFF0D294E),
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// RECENT ACTIVITY
// --------------------------------------------------

class _ActivityItem {
  final String name;
  final String action;
  final String meta;

  const _ActivityItem({
    required this.name,
    required this.action,
    required this.meta,
  });
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  static const List<_ActivityItem> _items = [
    _ActivityItem(
      name: 'Nadia',
      action: 'uploaded Witness_Statement.pdf',
      meta: 'CS-2024/077 · 12m ago',
    ),
    _ActivityItem(
      name: 'Imran',
      action: 'completed "Collect exhibits"',
      meta: 'CS-2023/310 · 1h ago',
    ),
    _ActivityItem(
      name: 'Nusrat Traders',
      action: 'paid invoice #1042',
      meta: 'Billing · 3h ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent activity',
            style: TextStyle(
              color: Color(0xFF0D294E),
              fontSize: 19,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.20,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 20),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(width: 1, color: Color(0xFFF5F4F0)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_items.length, (index) {
                return _ActivityRow(
                  item: _items[index],
                  isFirst: index == 0,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final _ActivityItem item;
  final bool isFirst;

  const _ActivityRow({required this.item, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    final double topPadding = isFirst ? 0 : 16;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: item.name,
                        style: const TextStyle(
                          color: Color(0xFF0D294E),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.43,
                        ),
                      ),
                      const TextSpan(
                        text: ' ',
                        style: TextStyle(
                          color: Color(0xFF0D294E),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                      TextSpan(
                        text: item.action,
                        style: const TextStyle(
                          color: Color(0xFF202B38),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  item.meta,
                  style: const TextStyle(
                    color: Color(0xFF202B38),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Timeline dot (10px fill + 4px navy ring)
        Positioned(
          left: -26,
          top: topPadding + 6,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F4F0),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF0D294E),
                  blurRadius: 0,
                  offset: Offset(0, 0),
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}