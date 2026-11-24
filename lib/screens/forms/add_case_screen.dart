import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';

// --------------------------------------------------
// DATA
// --------------------------------------------------

/// What the form hands back when "Save Case" succeeds.
/// The screen pops with this object: `Navigator.pop(context, data)`.
/// Your backend dev can map it straight to an API request / DB row.
class CaseFormData {
  final String caseName;
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
  final DateTime? nextHearingDate;
  final TimeOfDay? nextHearingTime;
  final String description;
  final List<String> attachments; // file names of the checked PDFs

  const CaseFormData({
    required this.caseName,
    required this.caseNumber,
    required this.client,
    required this.status,
    required this.practiceArea,
    required this.court,
    required this.judge,
    required this.opposingParty,
    required this.opposingCounsel,
    required this.filingDate,
    required this.courtRoom,
    required this.nextHearingDate,
    required this.nextHearingTime,
    required this.description,
    required this.attachments,
  });

  /// Hearing date + time combined (midnight if no time was picked).
  DateTime? get nextHearing {
    final date = nextHearingDate;
    if (date == null) return null;
    final time = nextHearingTime ?? const TimeOfDay(hour: 0, minute: 0);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

class _AttachmentItem {
  final String name;
  bool selected;

  _AttachmentItem({required this.name, this.selected = false});
}

const List<String> _statusOptions = ['Active', 'Pending', 'On Hold', 'Closed'];

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

String _formatDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

// --------------------------------------------------
// SHARED STYLES
// --------------------------------------------------

const Color _errorColor = Color(0xFFC0392B);

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
  color: _errorColor,
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
      color: hasError ? _errorColor : AppColors.border,
    ),
  );
}

// --------------------------------------------------
// SCREEN
// --------------------------------------------------

