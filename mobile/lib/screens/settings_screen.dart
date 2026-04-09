import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Game difficulty levels
enum Difficulty { easy, medium, hard, expert }

/// Game theme options
enum GameTheme { dark, light, neon, retro }

/// Extension for enum display strings
extension DifficultyExtension on Difficulty {
  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }
}

extension GameThemeExtension on GameTheme {
  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }
}

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
  Difficulty _difficulty = Difficulty.medium;
  GameTheme _theme = GameTheme.dark;

  bool _isLoading = true;

  final List<Difficulty> _difficulties = Difficulty.values;
  final List<GameTheme> _themes = GameTheme.values;

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

    _loadSettings();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _soundEnabled = prefs.getBool('soundEnabled') ?? true;
        _musicEnabled = prefs.getBool('musicEnabled') ?? true;
        _soundVolume = prefs.getDouble('soundVolume') ?? 0.8;
        _musicVolume = prefs.getDouble('musicVolume') ?? 0.6;
        _difficulty = _parseDifficulty(prefs.getString('difficulty'));
        _theme = _parseTheme(prefs.getString('theme'));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// Parse difficulty from string
  Difficulty _parseDifficulty(String? value) {
    if (value == null) return Difficulty.medium;
    return Difficulty.values.firstWhere(
      (d) => d.name == value.toLowerCase(),
      orElse: () => Difficulty.medium,
    );
  }

  /// Parse theme from string
  GameTheme _parseTheme(String? value) {
    if (value == null) return GameTheme.dark;
    return GameTheme.values.firstWhere(
      (t) => t.name == value.toLowerCase(),
      orElse: () => GameTheme.dark,
    );
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('soundEnabled', _soundEnabled);
      await prefs.setBool('musicEnabled', _musicEnabled);
      await prefs.setDouble('soundVolume', _soundVolume);
      await prefs.setDouble('musicVolume', _musicVolume);
      await prefs.setString('difficulty', _difficulty.name);
      await prefs.setString('theme', _theme.name);
      return;
    } catch (e) {
      rethrow;
    }
  }

  /// Reset all game progress and settings
  Future<void> _resetAllProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear game-specific keys
      await prefs.remove('soundEnabled');
      await prefs.remove('musicEnabled');
      await prefs.remove('soundVolume');
      await prefs.remove('musicVolume');
      await prefs.remove('difficulty');
      await prefs.remove('theme');

      // Reset to defaults
      await _resetToDefaults();
    } catch (e) {
      // Error occurred during reset
    }
  }

  /// Reset to default values
  Future<void> _resetToDefaults() async {
    setState(() {
      _soundEnabled = true;
      _musicEnabled = true;
      _soundVolume = 0.8;
      _musicVolume = 0.6;
      _difficulty = Difficulty.medium;
      _theme = GameTheme.dark;
    });
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
            onPressed: () async {
              Navigator.of(context).pop();
              await _resetAllProgress();
              if (mounted) {
                _showSuccessSnackBar('All progress has been reset');
              }
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE94560),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onSaveSettings() async {
    try {
      await _saveSettings();
      if (mounted) {
        _showSuccessSnackBar('Settings saved!');
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to save settings');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE94560),
          ),
        ),
      );
    }

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
                      _buildDropdownTile<Difficulty>(
                        icon: Icons.speed,
                        title: 'Difficulty',
                        value: _difficulty,
                        valueDisplay: _difficulty.displayName,
                        items: _difficulties,
                        getItemDisplay: (d) => d.displayName,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _difficulty = value);
                          }
                        },
                      ),
                      const Divider(color: Colors.white24),
                      _buildDropdownTile<GameTheme>(
                        icon: Icons.palette,
                        title: 'Theme',
                        value: _theme,
                        valueDisplay: _theme.displayName,
                        items: _themes,
                        getItemDisplay: (t) => t.displayName,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _theme = value);
                          }
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
                    onPressed: _onSaveSettings,
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

  Widget _buildDropdownTile<T>(({
    required IconData icon,
    required String title,
    required T value,
    required String valueDisplay,
    required List<T> items,
    required String Function(T) getItemDisplay,
    required ValueChanged<T?> onChanged,
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
      trailing: DropdownButton<T>(
        value: value,
        dropdownColor: const Color(0xFF16213E),
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        style: const TextStyle(color: Colors.white70),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(getItemDisplay(item)),
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
