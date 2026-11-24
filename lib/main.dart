
import 'package:material_ui/material_ui.dart';

import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'widgets/app_bottom_nav.dart';

import 'screens/home_screen.dart';
import 'screens/cases_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/pdf_screen.dart';

void main() {
  runApp(const AdvocateNotebookApp());
}

class AdvocateNotebookApp extends StatelessWidget {
  const AdvocateNotebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advocate Notebook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CasesScreen(),
    ClientsScreen(),
    TasksScreen(),
    PdfScreen(),
  ];

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Screen content fills everything and scrolls behind the nav.
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: _screens[_currentIndex],
            ),
          ),

          // Floating nav. Only the navy container is visible and tappable.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
