import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../forms/add_case_expense_screen.dart' show formatShortDate;
import '../edit/edit_client_screen.dart';
import '../forms/add_client_screen.dart' show ClientFormData;
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import 'case_details_screen.dart';

// --------------------------------------------------
// SHARED STYLES
// --------------------------------------------------

TextStyle _text(
  double size,
  Color color, {
  FontWeight weight = FontWeight.w400,
  double? height,
  double? letterSpacing,
}) {
  return TextStyle(
    color: color,
    fontSize: size,
    fontFamily: 'SF Pro',
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
  );
}

// --------------------------------------------------
// DATA
// --------------------------------------------------

const List<String> _logTypes = ['Call', 'Email', 'WhatsApp', 'Meeting', 'SMS'];

enum _CallMethod { phone, whatsapp }

class _ClientCase {
  final String title;
  final String caseNumber;
  final String statusLabel;
  final Color statusColor;

  const _ClientCase({
    required this.title,
    required this.caseNumber,
    required this.statusLabel,
    required this.statusColor,
  });
}

class _LogEntry {
  final String type;
  final String note;
  final DateTime date;

  const _LogEntry({
    required this.type,
    required this.note,
    required this.date,
  });
}

// --------------------------------------------------
// SCREEN
// --------------------------------------------------

class ClientDetailsScreen extends StatefulWidget {
  final String name;
  final String clientId;
  final String phone;

  const ClientDetailsScreen({
    super.key,
    required this.name,
    required this.clientId,
    required this.phone,
  });

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  late String _name;
  late String _phone;

  // Replace all of this with real data from your repository / provider later.
  String _email = 'rafiq@mail.com';
  String _clientType = 'Individual';
  String _whatsapp = '';
  String _address = '';
  String _preferredContact = 'Phone';
  String _notes = '';

  final List<_ClientCase> _cases = const [
    _ClientCase(
      title: 'Rahman vs Karim',
      caseNumber: 'CS-2024/118',
      statusLabel: 'Active',
      statusColor: AppColors.statusActive,
    ),
  ];

  final List<String> _documents = ['Plaint_Rahman_v_Karim.pdf'];

  final List<_LogEntry> _log = [];