class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});

  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  // Replace with real clients from your repository / provider later.
  static const List<String> _clients = [
    'Rafiq Rahman',
    'Nusrat Traders Ltd',
    'Sabina Akter',
  ];

  // Text controllers
  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _practiceCtrl = TextEditingController();
  final _courtCtrl = TextEditingController();
  final _judgeCtrl = TextEditingController();
  final _opposingPartyCtrl = TextEditingController();
  final _opposingCounselCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // Keys used to scroll to the first field with an error.
  final _nameKey = GlobalKey();
  final _numberKey = GlobalKey();
  final _clientKey = GlobalKey();
  final _hearingKey = GlobalKey();

  // Selections
  String? _client;
  String _status = _statusOptions.first; // "Active" by default
  DateTime? _filingDate;
  DateTime? _hearingDate;
  TimeOfDay? _hearingTime;

  // Replace with the user's existing PDFs from your repository later.
  final List<_AttachmentItem> _attachments = [
    _AttachmentItem(name: 'Plaint_Rahman_v_Karim.pdf'),
    _AttachmentItem(name: 'Title_Deed_Plot42.pdf'),
    _AttachmentItem(name: 'Supply_Agreement.pdf'),
  ];
  int _uploadCount = 0;

  // Validation errors (null = no error)
  String? _nameError;
  String? _numberError;
  String? _clientError;
  String? _hearingError;

  // Form state
  bool _isDirty = false;
  bool _isSaving = false;

  @override
  void dispose() {
    for (final controller in [
      _nameCtrl,
      _numberCtrl,
      _practiceCtrl,
      _courtCtrl,
      _judgeCtrl,
      _opposingPartyCtrl,
      _opposingCounselCtrl,
      _roomCtrl,
      _descriptionCtrl,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  // ------------------------------------------------
  // State helpers
  // ------------------------------------------------

  void _onTextChanged() {
    final needsRebuild =
        !_isDirty || _nameError != null || _numberError != null;
    if (!needsRebuild) return;

    setState(() {
      _isDirty = true;
      if (_nameCtrl.text.trim().isNotEmpty) _nameError = null;
      if (_numberCtrl.text.trim().isNotEmpty) _numberError = null;
    });
  }

  // ------------------------------------------------
  // Pickers
  // ------------------------------------------------

  Widget _pickerTheme(BuildContext context, Widget? child) {
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

  Future<void> _pickClient() async {
    FocusScope.of(context).unfocus();
    final value = await _showOptionSheet(
      title: 'Select client',
      options: _clients,
      selected: _client,
    );
    if (!mounted || value == null) return;

    setState(() {
      _client = value;
      _clientError = null;
      _isDirty = true;
    });
  }

  Future<void> _pickStatus() async {
    FocusScope.of(context).unfocus();
    final value = await _showOptionSheet(
      title: 'Status',
      options: _statusOptions,
      selected: _status,
    );
    if (!mounted || value == null) return;

    setState(() {
      _status = value;
      _isDirty = true;
    });
  }

  Future<void> _pickFilingDate() async {
    FocusScope.of(context).unfocus();
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _filingDate ?? today,
      firstDate: DateTime(today.year - 30),
      lastDate: today,
      builder: _pickerTheme,
    );
    if (!mounted || picked == null) return;

    setState(() {
      _filingDate = picked;
      _isDirty = true;
    });
  }

  Future<void> _pickHearingDate() async {
    FocusScope.of(context).unfocus();
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _hearingDate ?? today,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 10),
      builder: _pickerTheme,
    );
    if (!mounted || picked == null) return;

    setState(() {
      _hearingDate = picked;
      _hearingError = null;
      _isDirty = true;
    });
  }

  Future<void> _pickHearingTime() async {
    FocusScope.of(context).unfocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: _hearingTime ?? const TimeOfDay(hour: 10, minute: 0),
      builder: _pickerTheme,
    );
    if (!mounted || picked == null) return;

    setState(() {
      _hearingTime = picked;
      _isDirty = true;
    });
  }

  Future<String?> _showOptionSheet({
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
      builder: (context) => _OptionSheet(
        title: title,
        options: options,
        selected: selected,
      ),
    );
  }

  // ------------------------------------------------
  // Attachments
  // ------------------------------------------------

  void _toggleAttachment(int index) {
    setState(() {
      _attachments[index].selected = !_attachments[index].selected;
      _isDirty = true;
    });
  }

  Future<void> _uploadPdf() async {
    FocusScope.of(context).unfocus();

    // TODO: open a real file picker (e.g. the file_picker package):
    //
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['pdf'],
    // );
    // final name = result?.files.single.name;
    // if (name == null) return; // user cancelled
    //
    // Placeholder so the UI state works until the picker is wired up:
    _uploadCount++;
    final name = 'Uploaded_Document_$_uploadCount.pdf';

    if (!mounted) return;
    setState(() {
      _attachments.add(_AttachmentItem(name: name, selected: true));
      _isDirty = true;
    });
  }

  // ------------------------------------------------
  // Validation + save
  // ------------------------------------------------

  bool _validate() {
    final nameError =
        _nameCtrl.text.trim().isEmpty ? 'Enter a case name' : null;
    final numberError = _numberCtrl.text.trim().isEmpty
        ? 'Enter a case number or reference'
        : null;
    final clientError = _client == null ? 'Select a client' : null;
    final hearingError = (_hearingTime != null && _hearingDate == null)
        ? 'Pick a date for this time'
        : null;

    setState(() {
      _nameError = nameError;
      _numberError = numberError;
      _clientError = clientError;
      _hearingError = hearingError;
    });

    final GlobalKey? firstInvalid = nameError != null
        ? _nameKey
        : numberError != null
            ? _numberKey
            : clientError != null
                ? _clientKey
                : hearingError != null
                    ? _hearingKey
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

  CaseFormData _buildFormData() {
    return CaseFormData(
      caseName: _nameCtrl.text.trim(),
      caseNumber: _numberCtrl.text.trim(),
      client: _client!,
      status: _status,
      practiceArea: _practiceCtrl.text.trim(),
      court: _courtCtrl.text.trim(),
      judge: _judgeCtrl.text.trim(),
      opposingParty: _opposingPartyCtrl.text.trim(),
      opposingCounsel: _opposingCounselCtrl.text.trim(),
      filingDate: _filingDate,
      courtRoom: _roomCtrl.text.trim(),
      nextHearingDate: _hearingDate,
      nextHearingTime: _hearingTime,
      description: _descriptionCtrl.text.trim(),
      attachments: [
        for (final item in _attachments)
          if (item.selected) item.name,
      ],
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    setState(() => _isSaving = true);
    final data = _buildFormData();

    try {
      // TODO (backend): send `data` to the API / repository, e.g.
      // await caseRepository.createCase(data);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the case. Try again.')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(data);
  }

  // ------------------------------------------------
  // Back / discard handling
  // ------------------------------------------------

  Future<void> _handleBack() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();
    if (!_isDirty) {
      Navigator.of(context).pop();
      return;
    }

    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Discard changes?'),
        content: const Text('Your changes to this case will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Keep editing',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Discard',
              style: TextStyle(color: _errorColor),
            ),
          ),
        ],
      ),
    );

    if (!mounted || discard != true) return;
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
              _AddCaseHeader(onBack: _handleBack),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      _FormField(
                        key: _nameKey,
                        label: 'Case name *',
                        errorText: _nameError,
                        child: _TextInput(
                          controller: _nameCtrl,
                          hasError: _nameError != null,
                          onChanged: (_) => _onTextChanged(),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      _FormField(
                        key: _numberKey,
                        label: 'Case number / reference *',
                        errorText: _numberError,
                        child: _TextInput(
                          controller: _numberCtrl,
                          hasError: _numberError != null,
                          onChanged: (_) => _onTextChanged(),
                        ),
                      ),
                      _FormField(
                        key: _clientKey,
                        label: 'Client *',
                        errorText: _clientError,
                        child: _SelectField(
                          text: _client,
                          placeholder: 'Select client',
                          hasError: _clientError != null,
                          onTap: _pickClient,
                        ),
                      ),
                      _FormField(
                        label: 'Status',
                        child: _SelectField(
                          text: _status,
                          placeholder: 'Select status',
                          onTap: _pickStatus,
                        ),
                      ),
                      _FormField(
                        label: 'Practice area',
                        child: _TextInput(
                          controller: _practiceCtrl,
                          onChanged: (_) => _onTextChanged(),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      _FormField(
                        label: 'Court / jurisdiction',
                        child: _TextInput(
                          controller: _courtCtrl,
                          onChanged: (_) => _onTextChanged(),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      _FormField(
                        label: 'Judge',
                        child: _TextInput(
                          controller: _judgeCtrl,
                          onChanged: (_) => _onTextChanged(),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      _FormField(
                        label: 'Opposing party',
                        child: _TextInput(
                          controller: _opposingPartyCtrl,
                          onChanged: (_) => _onTextChanged(),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      _FormField(
                        label: 'Opposing counsel',
                        child: _TextInput(
                          controller: _opposingCounselCtrl,
                          onChanged: (_) => _onTextChanged(),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      _FormField(
                        label: 'Filing date',
                        child: _SelectField(
                          text: _filingDate == null
                              ? null
                              : _formatDate(_filingDate!),
                          placeholder: 'Select date',
                          trailingIcon: Icons.calendar_today_rounded,
                          onTap: _pickFilingDate,
                        ),
                      ),
                      _FormField(
                        label: 'Court location / room',
                        child: _TextInput(
                          controller: _roomCtrl,
                          onChanged: (_) => _onTextChanged(),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Expanded(
                            child: _FormField(
                              key: _hearingKey,
                              label: 'Next hearing',
                              errorText: _hearingError,
                              child: _SelectField(
                                text: _hearingDate == null
                                    ? null
                                    : _formatDate(_hearingDate!),
                                placeholder: 'Select date',
                                hasError: _hearingError != null,
                                trailingIcon: Icons.calendar_today_rounded,
                                onTap: _pickHearingDate,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _FormField(
                              label: 'Time',
                              child: _SelectField(
                                text: _hearingTime?.format(context),
                                placeholder: 'Select time',
                                trailingIcon: Icons.access_time_rounded,
                                onTap: _pickHearingTime,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _FormField(
                        label: 'Description',
                        child: _TextInput(
                          controller: _descriptionCtrl,
                          onChanged: (_) => _onTextChanged(),
                          multiline: true,
                        ),
                      ),
                      _AttachmentsSection(
                        items: _attachments,
                        onToggle: _toggleAttachment,
                        onUpload: _uploadPdf,
                      ),
                    ],
                  ),
                ),
              ),
              _SaveBar(isSaving: _isSaving, onSave: _save),
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

class _AddCaseHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _AddCaseHeader({required this.onBack});

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
          const Expanded(
            child: Text(
              'Add Case',
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
// FORM FIELDS
// --------------------------------------------------

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  final String? errorText;

  const _FormField({
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

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool hasError;
  final bool multiline;
  final TextCapitalization textCapitalization;

  const _TextInput({
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
class _SelectField extends StatelessWidget {
  final String? text;
  final String placeholder;
  final VoidCallback onTap;
  final bool hasError;
  final IconData trailingIcon;

  const _SelectField({
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
// OPTION BOTTOM SHEET (client / status)
// --------------------------------------------------

class _OptionSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;

  const _OptionSheet({
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
// ATTACHMENTS
// --------------------------------------------------

class _AttachmentsSection extends StatelessWidget {
  final List<_AttachmentItem> items;
  final ValueChanged<int> onToggle;
  final VoidCallback onUpload;

  const _AttachmentsSection({
    required this.items,
    required this.onToggle,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4, bottom: 4),
          child: Text('Attachments', style: _labelStyle),
        ),
        for (var i = 0; i < items.length; i++)
          _AttachmentRow(item: items[i], onTap: () => onToggle(i)),
        const SizedBox(height: 4),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onUpload,
          child: Container(
            width: double.infinity,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 1, color: AppColors.border),
            ),
            child: const Text(
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
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Only file names are stored in this prototype.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
              height: 1.50,
              letterSpacing: 0.06,
            ),
          ),
        ),
      ],
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  final _AttachmentItem item;
  final VoidCallback onTap;

  const _AttachmentRow({required this.item, required this.onTap});

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
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item.selected ? AppColors.textNavy : null,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  width: 1,
                  color: item.selected
                      ? AppColors.textNavy
                      : AppColors.textMuted,
                ),
              ),
              child: item.selected
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
                item.name,
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

// --------------------------------------------------
// SAVE BAR
// --------------------------------------------------

class _SaveBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;

  const _SaveBar({required this.isSaving, required this.onSave});

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
          text: isSaving ? 'Saving...' : 'Save Case',
          onPressed: onSave, // _save ignores taps while already saving
          height: 44,
          borderRadius: 8,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}