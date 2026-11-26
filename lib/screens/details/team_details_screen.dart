import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../edit/edit_team_screen.dart';
import '../forms/add_team_screen.dart';

class _Payment {
  final DateTime date;
  final String amount;

  const _Payment(this.date, this.amount);
}

class TeamDetailsScreen extends StatefulWidget {
  const TeamDetailsScreen({super.key, required this.member, this.onChanged});

  final TeamFormData member;

  /// Called when the member changes (edit or payment) so the list can refresh.
  final ValueChanged<TeamFormData>? onChanged;

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  // TODO: replace with your real tasks. Tasks and payment history below are
  // only kept while this page is open until you connect real storage.
  static const _allTasks = [
    'Collect exhibits',
    'Draft legal notice',
    'Prepare witness statement',
    'File written statement',
  ];

  late TeamFormData _member = widget.member;
  final List<String> _tasks = [];
  final List<_Payment> _payments = [];

  void _update(TeamFormData updated) {
    setState(() => _member = updated);
    widget.onChanged?.call(updated);
  }

  Future<void> _edit() async {
    final result = await Navigator.of(context).push<TeamFormData>(
      MaterialPageRoute(builder: (_) => EditTeamScreen(member: _member)),
    );
    if (!mounted || result == null) return;
    _update(result);
  }

  void _recordPayment() {
    setState(() => _payments.insert(0, _Payment(DateTime.now(), _member.amount)));
    _update(_member.copyWith(status: 'Paid'));
  }

  @override
  Widget build(BuildContext context) {
    final hasAmount = (int.tryParse(_member.amount) ?? 0) > 0;
    final available = _allTasks.where((t) => !_tasks.contains(t)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textNavy,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(bottom: BorderSide(width: 1, color: AppColors.border)),
        titleTextStyle: const TextStyle(
          color: AppColors.textNavy,
          fontSize: 17,
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w600,
          letterSpacing: -0.43,
        ),
        title: Text(_member.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: _edit,
            icon: const Icon(Icons.edit_outlined, size: 22),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile ──
              const _SectionTitle('Profile'),
              Container(
                width: double.infinity,
                decoration: _cardDecoration,
                child: Column(
                  children: [
                    _InfoRow(Icons.work_outline_rounded, _member.role),
                    const Divider(height: 1, color: AppColors.border),
                    _InfoRow(Icons.phone_outlined, _member.phone),
                    if (_member.email.isNotEmpty) ...[
                      const Divider(height: 1, color: AppColors.border),
                      _InfoRow(Icons.mail_outline_rounded, _member.email),
                    ],
                  ],
                ),
              ),

              // ── Payment ──
              const SizedBox(height: 20),
              const _SectionTitle('Payment'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: _cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${_taka(_member.amount)} / ${_member.frequency}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 16,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                              letterSpacing: -0.31,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _member.status,
                          style: TextStyle(
                            color: _member.statusColor,
                            fontSize: 16,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                            letterSpacing: -0.31,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      text: 'Record payment',
                      width: double.infinity,
                      height: 48,
                      borderRadius: 8,
                      onPressed: hasAmount ? _recordPayment : null,
                    ),
                    if (!hasAmount)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Add a payment amount (Edit) to record payments.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontFamily: 'SF Pro',
                            height: 1.33,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Assigned tasks ──
              const SizedBox(height: 20),
              _SectionTitle('Assigned tasks (${_tasks.length})'),
              for (final task in _tasks)
                Container(
                  width: double.infinity,
                  height: 44,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  decoration: _fieldDecoration,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          task,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _fieldTextStyle,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _tasks.remove(task)),
                        child: const SizedBox(
                          width: 32,
                          height: 32,
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
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: _fieldDecoration,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(8),
                    dropdownColor: AppColors.surface,
                    style: _fieldTextStyle,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    hint: const Text(
                      'Assign a task…',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 15,
                        fontFamily: 'SF Pro',
                        letterSpacing: -0.23,
                      ),
                    ),
                    items: [
                      for (final t in available)
                        DropdownMenuItem(value: t, child: Text(t)),
                    ],
                    onChanged: available.isEmpty
                        ? null
                        : (t) {
                            if (t != null) setState(() => _tasks.add(t));
                          },
                  ),
                ),
              ),

              // ── Payment history ──
              const SizedBox(height: 20),
              const _SectionTitle('Payment history'),
              if (_payments.isEmpty)
                const Text(
                  'No payments recorded yet.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontFamily: 'SF Pro',
                    height: 1.43,
                    letterSpacing: -0.15,
                  ),
                )
              else
                for (int i = 0; i < _payments.length; i++)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: i == _payments.length - 1
                          ? null
                          : const Border(
                              bottom: BorderSide(width: 1, color: AppColors.border),
                            ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDate(_payments[i].date), style: _rowTextStyle),
                        Text(_taka(_payments[i].amount), style: _rowTextStyle),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// SMALL PARTS
// --------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textNavy,
          fontSize: 14,
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w600,
          height: 1.43,
          letterSpacing: -0.15,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: _rowTextStyle)),
        ],
      ),
    );
  }
}

final BoxDecoration _cardDecoration = BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(width: 1, color: AppColors.border),
);

final BoxDecoration _fieldDecoration = BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(width: 1, color: AppColors.border),
);

const TextStyle _fieldTextStyle = TextStyle(
  color: AppColors.textDark,
  fontSize: 15,
  fontFamily: 'SF Pro',
  fontWeight: FontWeight.w400,
  letterSpacing: -0.23,
);

const TextStyle _rowTextStyle = TextStyle(
  color: AppColors.textDark,
  fontSize: 14,
  fontFamily: 'SF Pro',
  fontWeight: FontWeight.w400,
  height: 1.43,
  letterSpacing: -0.15,
);

/// "30000" -> "৳30,000"
String _taka(String digits) {
  final value = digits.isEmpty ? '0' : digits;
  final grouped = value.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '৳$grouped';
}

String _formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]}';
}