  String _logType = _logTypes.first;
  final TextEditingController _logController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _phone = widget.phone;
  }

  @override
  void dispose() {
    _logController.dispose();
    super.dispose();
  }

  Future<void> _editClient() async {
    final result = await Navigator.of(context).push<ClientFormData>(
      MaterialPageRoute(
        builder: (_) => EditClientScreen(
          clientId: widget.clientId,
          initial: ClientFormData(
            name: _name,
            phone: _phone,
            email: _email,
            clientType: _clientType,
            whatsapp: _whatsapp,
            address: _address,
            preferredContact: _preferredContact,
            notes: _notes,
          ),
        ),
      ),
    );
    if (!mounted || result == null) return;

    setState(() {
      _name = result.name;
      _phone = result.phone;
      _email = result.email;
      _clientType = result.clientType;
      _whatsapp = result.whatsapp;
      _address = result.address;
      _preferredContact = result.preferredContact;
      _notes = result.notes;
    });
    // TODO: save the updated client to your repository / provider.
  }

  // ------------------------------------------------
  // Call / WhatsApp
  // ------------------------------------------------

  /// WhatsApp number if the client has one saved, otherwise the main phone.
  String get _whatsappNumber => _whatsapp.trim().isNotEmpty ? _whatsapp : _phone;

  Future<void> _showCallOptions() async {
    FocusScope.of(context).unfocus();

    if (_phone.trim().isEmpty && _whatsapp.trim().isEmpty) {
      _showMessage('No phone number saved for this client');
      return;
    }

    final method = await showModalBottomSheet<_CallMethod>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _CallSheet(phone: _phone, whatsapp: _whatsappNumber),
    );
    if (!mounted || method == null) return;

    switch (method) {
      case _CallMethod.phone:
        await _callPhone();
      case _CallMethod.whatsapp:
        await _openWhatsApp();
    }
  }

  Future<void> _callPhone() async {
    // Keep digits and a leading "+", drop spaces / dashes / brackets.
    final number = _phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (number.isEmpty) {
      _showMessage('No phone number saved for this client');
      return;
    }

    final opened = await _launch(Uri(scheme: 'tel', path: number));
    if (!mounted || opened) return;
    _showMessage('Could not start the call');
  }

  Future<void> _openWhatsApp() async {
    // wa.me wants digits only, with the country code and no "+".
    final number = _whatsappNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (number.isEmpty) {
      _showMessage('No WhatsApp number saved for this client');
      return;
    }

    final opened = await _launch(
      Uri.parse('https://wa.me/$number'),
      mode: LaunchMode.externalApplication,
    );
    if (!mounted || opened) return;
    _showMessage('Could not open WhatsApp');
  }

  Future<bool> _launch(
    Uri uri, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    try {
      return await launchUrl(uri, mode: mode);
    } catch (_) {
      return false;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ------------------------------------------------
  // Log + navigation
  // ------------------------------------------------

  void _addLog() {
    final note = _logController.text.trim();
    if (note.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _log.insert(0, _LogEntry(type: _logType, note: note, date: DateTime.now()));
      _logController.clear();
    });
  }

  void _openCase(_ClientCase c) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CaseDetailsScreen(
          title: c.title,
          caseNumber: c.caseNumber,
          client: _name,
          statusLabel: c.statusLabel,
          statusColor: c.statusColor,
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
            _Header(
              onBack: () => Navigator.of(context).maybePop(),
              onEdit: _editClient,
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary
                    Text(
                      _name,
                      style: _text(
                        20,
                        AppColors.textNavy,
                        weight: FontWeight.w600,
                        height: 1.4,
                        letterSpacing: -0.45,
                      ),
                    ),
                    Text(
                      '${widget.clientId} · $_clientType',
                      style: _text(
                        14,
                        AppColors.textMuted,
                        height: 1.43,
                        letterSpacing: -0.15,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _phone,
                            style: _text(
                              14,
                              AppColors.textDark,
                              height: 1.43,
                              letterSpacing: -0.15,
                            ),
                          ),
                          if (_email.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                _email,
                                style: _text(
                                  14,
                                  AppColors.textDark,
                                  height: 1.43,
                                  letterSpacing: -0.15,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Call button -> phone call or WhatsApp
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _CallButton(onTap: _showCallOptions),
                    ),

                    // Cases
                    _SectionTitle('Cases (${_cases.length})'),
                    for (var i = 0; i < _cases.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _CaseCard(
                        item: _cases[i],
                        onTap: () => _openCase(_cases[i]),
                      ),
                    ],

                    // Documents
                    _SectionTitle('Documents (${_documents.length})'),
                    for (var i = 0; i < _documents.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _DocumentCard(name: _documents[i]),
                    ],

                    // Communication log
                    const _SectionTitle('Communication log'),
                    _LogForm(
                      type: _logType,
                      controller: _logController,
                      onTypeChanged: (v) => setState(() => _logType = v),
                      onLog: _addLog,
                    ),
                    if (_log.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Center(
                          child: Text(
                            'No communication logged yet. Entries are added manually.',
                            textAlign: TextAlign.center,
                            style: _text(12, AppColors.textMuted, height: 1.33),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          children: [
                            for (var i = 0; i < _log.length; i++) ...[
                              if (i > 0) const SizedBox(height: 8),
                              _LogCard(entry: _log[i]),
                            ],
                          ],
                        ),
                      ),
                  ],
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

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEdit;

  const _Header({required this.onBack, required this.onEdit});

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
          Expanded(
            child: Text(
              'Client',
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
            text: 'Edit',
            onPressed: onEdit,
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
// CALL BUTTON + SHEET
// --------------------------------------------------

class _CallButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CallButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.textNavy,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.call_rounded, size: 18, color: AppColors.white),
            const SizedBox(width: 8),
            Text(
              'Call',
              style: _text(
                15,
                AppColors.white,
                weight: FontWeight.w600,
                height: 1.5,
                letterSpacing: -0.23,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallSheet extends StatelessWidget {
  final String phone;
  final String whatsapp;

  const _CallSheet({required this.phone, required this.whatsapp});

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
              'Contact client',
              style: _text(
                17,
                AppColors.textNavy,
                weight: FontWeight.w600,
                height: 1.5,
                letterSpacing: -0.43,
              ),
            ),
          ),
          _CallOption(
            icon: Icons.call_outlined,
            label: 'Phone call',
            subtitle: phone,
            onTap: () => Navigator.of(context).pop(_CallMethod.phone),
          ),
          _CallOption(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'WhatsApp',
            subtitle: whatsapp,
            onTap: () => Navigator.of(context).pop(_CallMethod.whatsapp),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CallOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _CallOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textNavy),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: _text(15, AppColors.textDark, letterSpacing: -0.23),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _text(12, AppColors.textMuted, height: 1.33),
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
// SECTIONS
// --------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: _text(
          14,
          AppColors.textNavy,
          weight: FontWeight.w600,
          height: 1.43,
          letterSpacing: -0.15,
        ),
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final _ClientCase item;
  final VoidCallback onTap;

  const _CaseCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1, color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _text(
                      16,
                      AppColors.textDark,
                      height: 1.5,
                      letterSpacing: -0.31,
                    ),
                  ),
                  Text(
                    item.caseNumber,
                    style: _text(12, AppColors.textMuted, height: 1.33),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final String name;
  const _DocumentCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // TODO: open the document.
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: AppColors.border),
        ),
        child: Text(
          name,
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
    );
  }
}

// --------------------------------------------------
// COMMUNICATION LOG
// --------------------------------------------------

class _LogForm extends StatelessWidget {
  final String type;
  final TextEditingController controller;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onLog;

  const _LogForm({
    required this.type,
    required this.controller,
    required this.onTypeChanged,
    required this.onLog,
  });

  BoxDecoration get _box => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: AppColors.border),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: _box,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: type,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    style: _text(14, AppColors.textDark, letterSpacing: -0.15),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.textDark,
                    ),
                    items: [
                      for (final t in _logTypes)
                        DropdownMenuItem<String>(value: t, child: Text(t)),
                    ],
                    onChanged: (v) {
                      if (v != null) onTypeChanged(v);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Container(
                height: 44,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: _box,
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => onLog(),
                  cursorColor: AppColors.textNavy,
                  style: _text(15, AppColors.textDark, letterSpacing: -0.23),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'What was discussed?',
                    hintStyle: _text(
                      15,
                      AppColors.textHint,
                      letterSpacing: -0.23,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            text: 'Log',
            onPressed: onLog,
            height: 44,
            borderRadius: 8,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }
}

class _LogCard extends StatelessWidget {
  final _LogEntry entry;
  const _LogCard({required this.entry});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${entry.type} · ${formatShortDate(entry.date)}',
            style: _text(12, AppColors.textMuted, height: 1.33),
          ),
          Text(
            entry.note,
            style: _text(
              14,
              AppColors.textDark,
              height: 1.43,
              letterSpacing: -0.15,
            ),
          ),
        ],
      ),
    );
  }
}