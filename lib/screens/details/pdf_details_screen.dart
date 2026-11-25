import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../widgets/pdf_actions.dart';

class PdfDetailsScreen extends StatefulWidget {
  final String fileName;
  final String date;
  final List<String> linkedCases;
  final List<String> availableCases;
  final List<String> otherFileNames;

  final ValueChanged<String> onRenamed;
  final ValueChanged<List<String>> onLinkedCasesChanged;
  final VoidCallback onRemoved;

  const PdfDetailsScreen({
    super.key,
    required this.fileName,
    required this.date,
    required this.linkedCases,
    required this.availableCases,
    required this.otherFileNames,
    required this.onRenamed,
    required this.onLinkedCasesChanged,
    required this.onRemoved,
  });

  @override
  State<PdfDetailsScreen> createState() => _PdfDetailsScreenState();
}

class _PdfDetailsScreenState extends State<PdfDetailsScreen> {
  late String _fileName = widget.fileName;
  late List<String> _linkedCases = List<String>.of(widget.linkedCases);

  // ------------------------------------------------
  // ACTIONS
  // ------------------------------------------------

  Future<void> _rename() async {
    final newName = await showRenamePdfDialog(
      context,
      currentName: _fileName,
      otherFileNames: widget.otherFileNames,
    );

    if (newName == null || newName == _fileName || !mounted) return;

    setState(() => _fileName = newName);
    widget.onRenamed(newName);
  }

  Future<void> _openLinkSheet() async {
    final result = await showLinkCasesSheet(
      context,
      availableCases: widget.availableCases,
      selected: _linkedCases,
    );

    if (result != null) _setCases(result);
  }

  void _toggleCase(String name) {
    final next = {..._linkedCases};
    if (!next.remove(name)) next.add(name);

    _setCases(widget.availableCases.where(next.contains).toList());
  }

  void _setCases(List<String> cases) {
    if (!mounted) return;
    setState(() => _linkedCases = cases);
    widget.onLinkedCasesChanged(cases);
  }

  Future<void> _remove() async {
    final confirmed = await showRemovePdfDialog(
      context,
      fileName: _fileName,
    );

    if (!confirmed || !mounted) return;

    widget.onRemoved();
    Navigator.of(context).pop();
  }

  void _download() {
    // TODO: Implement PDF download.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Downloading $_fileName…')));
  }

  void _onMenuAction(PdfMenuAction action) {
    switch (action) {
      case PdfMenuAction.open:
        break; // Already open.
      case PdfMenuAction.download:
        _download();
      case PdfMenuAction.rename:
        _rename();
      case PdfMenuAction.linkCases:
        _openLinkSheet();
      case PdfMenuAction.remove:
        _remove();
    }
  }

  // ------------------------------------------------
  // BUILD
  // ------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar: back, file name, 3-dot menu.
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: AppColors.textNavy,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    PdfActionsMenu(
                      fileName: _fileName,
                      subtitle: widget.date,
                      showOpen: false,
                      onSelected: _onMenuAction,
                    ),
                  ],
                ),
              ),

              // PDF view.
              Expanded(
                child: _PdfPreview(date: widget.date),
              ),

              // Linked cases.
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                child: _LinkedCases(
                  availableCases: widget.availableCases,
                  linkedCases: _linkedCases,
                  onToggle: _toggleCase,
                  onEdit: _openLinkSheet,
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
// PDF PREVIEW
// --------------------------------------------------

/// Placeholder page preview. To show the real PDF, replace the body of this
/// widget with a PDF viewer (e.g. `pdfx` or `syncfusion_flutter_pdfviewer`).
class _PdfPreview extends StatelessWidget {
  final String date;

  const _PdfPreview({required this.date});

  static const List<double> _lineWidths = [
    0.55, 0.90, 0.85, 0.80, 0.75, 1.00, 0.97, 0.94,
    0.90, 0.86, 0.82, 0.78, 0.74, 0.70, 0.66, 0.60,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(width: 1, color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SAMPLE PREVIEW · PAGE 1',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                height: 1.50,
                letterSpacing: 0.37,
              ),
            ),
            const SizedBox(height: 12),

            // Title bar.
            FractionallySizedBox(
              widthFactor: 0.6,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.textNavy.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Text lines.
            for (final factor in _lineWidths)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FractionallySizedBox(
                  widthFactor: factor,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
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

// --------------------------------------------------
// LINKED CASES
// --------------------------------------------------

class _LinkedCases extends StatelessWidget {
  final List<String> availableCases;
  final List<String> linkedCases;
  final ValueChanged<String> onToggle;
  final VoidCallback onEdit;

  const _LinkedCases({
    required this.availableCases,
    required this.linkedCases,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Linked cases',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w500,
                  height: 1.33,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onEdit,
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: AppColors.textNavy,
                  fontSize: 12,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w500,
                  height: 1.33,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final name in availableCases)
              _CaseChip(
                label: name,
                selected: linkedCases.contains(name),
                onTap: () => onToggle(name),
              ),
          ],
        ),
      ],
    );
  }
}

class _CaseChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CaseChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.textNavy : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            width: 1,
            color: selected ? AppColors.textNavy : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textMuted,
            fontSize: 12,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
            height: 1.33,
          ),
        ),
      ),
    );
  }
}