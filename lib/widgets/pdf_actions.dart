import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

const Color kPdfDanger = Color(0xFFD92D20);

// --------------------------------------------------
// 3-DOT MENU  (opens a Drive-style bottom sheet)
// --------------------------------------------------

enum PdfMenuAction { open, download, rename, linkCases, remove }

class PdfActionsMenu extends StatelessWidget {
  final String fileName;
  final String? subtitle;
  final ValueChanged<PdfMenuAction> onSelected;

  /// Hide "Open" when the menu is already shown inside the details screen.
  final bool showOpen;

  const PdfActionsMenu({
    super.key,
    required this.fileName,
    required this.onSelected,
    this.subtitle,
    this.showOpen = true,
  });

  Future<void> _openSheet(BuildContext context) async {
    final action = await showModalBottomSheet<PdfMenuAction>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _PdfActionsSheet(
        fileName: fileName,
        subtitle: subtitle,
        showOpen: showOpen,
      ),
    );

    // Run the action after the sheet has closed.
    if (action != null) onSelected(action);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'More options',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
      splashRadius: 18,
      icon: const Icon(
        Icons.more_vert_rounded,
        size: 22,
        color: AppColors.textMuted,
      ),
      onPressed: () => _openSheet(context),
    );
  }
}

class _PdfActionsSheet extends StatelessWidget {
  final String fileName;
  final String? subtitle;
  final bool showOpen;

  const _PdfActionsSheet({
    required this.fileName,
    required this.subtitle,
    required this.showOpen,
  });

  @override
  Widget build(BuildContext context) {
    void pick(PdfMenuAction a) => Navigator.of(context).pop(a);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // File header.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kPdfDanger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 22,
                    color: kPdfDanger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textNavy,
                          fontSize: 16,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.31,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontFamily: 'SF Pro',
                            height: 1.33,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.border),

          const SizedBox(height: 4),
          if (showOpen)
            _SheetRow(
              icon: Icons.open_in_new_rounded,
              label: 'Open',
              onTap: () => pick(PdfMenuAction.open),
            ),
          _SheetRow(
            icon: Icons.download_rounded,
            label: 'Download',
            onTap: () => pick(PdfMenuAction.download),
          ),
          _SheetRow(
            icon: Icons.link_rounded,
            label: 'Link cases',
            onTap: () => pick(PdfMenuAction.linkCases),
          ),
          _SheetRow(
            icon: Icons.edit_outlined,
            label: 'Rename',
            onTap: () => pick(PdfMenuAction.rename),
          ),
          Divider(height: 9, thickness: 1, color: AppColors.border),
          _SheetRow(
            icon: Icons.delete_outline_rounded,
            label: 'Remove',
            color: kPdfDanger,
            onTap: () => pick(PdfMenuAction.remove),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _SheetRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textDark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color ?? AppColors.textMuted),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                color: c,
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
// RENAME DIALOG
// --------------------------------------------------

/// Returns the new file name (always ending with .pdf) or null if cancelled.
Future<String?> showRenamePdfDialog(
  BuildContext context, {
  required String currentName,
  required List<String> otherFileNames,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _RenameDialog(
      currentName: currentName,
      otherFileNames: otherFileNames,
    ),
  );
}

class _RenameDialog extends StatefulWidget {
  final String currentName;
  final List<String> otherFileNames;

  const _RenameDialog({
    required this.currentName,
    required this.otherFileNames,
  });

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();

    final name = widget.currentName;
    final base = name.toLowerCase().endsWith('.pdf')
        ? name.substring(0, name.length - 4)
        : name;

    _controller = TextEditingController(text: base);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: base.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.trim();

    if (raw.isEmpty) {
      setState(() => _error = 'Enter a file name');
      return;
    }

    if (RegExp(r'[\\/:*?"<>|]').hasMatch(raw)) {
      setState(() => _error = 'Name contains invalid characters');
      return;
    }

    final name = raw.toLowerCase().endsWith('.pdf') ? raw : '$raw.pdf';

    final exists = widget.otherFileNames
        .any((n) => n.toLowerCase() == name.toLowerCase());

    if (exists) {
      setState(() => _error = 'A document with this name already exists');
      return;
    }

    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Rename document',
        style: TextStyle(
          color: AppColors.textNavy,
          fontSize: 17,
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w600,
          letterSpacing: -0.43,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        cursorColor: AppColors.textNavy,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 15,
          fontFamily: 'SF Pro',
        ),
        decoration: InputDecoration(
          errorText: _error,
          suffixText: '.pdf',
          hintText: 'File name',
          hintStyle: const TextStyle(color: AppColors.textHint),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.textNavy),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text(
            'Save',
            style: TextStyle(
              color: AppColors.textNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------
// REMOVE DIALOG
// --------------------------------------------------

Future<bool> showRemovePdfDialog(
  BuildContext context, {
  required String fileName,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Remove document?',
        style: TextStyle(
          color: AppColors.textNavy,
          fontSize: 17,
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w600,
          letterSpacing: -0.43,
        ),
      ),
      content: Text(
        '"$fileName" will be removed from your documents and unlinked '
        'from all cases.',
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
          fontFamily: 'SF Pro',
          height: 1.43,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            'Remove',
            style: TextStyle(
              color: kPdfDanger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  return result ?? false;
}

// --------------------------------------------------
// LINK CASES SHEET  (Drive-style list)
// --------------------------------------------------

/// Returns the new list of linked cases or null if dismissed.
Future<List<String>?> showLinkCasesSheet(
  BuildContext context, {
  required List<String> availableCases,
  required List<String> selected,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _LinkCasesSheet(
      availableCases: availableCases,
      selected: selected,
    ),
  );
}

class _LinkCasesSheet extends StatefulWidget {
  final List<String> availableCases;
  final List<String> selected;

  const _LinkCasesSheet({
    required this.availableCases,
    required this.selected,
  });

  @override
  State<_LinkCasesSheet> createState() => _LinkCasesSheetState();
}

class _LinkCasesSheetState extends State<_LinkCasesSheet> {
  late final Set<String> _selected = {...widget.selected};

  void _toggle(String name) {
    setState(() {
      if (!_selected.remove(name)) _selected.add(name);
    });
  }

  void _done() {
    // Keep the original case order.
    Navigator.of(context).pop(
      widget.availableCases.where(_selected.contains).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title + Done.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Link cases',
                      style: TextStyle(
                        color: AppColors.textNavy,
                        fontSize: 17,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.43,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _done,
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: AppColors.textNavy,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: AppColors.border),

            // Case rows.
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: widget.availableCases.length,
                itemBuilder: (_, index) {
                  final name = widget.availableCases[index];
                  final isOn = _selected.contains(name);

                  return InkWell(
                    onTap: () => _toggle(name),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.folder_outlined,
                            size: 22,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 15,
                                fontFamily: 'SF Pro',
                                letterSpacing: -0.23,
                              ),
                            ),
                          ),
                          Icon(
                            isOn
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            size: 24,
                            color: isOn
                                ? AppColors.textNavy
                                : AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}