import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/game_world.dart';
import '../game/engine/game_loop.dart';

/// Main game screen for the horizontal shoot 'em up
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> 
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late GameWorld _gameWorld;
  late AnimationController _uiAnimationController;
  
  // For smooth UI updates without rebuilding the whole tree every frame
  int _uiUpdateCounter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _gameWorld = GameWorld();
    _gameWorld.onGameOver = _handleGameOver;
    
    _uiAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    
    _uiAnimationController.addListener(_onUIUpdate);
  }
  
  void _onUIUpdate() {
    // Update UI more infrequently than game loop
    _uiUpdateCounter++;
    if (_uiUpdateCounter % 2 == 0) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _uiAnimationController.dispose();
    _gameWorld.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _gameWorld.pauseGame();
    } else if (state == AppLifecycleState.resumed) {
      if (_gameWorld.state == GameState.paused) {
        // Keep paused, let user resume manually
      }
    }
  }

  void _handleGameOver() {
    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'GAME OVER',
          style: TextStyle(
            color: Color(0xFFE94560),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Final Score: ${_gameWorld.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Wave Reached: ${_gameWorld.wave}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thanks for playing!',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'MAIN MENU',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _gameWorld.startGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
            ),
            child: const Text('PLAY AGAIN'),
          ),
        ],
      ),
    );
  }

  void _showPauseMenu() {
    _gameWorld.pauseGame();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'PAUSED',
          style: TextStyle(
            color: Color(0xFFE94560),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: ${_gameWorld.score}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Wave: ${_gameWorld.wave}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'QUIT',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _gameWorld.resumeGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('RESUME'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Initialize game world with screen size
          if (_gameWorld.starfield == null) {
            _gameWorld.initialize(
              Size(constraints.maxWidth, constraints.maxHeight),
            );
            // Auto-start after first frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _gameWorld.startGame();
            });
          }
          
          return RawKeyboardListener(
            focusNode: FocusNode(),
            autofocus: true,
            onKey: _handleKeyEvent,
            child: GestureDetector(
              onTapUp: (_) => _gameWorld.setFiring(false),
              onTapDown: (_) => _gameWorld.setFiring(true),
              onPanUpdate: (details) {
                // Touch-based movement
                final dy = details.delta.dy;
                _gameWorld.setMovement(
                  dy < -2,
                  dy > 2,
                );
              },
              onPanEnd: (_) => _gameWorld.setMovement(false, false),
              child: Stack(
                children: [
                  // Game canvas
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: GamePainter(_gameWorld),
                  ),
                  
                  // UI Overlay
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withAlpha(179),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Score
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'SCORE',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  _formatScore(_gameWorld.score),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            
                            // Wave
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'WAVE',
                                  style: TextStyle(
                                    color: Color(0xFFE94560),
                                    fontSize: 10,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  '${_gameWorld.wave}',
                                  style: const TextStyle(
                                    color: Color(0xFFE94560),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Health bar
                  Positioned(
                    bottom: 20,
                    left: 16,
                    child: SafeArea(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Color(0xFFE94560),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 100,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(128),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _gameWorld.health / 
                                _gameWorld.maxHealth.clamp(1, 100),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _getHealthColor(_gameWorld.healthPercent),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Lives
                  Positioned(
                    bottom: 20,
                    right: 16,
                    child: SafeArea(
                      child: Row(
                        children: List.generate(
                          _gameWorld.lives.clamp(0, 5),
                          (index) => const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.favorite,
                              color: Color(0xFF00D4FF),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Pause button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: SafeArea(
                      child: FloatingActionButton.small(
                        onPressed: _showPauseMenu,
                        backgroundColor: const Color(0xFFE94560),
                        child: const Icon(Icons.pause),
                      ),
                    ),
                  ),
                  
                  // Touch controls hint
                  if (_gameWorld.gameTime < 3)
                    Positioned(
                      bottom: 80,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: 1.0 - (_gameWorld.gameTime / 3).clamp(0, 1),
                          duration: const Duration(milliseconds: 100),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(179),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '👆 Drag to move',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '👇 Hold to shoot',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.keyW:
          _gameWorld.setMovement(
            true,
            false,
          );
          break;
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.keyS:
          _gameWorld.setMovement(
            false,
            true,
          );
          break;
        case LogicalKeyboardKey.space:
        case LogicalKeyboardKey.keyZ:
          _gameWorld.setFiring(true);
          break;
        case LogicalKeyboardKey.escape:
          _showPauseMenu();
          break;
      }
    } else if (event is RawKeyUpEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.keyW:
          _gameWorld.setMovement(false, false);
          break;
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.keyS:
          _gameWorld.setMovement(false, false);
          break;
        case LogicalKeyboardKey.space:
        case LogicalKeyboardKey.keyZ:
          _gameWorld.setFiring(false);
          break;
      }
    }
  }
  
  String _formatScore(int score) {
    return score.toString().padLeft(8, '0');
  }
  
  Color _getHealthColor(double percent) {
    if (percent > 0.6) return Colors.green;
    if (percent > 0.3) return Colors.orange;
    return const Color(0xFFE94560);
  }
}

/// Custom painter for rendering the game world
class GamePainter extends CustomPainter {
  final GameWorld gameWorld;
  
  GamePainter(this.gameWorld) : super(repaint: gameWorld);
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw starfield
    gameWorld.starfield?.render(canvas);
    
    // Draw all entities
    for (final entity in gameWorld.renderableEntities) {
      entity.render(canvas);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
