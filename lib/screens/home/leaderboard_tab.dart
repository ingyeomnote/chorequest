import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/household_provider.dart';
import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final householdProvider = context.watch<HouseholdProvider>();
    final leaderboard = householdProvider.getLeaderboard();

    return Scaffold(
      appBar: AppBar(
        title: const Text('리더보드'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => householdProvider.refresh(),
          ),
        ],
      ),
      body: leaderboard.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.leaderboard,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '아직 가구 멤버가 없습니다',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Top 3 Podium
                if (leaderboard.isNotEmpty) _TopThreePodium(leaderboard: leaderboard),

                const SizedBox(height: 16),

                // Full Leaderboard
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: leaderboard.length,
                    itemBuilder: (context, index) {
                      return _LeaderboardTile(
                        user: leaderboard[index],
                        rank: index + 1,
                      ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.2, end: 0);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _TopThreePodium extends StatelessWidget {
  final List<UserModel> leaderboard;

  const _TopThreePodium({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (leaderboard.length > 1)
            _PodiumItem(
              user: leaderboard[1],
              rank: 2,
              height: 120,
              color: Colors.grey[400]!,
            ),
          const SizedBox(width: 8),
          if (leaderboard.isNotEmpty)
            _PodiumItem(
              user: leaderboard[0],
              rank: 1,
              height: 160,
              color: Colors.amber,
            ),
          const SizedBox(width: 8),
          if (leaderboard.length > 2)
            _PodiumItem(
              user: leaderboard[2],
              rank: 3,
              height: 100,
              color: Colors.brown[400]!,
            ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final UserModel user;
  final int rank;
  final double height;
  final Color color;

  const _PodiumItem({
    required this.user,
    required this.rank,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: rank == 1 ? 40 : 32,
          backgroundColor: color.withValues(alpha: 0.3),
          child: Text(
            'Lv ${user.level}',
            style: TextStyle(
              fontSize: rank == 1 ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.name,
          style: TextStyle(
            fontSize: rank == 1 ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${user.xp} XP',
          style: TextStyle(
            fontSize: rank == 1 ? 14 : 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withValues(alpha: 0.6)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.all(8),
          child: Icon(
            rank == 1
                ? Icons.emoji_events
                : rank == 2
                    ? Icons.military_tech
                    : Icons.star,
            color: Colors.white,
            size: rank == 1 ? 40 : 32,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8), delay: (rank * 100).ms);
  }
}

class _LeaderboardTile extends StatelessWidget {
  final UserModel user;
  final int rank;

  const _LeaderboardTile({
    required this.user,
    required this.rank,
  });

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor(rank);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [rankColor, rankColor.withValues(alpha: 0.6)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rank',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.stars, size: 16, color: rankColor),
            const SizedBox(width: 4),
            Text('Level ${user.level}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${user.xp}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: rankColor,
              ),
            ),
            const Text(
              'XP',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
