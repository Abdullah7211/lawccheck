import 'package:material_ui/material_ui.dart';

import '../edit/edit_case_screen.dart';
import '../forms/add_case_expense_screen.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';

// --------------------------------------------------
// SHARED STYLES
// --------------------------------------------------

const Color _dangerColor = Color(0xFFB3261E);

TextStyle _text(
  double size,
  Color color, {
  FontWeight weight = FontWeight.w400,
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
}) {
  return TextStyle(
    color: color,
    fontSize: size,
    fontFamily: 'SF Pro',
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
  );
}

Color _statusColorFor(String label) {
  switch (label) {
    case 'Active':
      return AppColors.statusActive;
    case 'Pending':
      return AppColors.statusPending;
    default:
      return AppColors.statusInactive;
  }
}

String _orDash(String value) => value.trim().isEmpty ? '—' : value;

// --------------------------------------------------
// MODALS  (confirm dialog + action sheet + edit note sheet)
// --------------------------------------------------

enum _ItemAction { edit, remove }

/// "Remove …?" confirmation dialog. Returns true if the user confirmed.
Future<bool> _confirmRemove(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        title,
        style: _text(
          17,
          AppColors.textNavy,
          weight: FontWeight.w600,
          letterSpacing: -0.43,
        ),
      ),
      content: Text(
        message,
        style: _text(14, AppColors.textDark, height: 1.43, letterSpacing: -0.15),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('Cancel', style: _text(14, AppColors.textMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            'Remove',
            style: _text(14, _dangerColor, weight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Bottom sheet with "Edit" and "Remove" rows.
Future<_ItemAction?> _showItemActions(
  BuildContext context, {
  required String title,
  required String editLabel,
  required String removeLabel,
}) {
  Widget row(BuildContext ctx, IconData icon, String label, Color color,
      _ItemAction action) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(ctx).pop(action),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(label, style: _text(15, color, letterSpacing: -0.23)),
          ],
        ),
      ),
    );
  }

  return showModalBottomSheet<_ItemAction>(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _text(
                17,
                AppColors.textNavy,
                weight: FontWeight.w600,
                letterSpacing: -0.43,
              ),
            ),
          ),
          row(ctx, Icons.edit_outlined, editLabel, AppColors.textDark,
              _ItemAction.edit),
          row(ctx, Icons.delete_outline_rounded, removeLabel, _dangerColor,
              _ItemAction.remove),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Bottom sheet for editing a note. Returns the new text, or null if cancelled.
Future<String?> _showEditNoteSheet(BuildContext context, String initial) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _EditNoteSheet(initial: initial),
    ),
  );
}

class _EditNoteSheet extends StatefulWidget {
  final String initial;
  const _EditNoteSheet({required this.initial});

  @override
  State<_EditNoteSheet> createState() => _EditNoteSheetState();
}

