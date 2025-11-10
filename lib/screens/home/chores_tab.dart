import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/chore_provider.dart';
import 'package:flutter_app/widgets/chore_list_tile.dart';
import 'package:flutter_app/screens/chore/add_chore_screen.dart';

class ChoresTab extends StatefulWidget {
  const ChoresTab({super.key});

  @override
  State<ChoresTab> createState() => _ChoresTabState();
}

class _ChoresTabState extends State<ChoresTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final choreProvider = context.watch<ChoreProvider>();
    // Remove unused variable
    // final user = authProvider.currentUser!;

    // 집안일 데이터를 로딩 중인 경우 로딩 화면 표시
    if (choreProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('집안일'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final pendingChores = choreProvider.getPendingChores();
    final completedChores = choreProvider.getCompletedChores();
    final overdueChores = choreProvider.getOverdueChores();

    return Scaffold(
      appBar: AppBar(
        title: const Text('집안일'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('진행중'),
                  if (pendingChores.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${pendingChores.length}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('완료'),
                  if (completedChores.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${completedChores.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('지연'),
                  if (overdueChores.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${overdueChores.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ChoreList(chores: pendingChores, emptyMessage: '진행중인 집안일이 없습니다'),
          _ChoreList(chores: completedChores, emptyMessage: '완료한 집안일이 없습니다'),
          _ChoreList(chores: overdueChores, emptyMessage: '지연된 집안일이 없습니다'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddChoreScreen(
                householdId: authProvider.currentUser!.householdId!,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('집안일 추가'),
      ),
    );
  }
}

class _ChoreList extends StatelessWidget {
  final List chores;
  final String emptyMessage;

  const _ChoreList({
    required this.chores,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (chores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chores.length,
      itemBuilder: (context, index) {
        return ChoreListTile(chore: chores[index]);
      },
    );
  }
}
