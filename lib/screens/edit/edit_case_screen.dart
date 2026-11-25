import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../forms/add_case_expense_screen.dart' show formatShortDate;

// --------------------------------------------------
// DATA
// --------------------------------------------------

const List<String> kCaseStatuses = ['Active', 'Pending', 'On Hold', 'Closed'];

class CaseEditData {
  final String name;
  final String caseNumber;
  final String client;
  final String status;
  final String practiceArea;
  final String court;
  final String judge;
  final String opposingParty;
  final String opposingCounsel;
  final DateTime? filingDate;
  final String courtRoom;
  final DateTime? nextHearing;
  final TimeOfDay? hearingTime;
  final String description;

  /// File names of the attached documents.
  final List<String> attachments;

  const CaseEditData({
    required this.name,
    required this.caseNumber,
    required this.client,
    required this.status,
    this.practiceArea = '',
    this.court = '',
    this.judge = '',
    this.opposingParty = '',
    this.opposingCounsel = '',
    this.filingDate,
    this.courtRoom = '',
    this.nextHearing,
    this.hearingTime,
    this.description = '',
    this.attachments = const [],
  });
}

// --------------------------------------------------
// SCREEN
// --------------------------------------------------

class EditCaseScreen extends StatefulWidget {
  final CaseEditData initial;

  /// Clients the user can pick from.
  final List<String> clients;

  /// Every file that can be ticked under "Attachments".
  final List<String> availableAttachments;

  /// Called when "Upload PDF" is tapped. Return the picked file name, or null
  /// if the user cancelled.
  /// TODO: wire this to the `file_picker` package.
  final Future<String?> Function()? onUploadPdf;

  const EditCaseScreen({
    super.key,
    required this.initial,
    this.clients = const [
      'Rafiq Rahman',
      'Nusrat Traders Ltd',
      'Sabina Akter',
    ],
    this.availableAttachments = const [],
    this.onUploadPdf,
  });

  @override
  State<EditCaseScreen> createState() => _EditCaseScreenState();
}

class _EditCaseScreenState extends State<EditCaseScreen> {
  late final TextEditingController _name;
  late final TextEditingController _caseNumber;
  late final TextEditingController _practiceArea;
  late final TextEditingController _court;
  late final TextEditingController _judge;
  late final TextEditingController _opposingParty;
  late final TextEditingController _opposingCounsel;
  late final TextEditingController _courtRoom;
  late final TextEditingController _description;

  late String _client;
  late String _status;
  DateTime? _filingDate;
  DateTime? _nextHearing;
  TimeOfDay? _hearingTime;

  late final List<String> _allAttachments;
  late final Set<String> _selectedAttachments;

  bool _nameError = false;
  bool _numberError = false;
  bool _clientError = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initial;

    _name = TextEditingController(text: d.name);
    _caseNumber = TextEditingController(text: d.caseNumber);
    _practiceArea = TextEditingController(text: d.practiceArea);
    _court = TextEditingController(text: d.court);
    _judge = TextEditingController(text: d.judge);
    _opposingParty = TextEditingController(text: d.opposingParty);
    _opposingCounsel = TextEditingController(text: d.opposingCounsel);
    _courtRoom = TextEditingController(text: d.courtRoom);
    _description = TextEditingController(text: d.description);

    _client = d.client;
    _status = kCaseStatuses.contains(d.status) ? d.status : kCaseStatuses.first;
    _filingDate = d.filingDate;
    _nextHearing = d.nextHearing;
    _hearingTime = d.hearingTime;

