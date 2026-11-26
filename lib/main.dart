import 'package:material_ui/material_ui.dart';

import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/app_drawer.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cases_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/pdf_screen.dart';
import 'screens/team_screen.dart';
import 'screens/monthly_schedule_screen.dart';
import 'screens/expense_screen.dart';

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
      home: const SplashScreen(),
    );
  }
}

// Main app navigation: Home, Cases, Clients, Tasks, PDF
// (+ Team and Monthly schedule, opened from the drawer).
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _goTo(int index) => setState(() => _currentIndex = index);

  // Index map (must match the drawer):
  // 0 Home, 1 Cases, 2 Clients, 3 Tasks, 4 PDF, 5 Team, 6 Monthly schedule
  Widget _screenFor(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const CasesScreen();
      case 2:
        return const ClientsScreen();
      case 3:
        return const TasksScreen();
      case 4:
        return const PdfScreen();
      case 5:
        return const TeamScreen();
      case 6:
        // Back arrow returns to Home instead of popping the whole app.
        return MonthlyScheduleScreen(onBack: () => _goTo(0));
      case 7:
        return ExpenseScreen(onBack: () => _goTo(0));
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // On any tab other than Home, the phone's back button goes to Home first.
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goTo(0);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,

        // Sidebar (3/4 of the screen width).
        drawer: AppDrawer(
          currentIndex: _currentIndex,
          onSelectTab: _goTo,
        ),

        // Lighter dim behind the drawer (default is a heavy dark grey).
        drawerScrimColor: const Color(0x33000000),

        body: Stack(
          children: [
            // Screen content fills the available space.
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: _screenFor(_currentIndex),
              ),
            ),

            // Floating bottom navigation.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomNav(
                currentIndex: _currentIndex,
                onTap: _goTo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}