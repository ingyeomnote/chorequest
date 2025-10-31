import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/household_provider.dart';
import 'package:flutter_app/providers/chore_provider.dart';
import 'package:flutter_app/screens/home/dashboard_tab.dart';
import 'package:flutter_app/screens/home/chores_tab.dart';
import 'package:flutter_app/screens/home/leaderboard_tab.dart';
import 'package:flutter_app/screens/home/profile_tab.dart';
import 'package:flutter_app/screens/household/create_household_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final authProvider = context.read<AuthProvider>();
    final householdProvider = context.read<HouseholdProvider>();
    final choreProvider = context.read<ChoreProvider>();

    // 최신 사용자 정보 새로고침
    authProvider.refreshCurrentUser();

    final householdId = authProvider.currentUser?.householdId;
    if (householdId != null && householdId.isNotEmpty) {
      try {
        await householdProvider.loadHousehold(householdId);
        await choreProvider.loadChores(householdId);
      } catch (e) {
        debugPrint('데이터 로드 실패: $e');
      }
    }

    setState(() => _isLoading = false);
  }

  void _showCreateHouseholdDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateHouseholdScreen(),
      ),
    ).then((_) => _initializeData());
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user?.householdId == null || user!.householdId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ChoreQuest'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  '가구가 없습니다',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  '가족과 함께 사용할 가구를 만들어보세요',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _showCreateHouseholdDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('가구 만들기'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final tabs = [
      const DashboardTab(),
      const ChoresTab(),
      const LeaderboardTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: '대시보드',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: '집안일',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: '리더보드',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}
