import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const AdvocateNotebookApp());
}

class AdvocateNotebookApp extends StatelessWidget {
  const AdvocateNotebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Advocate Notebook',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF173B57)),
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const navy = Color(0xFF173B57);
  static const muted = Color(0xFF7B8794);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Advocate Notebook',
          style: TextStyle(
            color: navy,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: navy),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Color(0xFFE5EBF0),
              child: Icon(Icons.person_outline, color: navy),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              const Text(
                'Good morning, Advocate',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Here is your legal practice overview.',
                style: TextStyle(color: muted, fontSize: 14),
              ),

              const SizedBox(height: 24),

              // Date card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: navy,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR WORKSPACE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Stay organized.\nStay prepared.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        height: 1.35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Manage your cases, hearings and daily tasks.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              const SectionTitle(title: 'Case overview'),
              const SizedBox(height: 14),

              // Statistics
              const Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Cases',
                      number: '48',
                      icon: Icons.folder_outlined,
                      color: Color(0xFF3D79B5),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Active Cases',
                      number: '32',
                      icon: Icons.work_outline,
                      color: Color(0xFF299B78),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Upcoming',
                      number: '08',
                      icon: Icons.calendar_month_outlined,
                      color: Color(0xFFD58A37),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Completed',
                      number: '16',
                      icon: Icons.check_circle_outline,
                      color: Color(0xFF8065B5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Quick actions
              const SectionTitle(title: 'Quick actions'),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: QuickAction(
                      icon: Icons.add_box_outlined,
                      title: 'New Case',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: QuickAction(
                      icon: Icons.event_note_outlined,
                      title: 'Add Hearing',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: QuickAction(
                      icon: Icons.task_alt,
                      title: 'Add Task',
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Upcoming hearings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle(title: 'Upcoming hearings'),
                  TextButton(onPressed: () {}, child: const Text('View all')),
                ],
              ),

              const SizedBox(height: 10),

              const HearingCard(
                caseName: 'Rahman vs Karim',
                court: 'District Court, Courtroom 02',
                time: '10:30 AM',
                date: '24 NOV',
              ),

              const SizedBox(height: 12),

              const HearingCard(
                caseName: 'State vs Ahmed',
                court: 'Sessions Court, Courtroom 05',
                time: '12:00 PM',
                date: '26 NOV',
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: navy,
        unselectedItemColor: muted,
        currentIndex: 0,
        onTap: (index) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            label: 'Cases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Diary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Section heading
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: HomeScreen.navy,
      ),
    );
  }
}

// Statistics card
class StatCard extends StatelessWidget {
  final String title;
  final String number;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.number,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFECEFF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 15),
          Text(
            number,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: HomeScreen.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: HomeScreen.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Quick action button
class QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const QuickAction({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFECEFF3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: HomeScreen.navy, size: 25),
            const SizedBox(height: 9),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: HomeScreen.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Hearing card
class HearingCard extends StatelessWidget {
  final String caseName;
  final String court;
  final String time;
  final String date;

  const HearingCard({
    super.key,
    required this.caseName,
    required this.court,
    required this.time,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFECEFF3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.gavel_outlined,
              color: HomeScreen.navy,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: HomeScreen.navy,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  court,
                  style: const TextStyle(fontSize: 11, color: HomeScreen.muted),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              date,
              style: const TextStyle(
                color: HomeScreen.navy,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
