import 'package:material_ui/material_ui.dart';

import 'forms/add_case_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_bottom_nav.dart';
import 'details/case_details_screen.dart';

// --------------------------------------------------
// DATA
// --------------------------------------------------

enum _CaseStatus {
  active('Active', AppColors.statusActive),
  pending('Pending', AppColors.statusPending),
  onHold('On Hold', AppColors.statusInactive),
  closed('Closed', AppColors.statusInactive);

  const _CaseStatus(this.label, this.color);

  final String label;
  final Color color;
}

class _CaseItem {
  final String title;
  final String caseNumber;
  final String client;
  final _CaseStatus status;
  final String nextHearing;

  const _CaseItem({
    required this.title,
    required this.caseNumber,
    required this.client,
    required this.status,
    required this.nextHearing,
  });
}

// --------------------------------------------------
// SCREEN
// --------------------------------------------------

class CasesScreen extends StatefulWidget {
  const CasesScreen({super.key});

  @override
  State<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> {
  // Replace with real data from your repository / provider later.
  static const List<_CaseItem> _allCases = [
    _CaseItem(
      title: 'Rahman vs Karim',
      caseNumber: 'CS-2024/118',
      client: 'Rafiq Rahman',
      status: _CaseStatus.active,
      nextHearing: '28 Oct, 10:30',
    ),
    _CaseItem(
      title: 'Property Ownership Dispute',
      caseNumber: 'CS-2023/402',
      client: 'Nusrat Traders Ltd',
      status: _CaseStatus.active,
      nextHearing: '28 Oct, 12:00',
    ),
    _CaseItem(
      title: 'Commercial Contract Matter',
      caseNumber: 'CS-2024/077',
      client: 'Nusrat Traders Ltd',
      status: _CaseStatus.pending,
      nextHearing: '28 Oct, 14:30',
    ),
    _CaseItem(
      title: 'Akter Family Settlement',
      caseNumber: 'FC-2024/031',
      client: 'Sabina Akter',
      status: _CaseStatus.onHold,
      nextHearing: '4 Nov, 10:00',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();

  // null means the "All" chip is selected.
  _CaseStatus? _selectedStatus;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_CaseItem> get _filteredCases {
    final query = _query.trim().toLowerCase();

    return _allCases.where((item) {
      final matchesStatus =
          _selectedStatus == null || item.status == _selectedStatus;

      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.caseNumber.toLowerCase().contains(query) ||
          item.client.toLowerCase().contains(query);

      return matchesStatus && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cases = _filteredCases;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed top area: title, search, filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CasesHeader(
                    onAddCase: () async {
                      final result = await Navigator.of(context).push<CaseFormData>(
                        MaterialPageRoute(builder: (_) => const AddCaseScreen()),
                      );
                      if (!mounted || result == null) return;
                      // TODO: refresh the list / add the new case from `result`.
                    },
                  ),
                  _SearchField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  _StatusFilters(
                    selected: _selectedStatus,
                    onSelected: (status) =>
                        setState(() => _selectedStatus = status),
                  ),
                ],
              ),
            ),

            // Scrollable list
            Expanded(
              child: cases.isEmpty
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
                      itemCount: cases.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _CaseCard(item: cases[index]);
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

class _CasesHeader extends StatelessWidget {
  final VoidCallback onAddCase;

  const _CasesHeader({required this.onAddCase});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Cases',
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
            text: 'Add Case',
            onPressed: onAddCase,
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
                  hintText: 'Search name, number, or client',
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
// STATUS FILTER CHIPS
// --------------------------------------------------

class _StatusFilters extends StatelessWidget {
  final _CaseStatus? selected;
  final ValueChanged<_CaseStatus?> onSelected;

  const _StatusFilters({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: selected == null,
              onTap: () => onSelected(null),
            ),
            for (final status in _CaseStatus.values) ...[
              const SizedBox(width: 8),
              _FilterChip(
                label: status.label,
                isSelected: selected == status,
                onTap: () => onSelected(status),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textNavy : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            width: 1,
            color: isSelected ? AppColors.textNavy : AppColors.border,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textMuted,
            fontSize: 12,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
            height: 1.33,
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// CASE CARD
// --------------------------------------------------

class _CaseCard extends StatelessWidget {
  final _CaseItem item;

  const _CaseCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CaseDetailsScreen(
              title: item.title,
              caseNumber: item.caseNumber,
              client: item.client,
              statusLabel: item.status.label,
              statusColor: item.status.color,
            ),
          ),
        );
      },
      child: Container(
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
            // Title + status
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                      letterSpacing: -0.31,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _StatusLabel(status: item.status),
              ],
            ),

            // Case number + client
            Text(
              '${item.caseNumber} · ${item.client}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                height: 1.33,
              ),
            ),

            // Next hearing
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Next hearing: ${item.nextHearing}',
                style: const TextStyle(
                  color: AppColors.textNavy,
                  fontSize: 12,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final _CaseStatus status;

  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: status.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          status.label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
            height: 1.33,
          ),
        ),
      ],
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
              'No cases found',
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
              'Try a different search or filter.',
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