class _EditNoteSheetState extends State<_EditNoteSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit note',
              style: _text(
                17,
                AppColors.textNavy,
                weight: FontWeight.w600,
                letterSpacing: -0.43,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: AppColors.border),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                minLines: 2,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                cursorColor: AppColors.textNavy,
                style: _text(15, AppColors.textDark, letterSpacing: -0.23),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 1, color: AppColors.border),
                      ),
                      child: Text(
                        'Cancel',
                        style: _text(14, AppColors.textNavy, letterSpacing: -0.15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    text: 'Save',
                    onPressed: _save,
                    height: 44,
                    borderRadius: 8,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// DATA
// --------------------------------------------------

enum _CaseTab {
  overview('Overview'),
  hearings('Hearings'),
  documents('Documents'),
  expenses('Expenses'),
  notes('Notes');

  const _CaseTab(this.label);
  final String label;
}

class _Hearing {
  final String label;
  final bool isPast;
  const _Hearing(this.label, {required this.isPast});
}

class _CaseDocument {
  final String name;
  final String dateLabel;
  const _CaseDocument(this.name, this.dateLabel);
}

// --------------------------------------------------
// SCREEN
// --------------------------------------------------

class CaseDetailsScreen extends StatefulWidget {
  final String title;
  final String caseNumber;
  final String client;
  final String statusLabel;
  final Color statusColor;

  const CaseDetailsScreen({
    super.key,
    required this.title,
    required this.caseNumber,
    required this.client,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  State<CaseDetailsScreen> createState() => _CaseDetailsScreenState();
}

class _CaseDetailsScreenState extends State<CaseDetailsScreen> {
  _CaseTab _tab = _CaseTab.overview;

  // 1 = moving to a tab on the right, -1 = moving to a tab on the left.
  int _slideDirection = 1;

  // Case fields (editable through EditCaseScreen).
  late String _title;
  late String _caseNumber;
  late String _client;
  late String _statusLabel;
  late Color _statusColor;

  // Replace all of this with real data from your repository / provider later.
  String _clientContact = '+880 1711 000111 · rafiq@mail.com';
  String _practiceArea = 'Civil';
  String _court = 'District Court, Dhaka';
  String _judge = 'Hon. A. Chowdhury';
  String _opposingParty = 'Imran Karim';
  String _opposingCounsel = '';
  DateTime? _filingDate;
  String _courtRoom = 'Court 4';
  DateTime? _nextHearing;
  TimeOfDay? _hearingTime;
  String _description = 'Recovery suit over unpaid contractor dues.';

  static const List<String> _documentLibrary = [
    'Plaint_Rahman_v_Karim.pdf',
    'Title_Deed_Plot42.pdf',
    'Supply_Agreement.pdf',
    'Power_of_Attorney.pdf',
  ];

  final List<_Hearing> _hearings = const [
    _Hearing('8 Oct, 10:00 · Court 4', isPast: true),
    _Hearing('28 Oct, 10:30 · Court 4', isPast: false),
    _Hearing('9 Nov, 11:00 · Court 4', isPast: false),
  ];

  final List<_CaseDocument> _documents = [
    const _CaseDocument('Plaint_Rahman_v_Karim.pdf', '28 Sept'),
  ];

  final List<CaseExpense> _expenses = [
    CaseExpense(
      title: 'Court filing fee',
      amount: 2500,
      date: DateTime(DateTime.now().year, 10, 25),
      category: 'Court fees',
      type: 'Personal',
    ),
  ];

  final List<String> _notes = ['sewer', 'Client to bring original invoices.'];

  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _caseNumber = widget.caseNumber;
    _client = widget.client;
    _statusLabel = widget.statusLabel;
    _statusColor = widget.statusColor;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  double get _expenseTotal =>
      _expenses.fold<double>(0, (sum, e) => sum + e.amount);

  // ---- Tabs ----

  void _selectTab(_CaseTab tab) {
    if (tab == _tab) return;
    setState(() {
      _slideDirection = tab.index > _tab.index ? 1 : -1;
      _tab = tab;
    });
  }

  // ---- Case ----

  Future<void> _editCase() async {
    final result = await Navigator.of(context).push<CaseEditData>(
      MaterialPageRoute(
        builder: (_) => EditCaseScreen(
          initial: CaseEditData(
            name: _title,
            caseNumber: _caseNumber,
            client: _client,
            status: _statusLabel,
            practiceArea: _practiceArea,
            court: _court,
            judge: _judge,
            opposingParty: _opposingParty,
            opposingCounsel: _opposingCounsel,
            filingDate: _filingDate,
            courtRoom: _courtRoom,
            nextHearing: _nextHearing,
            hearingTime: _hearingTime,
            description: _description,
            attachments: [for (final d in _documents) d.name],
          ),
          clients: {
            'Rafiq Rahman',
            'Nusrat Traders Ltd',
            'Sabina Akter',
            _client,
          }.toList(),
          availableAttachments: {
            ..._documentLibrary,
            for (final d in _documents) d.name,
          }.toList(),
        ),
      ),
    );
    if (!mounted || result == null) return;

    setState(() {
      _title = result.name;
      _caseNumber = result.caseNumber;
      _client = result.client;
      _statusLabel = result.status;
      _statusColor = _statusColorFor(result.status);
      _practiceArea = result.practiceArea;
      _court = result.court;
      _judge = result.judge;
      _opposingParty = result.opposingParty;
      _opposingCounsel = result.opposingCounsel;
      _filingDate = result.filingDate;
      _courtRoom = result.courtRoom;
      _nextHearing = result.nextHearing;
      _hearingTime = result.hearingTime;
      _description = result.description;

      // Keep existing document dates, give new ones today's date.
      final existing = {for (final d in _documents) d.name: d};
      final today = formatShortDate(DateTime.now());
      final synced = [
        for (final name in result.attachments)
          existing[name] ?? _CaseDocument(name, today),
      ];
      _documents
        ..clear()
        ..addAll(synced);
    });
    // TODO: save the updated case to your repository / provider.
  }

  // ---- Documents ----

  void _attachDocument(String name) {
    setState(() {
      _documents.add(_CaseDocument(name, formatShortDate(DateTime.now())));
    });
  }

  Future<void> _removeDocument(int index) async {
    final doc = _documents[index];
    final ok = await _confirmRemove(
      context,
      title: 'Remove document?',
      message: '“${doc.name}” will be removed from this case.',
    );
    if (!mounted || !ok) return;
    setState(() => _documents.removeAt(index));
  }

  // ---- Expenses ----

  Future<void> _addExpense() async {
    final result = await Navigator.of(context).push<CaseExpense>(
      MaterialPageRoute(builder: (_) => const AddCaseExpenseScreen()),
    );
    if (!mounted || result == null) return;
    setState(() => _expenses.add(result));
  }

  Future<void> _expenseActions(int index) async {
    final expense = _expenses[index];
    final action = await _showItemActions(
      context,
      title: expense.title,
      editLabel: 'Edit expense',
      removeLabel: 'Remove expense',
    );
    if (!mounted || action == null) return;

    if (action == _ItemAction.edit) {
      final result = await Navigator.of(context).push<CaseExpense>(
        MaterialPageRoute(
          builder: (_) => AddCaseExpenseScreen(initial: expense),
        ),
      );
      if (!mounted || result == null) return;
      setState(() => _expenses[index] = result);
    } else {
      final ok = await _confirmRemove(
        context,
        title: 'Remove expense?',
        message:
            '“${expense.title}” (${formatTaka(expense.amount)}) will be removed from this case.',
      );
      if (!mounted || !ok) return;
      setState(() => _expenses.removeAt(index));
    }
  }

  // ---- Notes ----

  void _addNote() {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;
    setState(() {
      _notes.add(note);
      _noteController.clear();
    });
  }

  Future<void> _noteActions(int index) async {
    final note = _notes[index];
    final action = await _showItemActions(
      context,
      title: 'Note',
      editLabel: 'Edit note',
      removeLabel: 'Remove note',
    );
    if (!mounted || action == null) return;

    if (action == _ItemAction.edit) {
      final updated = await _showEditNoteSheet(context, note);
      if (!mounted || updated == null) return;
      setState(() => _notes[index] = updated);
    } else {
      final ok = await _confirmRemove(
        context,
        title: 'Remove note?',
        message: 'This note will be removed from the case.',
      );
      if (!mounted || !ok) return;
      setState(() => _notes.removeAt(index));
    }
  }

  // ---- PDF ----

  void _openPdfPreview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CasePdfPreviewScreen(
          title: _title,
          caseNumber: _caseNumber,
          statusLabel: _statusLabel,
          client: _client,
          clientContact: _clientContact,
          court: _court,
          judge: _judge,
          opposingParty: _opposingParty,
          hearings: [for (final h in _hearings) h.label],
          notes: List<String>.of(_notes),
          documents: [for (final d in _documents) d.name],
          expenses: List<CaseExpense>.of(_expenses),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _DetailsHeader(
              onBack: () => Navigator.of(context).maybePop(),
              onEdit: _editCase,
              onPdf: _openPdfPreview,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CaseSummary(
                    title: _title,
                    caseNumber: _caseNumber,
                    client: _client,
                    statusLabel: _statusLabel,
                    statusColor: _statusColor,
                    onClientTap: () {
                      // TODO: open the client details screen.
                    },
                  ),
                  _TabsBar(selected: _tab, onSelected: _selectTab),
                  Expanded(
                    child: ClipRect(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        layoutBuilder: (current, previous) => Stack(
                          fit: StackFit.expand,
                          children: [...previous, if (current != null) current],
                        ),
                        transitionBuilder: (child, animation) {
                          final isIncoming = child.key == ValueKey(_tab);
                          final dir = _slideDirection.toDouble();
                          // Incoming slides in from the side we are moving
                          // towards; outgoing slides out the opposite way.
                          final begin = Offset(isIncoming ? dir : -dir, 0);
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: begin,
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                        child: SingleChildScrollView(
                          key: ValueKey(_tab),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          child: _buildTab(),
                        ),
                      ),
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

  Widget _buildTab() {
    switch (_tab) {
      case _CaseTab.overview:
        return _OverviewTab(
          fields: [
            _OverviewField('Court', _orDash(_court)),
            _OverviewField('Judge', _orDash(_judge)),
            _OverviewField('Opposing party', _orDash(_opposingParty)),
            _OverviewField('Opposing counsel', _orDash(_opposingCounsel)),
            _OverviewField(
              'Filing date',
              _filingDate == null ? '—' : formatShortDate(_filingDate!),
            ),
            _OverviewField('Practice area', _orDash(_practiceArea)),
            _OverviewField('Description', _orDash(_description)),
            const _OverviewField(
              'Task · In Progress',
              'Draft written statement',
              accent: true,
            ),
          ],
        );
      case _CaseTab.hearings:
        return _HearingsTab(hearings: _hearings);
      case _CaseTab.documents:
        return _DocumentsTab(
          documents: _documents,
          available: [
            for (final name in _documentLibrary)
              if (!_documents.any((d) => d.name == name)) name,
          ],
          onAttach: _attachDocument,
          onRemove: _removeDocument,
        );
      case _CaseTab.expenses:
        return _ExpensesTab(
          expenses: _expenses,
          total: _expenseTotal,
          onAdd: _addExpense,
          onMore: _expenseActions,
        );
      case _CaseTab.notes:
        return _NotesTab(
          notes: _notes,
          controller: _noteController,
          onAdd: _addNote,
          onMore: _noteActions,
        );
    }
  }
}

// --------------------------------------------------
// HEADER + SUMMARY + TABS
// --------------------------------------------------

class _DetailsHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onPdf;

  const _DetailsHeader({
    required this.onBack,
    required this.onEdit,
    required this.onPdf,
  });

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
          _HeaderIconButton(
            icon: Icons.chevron_left_rounded,
            size: 24,
            width: 26,
            alignment: Alignment.centerLeft,
            onTap: onBack,
          ),
          Expanded(
            child: Text(
              'Case',
              style: _text(
                17,
                AppColors.textNavy,
                weight: FontWeight.w600,
                height: 1.5,
                letterSpacing: -0.43,
              ),
            ),
          ),
          _HeaderIconButton(icon: Icons.edit_outlined, onTap: onEdit),
          _HeaderIconButton(icon: Icons.description_outlined, onTap: onPdf),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double width;
  final Alignment alignment;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.size = 20,
    this.width = 44,
    this.alignment = Alignment.centerRight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: 44,
        child: Align(
          alignment: alignment,
          child: Icon(icon, size: size, color: AppColors.textNavy),
        ),
      ),
    );
  }
}

class _CaseSummary extends StatelessWidget {
  final String title;
  final String caseNumber;
  final String client;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onClientTap;

  const _CaseSummary({
    required this.title,
    required this.caseNumber,
    required this.client,
    required this.statusLabel,
    required this.statusColor,
    required this.onClientTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _text(
              20,
              AppColors.textNavy,
              weight: FontWeight.w600,
              height: 1.4,
              letterSpacing: -0.45,
            ),
          ),
          Text(
            caseNumber,
            style: _text(
              14,
              AppColors.textMuted,
              height: 1.43,
              letterSpacing: -0.15,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusLabel,
                  style: _text(
                    14,
                    AppColors.textDark,
                    height: 1.43,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '·',
                  style: _text(
                    14,
                    AppColors.textMuted,
                    height: 1.43,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onClientTap,
                    child: Text(
                      client,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _text(
                        14,
                        AppColors.textNavy,
                        height: 1.43,
                        letterSpacing: -0.15,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabsBar extends StatelessWidget {
  final _CaseTab selected;
  final ValueChanged<_CaseTab> onSelected;

  const _TabsBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (final tab in _CaseTab.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(tab),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 2,
                        color: tab == selected
                            ? AppColors.textNavy
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Text(
                    tab.label,
                    maxLines: 1,
                    style: _text(
                      12,
                      tab == selected
                          ? AppColors.textNavy
                          : AppColors.textMuted,
                      weight: FontWeight.w500,
                      height: 1.33,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// SHARED CARD + LIST
// --------------------------------------------------

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: AppColors.border),
      ),
      child: child,
    );
  }
}

/// Small tappable icon used at the end of a card (more / remove).
class _CardIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CardIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Icon(icon, size: 20, color: AppColors.textMuted),
      ),
    );
  }
}

/// Stacks widgets with an 8px gap.
class _Stack extends StatelessWidget {
  final List<Widget> children;
  const _Stack({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          children[i],
        ],
      ],
    );
  }
}

// --------------------------------------------------
// TAB: OVERVIEW
// --------------------------------------------------

class _OverviewField {
  final String label;
  final String value;
  final bool accent;
  const _OverviewField(this.label, this.value, {this.accent = false});
}

class _OverviewTab extends StatelessWidget {
  final List<_OverviewField> fields;
  const _OverviewTab({required this.fields});

  @override
  Widget build(BuildContext context) {
    return _Stack(
      children: [
        for (final f in fields)
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.label,
                  style: _text(
                    12,
                    f.accent ? const Color(0xFFB77924) : AppColors.textMuted,
                    height: 1.33,
                  ),
                ),
                Text(
                  f.value,
                  style: _text(
                    14,
                    AppColors.textDark,
                    height: 1.43,
                    letterSpacing: -0.15,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// --------------------------------------------------
// TAB: HEARINGS
// --------------------------------------------------

class _HearingsTab extends StatelessWidget {
  final List<_Hearing> hearings;
  const _HearingsTab({required this.hearings});

  @override
  Widget build(BuildContext context) {
    return _Stack(
      children: [
        for (final h in hearings)
          _InfoCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    h.label,
                    style: _text(
                      14,
                      AppColors.textDark,
                      height: 1.43,
                      letterSpacing: -0.15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  h.isPast ? 'Past' : 'Upcoming',
                  style: _text(12, AppColors.textMuted, height: 1.33),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// --------------------------------------------------
// TAB: DOCUMENTS
// --------------------------------------------------

class _DocumentsTab extends StatelessWidget {
  final List<_CaseDocument> documents;
  final List<String> available;
  final ValueChanged<String> onAttach;
  final ValueChanged<int> onRemove;

  const _DocumentsTab({
    required this.documents,
    required this.available,
    required this.onAttach,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return _Stack(
      children: [
        for (var i = 0; i < documents.length; i++)
          _InfoCard(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      // TODO: open the document.
                    },
                    child: Text(
                      documents[i].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _text(
                        14,
                        AppColors.textDark,
                        height: 1.43,
                        letterSpacing: -0.15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  documents[i].dateLabel,
                  style: _text(12, AppColors.textMuted, height: 1.33),
                ),
                _CardIconButton(
                  icon: Icons.close_rounded,
                  onTap: () => onRemove(i),
                ),
              ],
            ),
          ),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1, color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: null,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              hint: Text(
                'Attach existing document…',
                style: _text(15, AppColors.textDark, letterSpacing: -0.23),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.textDark,
              ),
              style: _text(15, AppColors.textDark, letterSpacing: -0.23),
              items: [
                for (final name in available)
                  DropdownMenuItem<String>(value: name, child: Text(name)),
              ],
              onChanged: available.isEmpty
                  ? null
                  : (v) {
                      if (v != null) onAttach(v);
                    },
            ),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------
// TAB: EXPENSES
// --------------------------------------------------

class _ExpensesTab extends StatelessWidget {
  final List<CaseExpense> expenses;
  final double total;
  final VoidCallback onAdd;
  final ValueChanged<int> onMore;

  const _ExpensesTab({
    required this.expenses,
    required this.total,
    required this.onAdd,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${formatTaka(total)} total',
                style: _text(
                  14,
                  AppColors.textDark,
                  weight: FontWeight.w600,
                  height: 1.43,
                  letterSpacing: -0.15,
                ),
              ),
            ),
            AppButton(
              text: 'Add Expenses',
              onPressed: onAdd,
              height: 44,
              borderRadius: 8,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _Stack(
          children: [
            for (var i = 0; i < expenses.length; i++)
              _InfoCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expenses[i].title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _text(
                              14,
                              AppColors.textDark,
                              height: 1.43,
                              letterSpacing: -0.15,
                            ),
                          ),
                          Text(
                            '${formatShortDate(expenses[i].date)} · ${expenses[i].category}',
                            style: _text(12, AppColors.textMuted, height: 1.33),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatTaka(expenses[i].amount),
                      style: _text(
                        14,
                        AppColors.textDark,
                        weight: FontWeight.w700,
                        height: 1.43,
                        letterSpacing: -0.15,
                      ),
                    ),
                    _CardIconButton(
                      icon: Icons.more_horiz_rounded,
                      onTap: () => onMore(i),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// --------------------------------------------------
// TAB: NOTES
// --------------------------------------------------

class _NotesTab extends StatelessWidget {
  final List<String> notes;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final ValueChanged<int> onMore;

  const _NotesTab({
    required this.notes,
    required this.controller,
    required this.onAdd,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 1, color: AppColors.border),
                ),
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onAdd(),
                  cursorColor: AppColors.textNavy,
                  style: _text(15, AppColors.textDark, letterSpacing: -0.23),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Add a note',
                    hintStyle: _text(
                      15,
                      AppColors.textHint,
                      letterSpacing: -0.23,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AppButton(
              text: 'Add',
              onPressed: onAdd,
              height: 44,
              borderRadius: 8,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _Stack(
          children: [
            for (var i = 0; i < notes.length; i++)
              _InfoCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        notes[i],
                        style: _text(
                          14,
                          AppColors.textDark,
                          height: 1.43,
                          letterSpacing: -0.15,
                        ),
                      ),
                    ),
                    _CardIconButton(
                      icon: Icons.more_horiz_rounded,
                      onTap: () => onMore(i),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// --------------------------------------------------
// SCREEN  (PDF preview)
// --------------------------------------------------

class CasePdfPreviewScreen extends StatelessWidget {
  final String title;
  final String caseNumber;
  final String statusLabel;
  final String client;
  final String clientContact;
  final String court;
  final String judge;
  final String opposingParty;
  final List<String> hearings;
  final List<String> notes;
  final List<String> documents;
  final List<CaseExpense> expenses;

  const CasePdfPreviewScreen({
    super.key,
    required this.title,
    required this.caseNumber,
    required this.statusLabel,
    required this.client,
    required this.clientContact,
    required this.court,
    required this.judge,
    required this.opposingParty,
    required this.hearings,
    required this.notes,
    required this.documents,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
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
                  _HeaderIconButton(
                    icon: Icons.chevron_left_rounded,
                    size: 24,
                    width: 26,
                    alignment: Alignment.centerLeft,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      'Case PDF preview',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _text(
                        17,
                        AppColors.textNavy,
                        weight: FontWeight.w600,
                        height: 1.5,
                        letterSpacing: -0.43,
                      ),
                    ),
                  ),
                  AppButton(
                    text: 'Print / Save PDF',
                    onPressed: () {
                      // TODO: generate the PDF (e.g. with the `pdf` + `printing`
                      // packages) and open the print / share sheet.
                    },
                    height: 36,
                    borderRadius: 8,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Container(
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
                        style: _text(
                          18,
                          AppColors.textDark,
                          weight: FontWeight.w600,
                          height: 1.56,
                          letterSpacing: -0.44,
                        ),
                      ),
                      Text(
                        '$caseNumber · $statusLabel',
                        style: _text(12, AppColors.textMuted, height: 1.63),
                      ),
                      _PdfSection(title: 'Client', lines: [client, clientContact]),
                      _PdfSection(
                        title: 'Court',
                        lines: [
                          court,
                          'Judge: $judge · Opposing: $opposingParty',
                        ],
                      ),
                      _PdfSection(title: 'Hearings', lines: hearings),
                      const _PdfSection(title: 'Deadlines', lines: []),
                      _PdfSection(
                        title: 'Notes',
                        lines: [for (final n in notes) '• $n'],
                      ),
                      _PdfSection(title: 'Documents', lines: documents),
                      _PdfSection(
                        title: 'Expenses',
                        lines: [
                          for (final e in expenses)
                            '${formatShortDate(e.date)} · ${e.title} · ${formatTaka(e.amount)}',
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfSection extends StatelessWidget {
  final String title;
  final List<String> lines;

  const _PdfSection({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    final body = lines.isEmpty ? const ['—'] : lines;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1, color: Color(0x4D202B38)),
              ),
            ),
            child: Text(
              title.toUpperCase(),
              style: _text(
                11,
                AppColors.textDark,
                weight: FontWeight.w600,
                height: 1.63,
                letterSpacing: 0.34,
              ),
            ),
          ),
          for (final line in body)
            Text(line, style: _text(12, AppColors.textDark, height: 1.63)),
        ],
      ),
    );
  }
}