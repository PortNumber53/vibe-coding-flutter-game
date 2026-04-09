import 'package:flutter/material.dart';
import 'dart:async';

/// Settings screen for game configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Settings state
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _soundVolume = 0.8;
  double _musicVolume = 0.6;
  String _difficulty = 'Medium';
  String _theme = 'Dark';

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard', 'Expert'];
  final List<String> _themes = ['Dark', 'Light', 'Neon', 'Retro'];

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
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'Reset All Progress?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This will erase all your saved data, achievements, and high scores. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSuccessSnackBar('All progress has been reset');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2ECC71),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
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
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Audio Section
                _buildSectionHeader('Audio'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildToggleTile(
                        icon: Icons.volume_up,
                        title: 'Sound Effects',
                        subtitle: 'Game sounds and SFX',
                        value: _soundEnabled,
                        onChanged: (value) {
                          setState(() => _soundEnabled = value);
                        },
                      ),
                      if (_soundEnabled) ...[
                        const Divider(color: Colors.white24),
                        _buildSliderTile(
                          icon: Icons.volume_down,
                          title: 'Sound Volume',
                          value: _soundVolume,
                          onChanged: (value) {
                            setState(() => _soundVolume = value);
                          },
                        ),
                      ],
                      const Divider(color: Colors.white24),
                      _buildToggleTile(
                        icon: Icons.music_note,
                        title: 'Background Music',
                        subtitle: 'Epic game soundtrack',
                        value: _musicEnabled,
                        onChanged: (value) {
                          setState(() => _musicEnabled = value);
                        },
                      ),
                      if (_musicEnabled) ...[
                        const Divider(color: Colors.white24),
                        _buildSliderTile(
                          icon: Icons.volume_mute,
                          title: 'Music Volume',
                          value: _musicVolume,
                          onChanged: (value) {
                            setState(() => _musicVolume = value);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Gameplay Section
                _buildSectionHeader('Gameplay'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildDropdownTile(
                        icon: Icons.speed,
                        title: 'Difficulty',
                        value: _difficulty,
                        items: _difficulties,
                        onChanged: (value) {
                          setState(() => _difficulty = value!);
                        },
                      ),
                      const Divider(color: Colors.white24),
                      _buildDropdownTile(
                        icon: Icons.palette,
                        title: 'Theme',
                        value: _theme,
                        items: _themes,
                        onChanged: (value) {
                          setState(() => _theme = value!);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Data Section
                _buildSectionHeader('Data'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildActionTile(
                        icon: Icons.delete_forever,
                        title: 'Reset Progress',
                        subtitle: 'Clear all saved data',
                        color: const Color(0xFFE94560),
                        onTap: _showResetConfirmation,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showSuccessSnackBar('Settings saved!');
                      Timer(const Duration(milliseconds: 500), () {
                        Navigator.of(context).pop();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE94560),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Version info
                const Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3460).withAlpha(77),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF0F3460),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFE94560)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFE94560),
        activeTrackColor: const Color(0xFFE94560).withAlpha(77),
        inactiveThumbColor: Colors.white70,
        inactiveTrackColor: Colors.white24,
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white54, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Slider(
                  value: value,
                  onChanged: onChanged,
                  activeColor: const Color(0xFFE94560),
                  inactiveColor: Colors.white24,
                  divisions: 10,
                  label: '${(value * 100).round()}%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF0F3460),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFE94560)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: const Color(0xFF16213E),
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        style: const TextStyle(color: Colors.white70),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withAlpha(51),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }
}
