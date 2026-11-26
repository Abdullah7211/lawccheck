import 'package:material_ui/material_ui.dart';

import '../forms/add_team_screen.dart';

/// Same form as "Add", pre-filled. Returns the updated TeamFormData.
class EditTeamScreen extends StatelessWidget {
  const EditTeamScreen({super.key, required this.member});

  final TeamFormData member;

  @override
  Widget build(BuildContext context) {
    return AddTeamScreen(
      initial: member,
      title: 'Edit Team Member',
      saveLabel: 'Save Changes',
    );
  }
}