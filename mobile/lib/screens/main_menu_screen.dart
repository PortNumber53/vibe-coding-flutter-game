import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'leaderboard_screen.dart';

/// Main Menu Screen with navigation options:
/// - New Game
/// - Load Game
/// - Game Settings
/// - Leaderboard
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;

  final List<MenuItem> _menuItems = [
    MenuItem(
      title: 'New Game',
      icon: Icons.play_arrow,
      color: const Color(0xFF4CAF50),
      onTap: (context) => _showNotImplemented(context, 'New Game'),
    ),
    MenuItem(
      title: 'Load Game',
      icon: Icons.folder_open,
      color: const Color(0xFF2196F3),
      onTap: (context) => _showNotImplemented(context, 'Load Game'),
    ),
    MenuItem(
      title: 'Game Settings',
      icon: Icons.settings,
      color: const Color(0xFFFF9800),
      onTap: (context) => _navigateToSettings(context),
    ),
    MenuItem(
      title: 'Leaderboard',
      icon: Icons.emoji_events,
      color: const Color(0xFFFFC107),
      onTap: (context) => _navigateToLeaderboard(context),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create staggered animations for each menu item
    _slideAnimations = List.generate(
      _menuItems.length,
      (index) => Tween<Offset>(
        begin: const Offset(1.5, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.15,
            0.6 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  static void _showNotImplemented(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          feature,
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This feature is coming soon!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFFE94560)),
            ),
          ),
        ],
      ),
    );
  }

  static void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  static void _navigateToLeaderboard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LeaderboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with title
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videogame_asset,
                          size: 40,
                          color: const Color(0xFFE94560).withAlpha(230),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VIBE CODING',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE94560),
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'GAME',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: Colors.white60,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFFE94560).withAlpha(179),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Menu buttons
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 350),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index) {
                        return SlideTransition(
                          position: _slideAnimations[index],
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildMenuButton(_menuItems[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.white.withAlpha(77),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(MenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => item.onTap(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                item.color.withAlpha(51),
                item.color.withAlpha(26),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.color.withAlpha(128),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: item.color.withAlpha(38),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.color.withAlpha(77),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: item.color.withAlpha(204),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data class representing a menu item
class MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final void Function(BuildContext context) onTap;

  MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
