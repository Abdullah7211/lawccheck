import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_snackbar.dart';
import 'edit/edit_client_screen.dart';
import 'forms/add_client_screen.dart';
import 'details/client_details_screen.dart';

// --------------------------------------------------
// DATA
// --------------------------------------------------

const Color _errorColor = Color(0xFFC0392B);

enum _ClientAction { edit, remove }

class _ClientItem {
  final String name;
  final String clientId;
  final String phone;
  final int caseCount;

  // Extra details used by the Edit Client form. Replace with real data from
  // your repository / provider later.
  final String email;
  final String clientType;
  final String whatsapp;
  final String address;
  final String preferredContact;
  final String notes;

  const _ClientItem({
    required this.name,
    required this.clientId,
    required this.phone,
    required this.caseCount,
    this.email = '',
    this.clientType = 'Individual',
    this.whatsapp = '',
    this.address = '',
    this.preferredContact = 'Phone',
    this.notes = '',
  });

  /// A brand new client from the Add Client form (no cases yet).
  factory _ClientItem.fromFormData(String clientId, ClientFormData data) {
    return _ClientItem(
      name: data.name,
      clientId: clientId,
      phone: data.phone,
      caseCount: 0,
      email: data.email,
      clientType: data.clientType,
      whatsapp: data.whatsapp,
      address: data.address,
      preferredContact: data.preferredContact,
      notes: data.notes,
    );
  }

  ClientFormData toFormData() => ClientFormData(
        name: name,
        phone: phone,
        email: email,
        clientType: clientType,
        whatsapp: whatsapp,
        address: address,
        preferredContact: preferredContact,
        notes: notes,
      );

  /// Same client (same id / case count) with the edited form values applied.
  _ClientItem updatedWith(ClientFormData data) => _ClientItem(
        name: data.name,
        clientId: clientId,
        phone: data.phone,
        caseCount: caseCount,
        email: data.email,
        clientType: data.clientType,
        whatsapp: data.whatsapp,
        address: data.address,
        preferredContact: data.preferredContact,
        notes: data.notes,
      );
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
  // (Not const anymore so a client can be added / removed.)
  final List<_ClientItem> _allClients = [
    const _ClientItem(
      name: 'Rafiq Rahman',
      clientId: 'CL-001',
      phone: '+880 1711 000111',
      caseCount: 1,
    ),
    const _ClientItem(
      name: 'Nusrat Traders Ltd',
      clientId: 'CL-002',
      phone: '+880 1819 222333',
      caseCount: 2,
      clientType: 'Company',
    ),
    const _ClientItem(
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

  /// Next free id like CL-004 (based on the highest existing number, so ids
  /// are never reused after a client is removed).
  String _nextClientId() {
    int highest = 0;
    for (final client in _allClients) {
      final number = int.tryParse(client.clientId.replaceAll('CL-', ''));
      if (number != null && number > highest) highest = number;
    }
    return 'CL-${(highest + 1).toString().padLeft(3, '0')}';
  }

  // ------------------------------------------------
  // Actions
  // ------------------------------------------------

  void _openDetails(_ClientItem client) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClientDetailsScreen(
          name: client.name,
          clientId: client.clientId,
          phone: client.phone,
        ),
      ),
    );
  }

  Future<void> _addClient() async {
    final result = await Navigator.of(context).push<ClientFormData>(
      MaterialPageRoute(builder: (_) => const AddClientScreen()),
    );
    if (!mounted || result == null) return;

    setState(() {
      _allClients.insert(0, _ClientItem.fromFormData(_nextClientId(), result));
    });
    // TODO: create the client in your repository / provider.

    showAppSnackBar(context, 'Client added');
  }

  Future<void> _editClient(_ClientItem client) async {
    final result = await Navigator.of(context).push<ClientFormData>(
      MaterialPageRoute(
        builder: (_) => EditClientScreen(
          clientId: client.clientId,
          initial: client.toFormData(),
        ),
      ),
    );
    if (!mounted || result == null) return;

    setState(() {
      final index = _allClients.indexWhere((c) => c.clientId == client.clientId);
      if (index != -1) _allClients[index] = client.updatedWith(result);
    });
    // TODO: save the updated client to your repository / provider.

    showAppSnackBar(context, 'Client updated');
  }

  Future<void> _showClientActions(_ClientItem client) async {
    FocusScope.of(context).unfocus();

    final action = await showModalBottomSheet<_ClientAction>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ClientActionsSheet(clientName: client.name),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case _ClientAction.edit:
        await _editClient(client);
      case _ClientAction.remove:
        await _confirmRemove(client);
    }
  }

  Future<void> _confirmRemove(_ClientItem client) async {
    final casesNote = client.caseCount > 0
        ? ' This client is linked to ${client.caseCount} '
            '${client.caseCount == 1 ? 'case' : 'cases'}.'
        : '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Remove client?',
          style: TextStyle(
            color: AppColors.textNavy,
            fontSize: 17,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            letterSpacing: -0.43,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${client.name}? '
          "This can't be undone.$casesNote",
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
            height: 1.43,
            letterSpacing: -0.15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Remove',
              style: TextStyle(color: _errorColor),
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    setState(() {
      _allClients.removeWhere((c) => c.clientId == client.clientId);
    });
    // TODO: delete the client in your repository / provider.

    showAppSnackBar(context, '${client.name} removed');
  }

  // ------------------------------------------------
  // Build
  // ------------------------------------------------

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
                  _ClientsHeader(onAddClient: _addClient),
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
                        final client = clients[index];

                        return _ClientCard(
                          item: client,
                          onTap: () => _openDetails(client),
                          onMenuTap: () => _showClientActions(client),
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
  final VoidCallback onTap;
  final VoidCallback onMenuTap;

  const _ClientCard({
    required this.item,
    required this.onTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final String casesLabel =
        '${item.caseCount} ${item.caseCount == 1 ? 'case' : 'cases'}';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
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
            // Three-dot menu (its own tap target, so the card tap isn't fired)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onMenuTap,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
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
// ACTIONS BOTTOM SHEET (Edit / Remove)
// --------------------------------------------------

class _ClientActionsSheet extends StatelessWidget {
  final String clientName;

  const _ClientActionsSheet({required this.clientName});

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
              clientName,
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
          _SheetOption(
            icon: Icons.edit_outlined,
            label: 'Edit',
            color: AppColors.textDark,
            onTap: () => Navigator.of(context).pop(_ClientAction.edit),
          ),
          _SheetOption(
            icon: Icons.delete_outline_rounded,
            label: 'Remove',
            color: _errorColor,
            onTap: () => Navigator.of(context).pop(_ClientAction.remove),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
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