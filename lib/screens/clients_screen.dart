import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_bottom_nav.dart';

// --------------------------------------------------
// DATA
// --------------------------------------------------

class _ClientItem {
  final String name;
  final String clientId;
  final String phone;
  final int caseCount;

  const _ClientItem({
    required this.name,
    required this.clientId,
    required this.phone,
    required this.caseCount,
  });
}

// --------------------------------------------------
// SCREEN
// --------------------------------------------------

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  // Replace with real data from your repository / provider later.
  static const List<_ClientItem> _allClients = [
    _ClientItem(
      name: 'Rafiq Rahman',
      clientId: 'CL-001',
      phone: '+880 1711 000111',
      caseCount: 1,
    ),
    _ClientItem(
      name: 'Nusrat Traders Ltd',
      clientId: 'CL-002',
      phone: '+880 1819 222333',
      caseCount: 2,
    ),
    _ClientItem(
      name: 'Sabina Akter',
      clientId: 'CL-003',
      phone: '+880 1915 444555',
      caseCount: 1,
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ClientItem> get _filteredClients {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _allClients;

    return _allClients.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.clientId.toLowerCase().contains(query) ||
          item.phone.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final clients = _filteredClients;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed top area: title + search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ClientsHeader(
                    onAddClient: () {
                      // TODO: open the Add Client screen.
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
              child: clients.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        AppBottomNav.contentBottomSpace(context),
                      ),
                      itemCount: clients.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _ClientCard(item: clients[index]);
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

class _ClientsHeader extends StatelessWidget {
  final VoidCallback onAddClient;

  const _ClientsHeader({required this.onAddClient});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Client',
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
            text: 'Add Client',
            onPressed: onAddClient,
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
// SEARCH (same as Cases screen)
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
                  hintText: 'Search clients',
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
// CLIENT CARD
// --------------------------------------------------

class _ClientCard extends StatelessWidget {
  final _ClientItem item;

  const _ClientCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final String casesLabel =
        '${item.caseCount} ${item.caseCount == 1 ? 'case' : 'cases'}';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // TODO: open the client details screen.
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1, color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
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
                  Text(
                    '${item.clientId} · ${item.phone}',
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
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              casesLabel,
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
              'No clients found',
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