    _selectedAttachments = {...d.attachments};
    _allAttachments = [
      ...widget.availableAttachments,
      for (final a in d.attachments)
        if (!widget.availableAttachments.contains(a)) a,
    ];
  }

  @override
  void dispose() {
    _name.dispose();
    _caseNumber.dispose();
    _practiceArea.dispose();
    _court.dispose();
    _judge.dispose();
    _opposingParty.dispose();
    _opposingCounsel.dispose();
    _courtRoom.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDate(DateTime? current) {
    FocusScope.of(context).unfocus();
    return showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  Future<void> _pickClient() async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<String>(
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
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Select client',
                style: TextStyle(
                  color: AppColors.textNavy,
                  fontSize: 17,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.43,
                ),
              ),
            ),
            for (final c in widget.clients)
              ListTile(
                title: Text(c, style: _inputStyle),
                trailing: c == _client
                    ? const Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: AppColors.textNavy,
                      )
                    : null,
                onTap: () => Navigator.of(ctx).pop(c),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        _client = picked;
        _clientError = false;
      });
    }
  }

  Future<void> _uploadPdf() async {
    final pick = widget.onUploadPdf;
    if (pick == null) return;
    final name = await pick();
    if (!mounted || name == null || name.isEmpty) return;
    setState(() {
      if (!_allAttachments.contains(name)) _allAttachments.add(name);
      _selectedAttachments.add(name);
    });
  }

  void _save() {
    final name = _name.text.trim();
    final number = _caseNumber.text.trim();

    setState(() {
      _nameError = name.isEmpty;
      _numberError = number.isEmpty;
      _clientError = _client.trim().isEmpty;
    });
    if (_nameError || _numberError || _clientError) return;

    Navigator.of(context).pop(
      CaseEditData(
        name: name,
        caseNumber: number,
        client: _client,
        status: _status,
        practiceArea: _practiceArea.text.trim(),
        court: _court.text.trim(),
        judge: _judge.text.trim(),
        opposingParty: _opposingParty.text.trim(),
        opposingCounsel: _opposingCounsel.text.trim(),
        filingDate: _filingDate,
        courtRoom: _courtRoom.text.trim(),
        nextHearing: _nextHearing,
        hearingTime: _hearingTime,
        description: _description.text.trim(),
        // Keep the original ordering of the list.
        attachments: [
          for (final a in _allAttachments)
            if (_selectedAttachments.contains(a)) a,
        ],
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
            _EditHeader(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Field(
                      label: 'Case name *',
                      error: _nameError ? 'Case name is required' : null,
                      child: _TextBox(
                        controller: _name,
                        hasError: _nameError,
                        capitalization: TextCapitalization.words,
                        onChanged: (_) {
                          if (_nameError) setState(() => _nameError = false);
                        },
                      ),
                    ),
                    _Field(
                      label: 'Case number / reference *',
                      error: _numberError ? 'Case number is required' : null,
                      child: _TextBox(
                        controller: _caseNumber,
                        hasError: _numberError,
                        onChanged: (_) {
                          if (_numberError) {
                            setState(() => _numberError = false);
                          }
                        },
                      ),
                    ),
                    _Field(
                      label: 'Client *',
                      error: _clientError ? 'Select a client' : null,
                      child: _TapBox(
                        text: _client,
                        hint: 'Select client',
                        hasError: _clientError,
                        onTap: _pickClient,
                      ),
                    ),
                    _Field(
                      label: 'Status',
                      child: _DropdownBox(
                        value: _status,
                        items: kCaseStatuses,
                        onChanged: (v) => setState(() => _status = v),
                      ),
                    ),
                    _Field(
                      label: 'Practice area',
                      child: _TextBox(
                        controller: _practiceArea,
                        capitalization: TextCapitalization.words,
                      ),
                    ),
                    _Field(
                      label: 'Court / jurisdiction',
                      child: _TextBox(
                        controller: _court,
                        capitalization: TextCapitalization.words,
                      ),
                    ),
                    _Field(
                      label: 'Judge',
                      child: _TextBox(
                        controller: _judge,
                        capitalization: TextCapitalization.words,
                      ),
                    ),
                    _Field(
                      label: 'Opposing party',
                      child: _TextBox(
                        controller: _opposingParty,
                        capitalization: TextCapitalization.words,
                      ),
                    ),
                    _Field(
                      label: 'Opposing counsel',
                      child: _TextBox(
                        controller: _opposingCounsel,
                        capitalization: TextCapitalization.words,
                      ),
                    ),
                    _Field(
                      label: 'Filing date',
                      child: _TapBox(
                        text: _filingDate == null
                            ? null
                            : formatShortDate(_filingDate!),
                        hint: 'Select date',
                        onTap: () async {
                          final d = await _pickDate(_filingDate);
                          if (d != null) setState(() => _filingDate = d);
                        },
                      ),
                    ),
                    _Field(
                      label: 'Court location / room',
                      child: _TextBox(controller: _courtRoom),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _Field(
                            label: 'Next hearing',
                            child: _TapBox(
                              text: _nextHearing == null
                                  ? null
                                  : formatShortDate(_nextHearing!),
                              hint: 'Select date',
                              onTap: () async {
                                final d = await _pickDate(_nextHearing);
                                if (d != null) setState(() => _nextHearing = d);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _Field(
                            label: 'Time',
                            child: _TapBox(
                              text: _hearingTime?.format(context),
                              hint: 'Select time',
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                final t = await showTimePicker(
                                  context: context,
                                  initialTime:
                                      _hearingTime ?? TimeOfDay.now(),
                                );
                                if (t != null) setState(() => _hearingTime = t);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    _Field(
                      label: 'Description',
                      child: _TextBox(
                        controller: _description,
                        height: 80,
                        maxLines: 3,
                        capitalization: TextCapitalization.sentences,
                      ),
                    ),
                    const _Label('Attachments'),
                    for (final file in _allAttachments)
                      _AttachmentRow(
                        name: file,
                        selected: _selectedAttachments.contains(file),
                        onTap: () => setState(() {
                          if (!_selectedAttachments.remove(file)) {
                            _selectedAttachments.add(file);
                          }
                        }),
                      ),
                    const SizedBox(height: 4),
                    _UploadButton(onTap: _uploadPdf),
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Only file names are stored in this prototype.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          letterSpacing: 0.06,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pinned save bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(width: 1, color: AppColors.border),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Save Case',
                  onPressed: _save,
                  height: 48,
                  borderRadius: 8,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
// STYLES
// --------------------------------------------------

const Color _errorColor = Color(0xFFB3261E);

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

BoxDecoration _boxDecoration({bool hasError = false}) {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      width: 1,
      color: hasError ? _errorColor : AppColors.border,
    ),
  );
}

// --------------------------------------------------
// HEADER
// --------------------------------------------------

class _EditHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _EditHeader({required this.onBack});

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
              width: 26,
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 24,
                  color: AppColors.textNavy,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Edit Case',
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
        ],
      ),
    );
  }
}

// --------------------------------------------------
// FORM PIECES
// --------------------------------------------------

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w500,
          height: 1.33,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  final String? error;

  const _Field({required this.label, required this.child, this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(label),
          child,
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                error!,
                style: const TextStyle(
                  color: _errorColor,
                  fontSize: 12,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TextBox extends StatelessWidget {
  final TextEditingController controller;
  final bool hasError;
  final double height;
  final int maxLines;
  final TextCapitalization capitalization;
  final ValueChanged<String>? onChanged;

  const _TextBox({
    required this.controller,
    this.hasError = false,
    this.height = 44,
    this.maxLines = 1,
    this.capitalization = TextCapitalization.none,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final multiline = maxLines > 1;
    return Container(
      height: height,
      width: double.infinity,
      alignment: multiline ? Alignment.topLeft : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: multiline ? 8 : 0),
      decoration: _boxDecoration(hasError: hasError),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        textCapitalization: capitalization,
        cursorColor: AppColors.textNavy,
        style: _inputStyle,
        decoration: const InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

/// A box that looks like a field but opens a picker when tapped.
class _TapBox extends StatelessWidget {
  final String? text;
  final String hint;
  final bool hasError;
  final VoidCallback onTap;

  const _TapBox({
    required this.text,
    required this.hint,
    required this.onTap,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final empty = text == null || text!.isEmpty;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: _boxDecoration(hasError: hasError),
        child: Text(
          empty ? hint : text!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: empty ? _hintStyle : _inputStyle,
        ),
      ),
    );
  }
}

class _DropdownBox extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownBox({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _boxDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: _inputStyle,
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AppColors.textDark,
          ),
          items: [
            for (final item in items)
              DropdownMenuItem<String>(value: item, child: Text(item)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _AttachmentRow({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: selected ? AppColors.textNavy : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  width: 1,
                  color: selected ? AppColors.textNavy : AppColors.textMuted,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: AppColors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  letterSpacing: -0.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashed-border "Upload PDF" button.
class _UploadButton extends StatelessWidget {
  final VoidCallback onTap;
  const _UploadButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: CustomPaint(
        painter: const _DashedBorderPainter(
          color: AppColors.border,
          radius: 8,
        ),
        child: const SizedBox(
          height: 44,
          width: double.infinity,
          child: Center(
            child: Text(
              'Upload PDF',
              style: TextStyle(
                color: AppColors.textNavy,
                fontSize: 14,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                height: 1.43,
                letterSpacing: -0.15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );

    const dash = 4.0;
    const gap = 3.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}