import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/pdf_actions.dart';
import 'details/pdf_details_screen.dart';

// --------------------------------------------------
// DATA
// --------------------------------------------------

class _PdfItem {
  final int id;
  final String fileName;
  final String date;
  final List<String> cases;

  const _PdfItem({
    required this.id,
    required this.fileName,
    required this.date,
    required this.cases,
  });

  _PdfItem copyWith({String? fileName, List<String>? cases}) {
    return _PdfItem(
      id: id,
      fileName: fileName ?? this.fileName,
      date: date,
      cases: cases ?? this.cases,
    );
  }

  String get subtitle => cases.isEmpty ? date : '$date · ${cases.join(', ')}';
}

// --------------------------------------------------
// SCREEN
// --------------------------------------------------

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  // Demo data. Later, replace this with repository/provider data.
  final List<_PdfItem> _allPdfs = [
    const _PdfItem(
      id: 1,
      fileName: 'Plaint_Rahman_v_Karim.pdf',
      date: '28 Sept',
      cases: ['Rahman vs Karim'],
    ),
    const _PdfItem(
      id: 2,
      fileName: 'Title_Deed_Plot42.pdf',
      date: '13 Oct',
      cases: ['Property Ownership Dispute'],
    ),
    const _PdfItem(
      id: 3,
      fileName: 'Supply_Agreement.pdf',
      date: '19 Oct',
      cases: ['Commercial Contract Matter', 'Property Ownership Dispute'],
    ),
  ];

  // Available cases for linking documents.
  final List<String> _availableCases = [
    'Rahman vs Karim',
    'Property Ownership Dispute',
    'Commercial Contract Matter',
    'Akter Family Settlement',
  ];

  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------
  // SEARCH
  // ------------------------------------------------

  List<_PdfItem> get _filteredPdfs {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) return _allPdfs;

    return _allPdfs
        .where((item) => item.fileName.toLowerCase().contains(query))
        .toList();
  }

  // ------------------------------------------------
  // HELPERS (always look items up by id, so they keep
  // working after a rename / case change)
  // ------------------------------------------------

  List<String> _otherFileNames(int id) {
    return _allPdfs.where((p) => p.id != id).map((p) => p.fileName).toList();
  }

  void _applyRename(int id, String newName) {
    if (!mounted) return;
    final index = _allPdfs.indexWhere((p) => p.id == id);
    if (index == -1) return;

    setState(() {
      _allPdfs[index] = _allPdfs[index].copyWith(fileName: newName);
    });
  }

  void _applyCases(int id, List<String> cases) {
    if (!mounted) return;
    final index = _allPdfs.indexWhere((p) => p.id == id);
    if (index == -1) return;

    setState(() {
      _allPdfs[index] = _allPdfs[index].copyWith(cases: List<String>.of(cases));
    });
  }

  void _applyRemove(int id) {
    if (!mounted) return;
    setState(() => _allPdfs.removeWhere((p) => p.id == id));
  }

  void _showMessage(String text) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  // ------------------------------------------------
  // CARD ACTIONS
  // ------------------------------------------------

  Future<void> _rename(_PdfItem item) async {
    final newName = await showRenamePdfDialog(
      context,
      currentName: item.fileName,
      otherFileNames: _otherFileNames(item.id),
    );

    if (newName != null && newName != item.fileName) {
      _applyRename(item.id, newName);
    }
  }

  Future<void> _linkCases(_PdfItem item) async {
    final result = await showLinkCasesSheet(
      context,
      availableCases: _availableCases,
      selected: item.cases,
    );

    if (result != null) _applyCases(item.id, result);
  }

  Future<void> _remove(_PdfItem item) async {
    final confirmed = await showRemovePdfDialog(
      context,
      fileName: item.fileName,
    );

    if (confirmed) _applyRemove(item.id);
  }

  void _download(_PdfItem item) {
    // TODO: Implement PDF download.
    _showMessage('Downloading ${item.fileName}…');
  }

  void _onMenuAction(_PdfItem item, PdfMenuAction action) {
    switch (action) {
      case PdfMenuAction.open:
        _openPdfDetails(item);
      case PdfMenuAction.download:
        _download(item);
      case PdfMenuAction.rename:
        _rename(item);
      case PdfMenuAction.linkCases:
        _linkCases(item);
      case PdfMenuAction.remove:
        _remove(item);
    }
  }

  // ------------------------------------------------
  // OPEN PDF DETAILS
  // ------------------------------------------------

  Future<void> _openPdfDetails(_PdfItem item) async {
    final id = item.id;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfDetailsScreen(
          fileName: item.fileName,
          date: item.date,
          linkedCases: List<String>.of(item.cases),
          availableCases: _availableCases,
          otherFileNames: _otherFileNames(id),
          onRenamed: (newName) => _applyRename(id, newName),
          onLinkedCasesChanged: (cases) => _applyCases(id, cases),
          onRemoved: () => _applyRemove(id),
        ),
      ),
    );
  }

  // ------------------------------------------------
  // BUILD
  // ------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final pdfs = _filteredPdfs;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header and search.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PdfHeader(
                    onUpload: () {
                      // TODO: Open the file picker / upload flow.
                    },
                  ),
                  _SearchField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _query = value);
                    },
                  ),
                ],
              ),
            ),

            // PDF list.
            Expanded(
              child: pdfs.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        20,
                        4,
                        20,
                        AppBottomNav.contentBottomSpace(context),
                      ),
                      itemCount: pdfs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = pdfs[index];

                        return _PdfCard(
                          item: item,
                          onOpen: () => _openPdfDetails(item),
                          onMenuAction: (action) => _onMenuAction(item, action),
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

// --------------------------------------------------
// HEADER
// --------------------------------------------------

class _PdfHeader extends StatelessWidget {
  final VoidCallback onUpload;

  const _PdfHeader({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Documents',
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
            text: 'Upload PDF',
            onPressed: onUpload,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
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
              size: 20,
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
                  hintText: 'Search filename',
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
      ),
    );
  }
}

// --------------------------------------------------
// PDF CARD
// --------------------------------------------------

class _PdfCard extends StatelessWidget {
  final _PdfItem item;
  final VoidCallback onOpen;
  final ValueChanged<PdfMenuAction> onMenuAction;

  const _PdfCard({
    required this.item,
    required this.onOpen,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(width: 1, color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File name and 3-dot menu.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      item.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                        letterSpacing: -0.31,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: PdfActionsMenu(
                      fileName: item.fileName,
                      subtitle: item.subtitle,
                      onSelected: onMenuAction,
                    ),
                  ),
                ],
              ),

              // Date and linked cases.
              Text(
                item.subtitle,
                style: const TextStyle(
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        AppBottomNav.contentBottomSpace(context),
      ),
      child: const Center(
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
              'No documents found',
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
              'Try a different search.',
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
