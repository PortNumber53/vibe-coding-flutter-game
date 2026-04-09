import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/enums.dart';

/// Data class representing a leaderboard entry
class LeaderboardEntry {
  final String playerName;
  final int score;
  final DateTime date;
  final Difficulty difficulty;

  const LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.date,
    required this.difficulty,
  });
}

/// Leaderboard screen showing high scores
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late TabController _tabController;

  // Mock leaderboard data - replace with actual data from storage
  final List<LeaderboardEntry> _allTimeScores = [
      LeaderboardEntry(
      playerName: 'ProGamer99',
      score: 999999,
      date: DateTime(2024, 12, 15),
      difficulty: Difficulty.expert,
    ),
    LeaderboardEntry(
      playerName: 'VibeMaster',
      score: 875420,
      date: DateTime(2024, 12, 14),
      difficulty: Difficulty.hard,
    ),
    LeaderboardEntry(
      playerName: 'CodeNinja',
      score: 756300,
      date: DateTime(2024, 12, 13),
      difficulty: Difficulty.hard,
    ),
    LeaderboardEntry(
      playerName: 'FlutterDev',
      score: 643210,
      date: DateTime(2024, 12, 12),
      difficulty: Difficulty.medium,
    ),
    LeaderboardEntry(
      playerName: 'DartHero',
      score: 521000,
      date: DateTime(2024, 12, 11),
      difficulty: Difficulty.medium,
    ),
    LeaderboardEntry(
      playerName: 'WidgetWizard',
      score: 489500,
      date: DateTime(2024, 12, 10),
      difficulty: Difficulty.medium,
    ),
    LeaderboardEntry(
      playerName: 'StateBuilder',
      score: 345600,
      date: DateTime(2024, 12, 9),
      difficulty: Difficulty.easy,
    ),
    LeaderboardEntry(
      playerName: 'SetStateStar',
      score: 234500,
      date: DateTime(2024, 12, 8),
      difficulty: Difficulty.easy,
    ),
  ];

  late List<LeaderboardEntry> _weeklyScores;
  late List<LeaderboardEntry> _monthlyScores;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _tabController = TabController(length: 3, vsync: this);
    _slideController.forward();

    // Filter mock data for different time periods
    final now = DateTime.now();
    _weeklyScores = _allTimeScores
        .where((entry) => now.difference(entry.date).inDays <= 7)
        .toList();
    _monthlyScores = _allTimeScores
        .where((entry) => now.difference(entry.date).inDays <= 30)
        .toList();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.expert:
        return const Color(0xFFE94560);
      case Difficulty.hard:
        return const Color(0xFFF39C12);
      case Difficulty.medium:
        return const Color(0xFF2ECC71);
      case Difficulty.easy:
        return const Color(0xFF3498DB);
    }
  }

  Widget _buildMedal(int rank) {
    IconData icon;
    Color color;

    switch (rank) {
      case 0:
        icon = Icons.emoji_events;
        color = const Color(0xFFFFD700); // Gold
        break;
      case 1:
        icon = Icons.emoji_events;
        color = const Color(0xFFC0C0C0); // Silver
        break;
      case 2:
        icon = Icons.emoji_events;
        color = const Color(0xFFCD7F32); // Bronze
        break;
      default:
        icon = Icons.sports_score;
        color = const Color(0xFF0F3460);
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntry> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.format_list_numbered,
              size: 64,
              color: Colors.white.withAlpha(51),
            ),
            const SizedBox(height: 16),
            Text(
              'No scores yet!',
              style: TextStyle(
                color: Colors.white.withAlpha(128),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to score!',
              style: TextStyle(
                color: Colors.white.withAlpha(77),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isTop = index < 3;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 50)),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isTop
                  ? const Color(0xFF1A1A2E)
                  : const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(16),
              border: isTop
                  ? Border.all(color: _getDifficultyColor(entry.difficulty).withAlpha(128), width: 1)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isTop
                      ? _getDifficultyColor(entry.difficulty).withAlpha(26)
                      : const Color(0xFF0F3460).withAlpha(51),
                  blurRadius: isTop ? 15 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMedal(index),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getDifficultyColor(entry.difficulty).withAlpha(77),
                            _getDifficultyColor(entry.difficulty).withAlpha(26),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          entry.playerName.isEmpty ? '' : entry.playerName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getDifficultyColor(entry.difficulty),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  entry.playerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(entry.difficulty).withAlpha(51),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.difficulty.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getDifficultyColor(entry.difficulty),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy').format(entry.date),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE94560),
                        Color(0xFFC73E54),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    NumberFormat.decimalPattern().format(entry.score),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFE94560)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Stats overview
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatsCard(
                      'Your Rank',
                      '#12',
                      Icons.military_tech,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatsCard(
                      'Best Score',
                      '234,567',
                      Icons.emoji_events,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFFE94560),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'All Time'),
                  Tab(text: 'Monthly'),
                  Tab(text: 'Weekly'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLeaderboardList(_allTimeScores),
                  _buildLeaderboardList(_monthlyScores),
                  _buildLeaderboardList(_weeklyScores),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
