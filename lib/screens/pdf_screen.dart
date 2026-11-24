import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_bottom_nav.dart';

// --------------------------------------------------
// DATA
// --------------------------------------------------

class _PdfItem {
  final String fileName;
  final String date;
  final List<String> cases;

  const _PdfItem({
    required this.fileName,
    required this.date,
    required this.cases,
  });

  /// e.g. "19 Oct · Commercial Contract Matter, Property Ownership Dispute"
  String get subtitle => '$date · ${cases.join(', ')}';
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
  // Replace with real data from your repository / provider later.
  static const List<_PdfItem> _allPdfs = [
    _PdfItem(
      fileName: 'Plaint_Rahman_v_Karim.pdf',
      date: '28 Sept',
      cases: ['Rahman vs Karim'],
    ),
    _PdfItem(
      fileName: 'Title_Deed_Plot42.pdf',
      date: '13 Oct',
      cases: ['Property Ownership Dispute'],
    ),
    _PdfItem(
      fileName: 'Supply_Agreement.pdf',
      date: '19 Oct',
      cases: ['Commercial Contract Matter', 'Property Ownership Dispute'],
    ),
  ];

  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_PdfItem> get _filteredPdfs {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) return _allPdfs;

    return _allPdfs
        .where((item) => item.fileName.toLowerCase().contains(query))
        .toList();
  }

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
            // Fixed top area: title + upload button, search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PdfHeader(
                    onUpload: () {
                      // TODO: open the file picker / upload flow.
                    },
                  ),
                  _SearchField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ],
              ),
            ),

            // Scrollable list
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
                          onOpen: () {
                            // TODO: open the PDF viewer.
                          },
                          onDownload: () {
                            // TODO: download the PDF.
                          },
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
// SEARCH (same as Cases screen, different hint)
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
  final VoidCallback onDownload;

  const _PdfCard({
    required this.item,
    required this.onOpen,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File name + trailing icon
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
              const SizedBox(width: 12),
              // The Figma export had an empty 24x24 icon slot here.
              // Swap the icon for whatever you use in the design.
              const Icon(
                Icons.picture_as_pdf_rounded,
                size: 24,
                color: AppColors.textMuted,
              ),
            ],
          ),

          // Date + linked case(s)
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

          // Actions
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: _OutlinedActionButton(label: 'Open', onTap: onOpen),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _OutlinedActionButton(
                    label: 'Download',
                    onTap: onDownload,
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

class _OutlinedActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlinedActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: AppColors.border),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textNavy,
            fontSize: 14,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
            height: 1.43,
            letterSpacing: -0.15,
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