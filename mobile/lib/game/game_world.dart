import 'dart:math';
import 'package:flutter/material.dart';
import 'engine/game_loop.dart';
import 'entities/game_entity.dart';
import 'entities/player_ship.dart';
import 'entities/bullet.dart';
import 'entities/enemy.dart';
import 'entities/particle.dart';
import 'entities/starfield.dart';

/// Game states
enum GameState {
  idle,
  playing,
  paused,
  gameOver,
}

/// Manages the game world, entities, and game state
class GameWorld extends ChangeNotifier {
  // Dependencies
  late final GameLoop _gameLoop;
  
  // Screen dimensions
  late Size _screenSize;
  
  // Game container
  GameState _state = GameState.idle;
  int _score = 0;
  int _wave = 1;
  double _gameTime = 0.0;
  
  // Entities
  PlayerShip? _player;
  final List<Bullet> _bullets = [];
  final List<Enemy> _enemies = [];
  final List<Particle> _particles = [];
  Starfield? _starfield;
  
  // Spawn system
  double _lastEnemySpawn = 0.0;
  double _spawnInterval = 2.0;
  int _difficulty = 1;
  
  // Input state
  bool _isUpPressed = false;
  bool _isDownPressed = false;
  bool _isFirePressed = false;
  
  // Getters
  GameState get state => _state;
  int get score => _score;
  int get wave => _wave;
  int get lives => _player?.lives ?? 0;
  int get health => _player?.currentHealth ?? 0;
  int get maxHealth => _player?.maxHealth ?? 1;
  double get gameTime => _gameTime;
  double get healthPercent {
    final max = maxHealth;
    if (max <= 0) return 0;
    return health / max;
  }
  
  List<GameEntity> get renderableEntities {
    final entities = <GameEntity>[];
    if (_player != null && _player!.isActive) entities.add(_player!);
    entities.addAll(_bullets.where((b) => b.isActive));
    entities.addAll(_enemies.where((e) => e.isActive));
    entities.addAll(_particles.where((p) => p.isActive));
    return entities;
  }
  
  GameLoop get gameLoop => _gameLoop;
  Starfield? get starfield => _starfield;
  
  // Callbacks
  VoidCallback? onGameOver;
  Function(int score)? onScoreChanged;

  GameWorld() {
    _gameLoop = GameLoop();
    _gameLoop.addCallback(_update);
  }
  
  /// Initialize the game world with screen dimensions
  void initialize(Size screenSize) {
    _screenSize = screenSize;
    _starfield = Starfield(
      starCount: 100,
      screenSize: screenSize,
    );
    _starfield!.setScrollSpeed(100.0);
  }
  
  /// Start a new game
  void startGame() {
    if (_screenSize == Size.zero) return;
    
    // Reset state
    _state = GameState.playing;
    _score = 0;
    _wave = 1;
    _gameTime = 0.0;
    _difficulty = 1;
    _lastEnemySpawn = 0.0;
    _spawnInterval = 2.0;
    
    // Clear entities
    _bullets.clear();
    _enemies.clear();
    _particles.clear();
    
    // Create player
    _player = PlayerShip(
      startPosition: Offset(_screenSize.width * 0.15, _screenSize.height / 2),
    );
    
    // Start game loop
    _gameLoop.start();
    
    notifyListeners();
  }
  
  /// Pause the game
  void pauseGame() {
    if (_state != GameState.playing) return;
    _state = GameState.paused;
    _gameLoop.pause();
    notifyListeners();
  }
  
  /// Resume the game
  void resumeGame() {
    if (_state != GameState.paused) return;
    _state = GameState.playing;
    _gameLoop.resume();
    notifyListeners();
  }
  
  /// End the game
  void endGame() {
    _state = GameState.gameOver;
    _gameLoop.stop();
    onGameOver?.call();
    notifyListeners();
  }
  
  /// Update game logic
  void _update(double deltaTime, double totalTime) {
    _gameTime = totalTime;
    
    // Update starfield
    _starfield?.update(deltaTime, totalTime);
    
    // Update player
    _updatePlayer(deltaTime, totalTime);
    
    // Update bullets
    _updateBullets(deltaTime, totalTime);
    
    // Update enemies
    _updateEnemies(deltaTime, totalTime);
    
    // Update particles
    _updateParticles(deltaTime, totalTime);
    
    // Spawn enemies
    _spawnEnemies(totalTime);
    
    // Check collisions
    _checkCollisions();
    
    // Clean up destroyed entities
    _cleanupEntities();
    
    // Check game over
    if (_player?.isDestroyed == true) {
      endGame();
    }
    
    notifyListeners();
  }
  
  void _updatePlayer(double deltaTime, double totalTime) {
    if (_player == null) return;
    
    _player!.isMovingUp = _isUpPressed;
    _player!.isMovingDown = _isDownPressed;
    _player!.update(deltaTime, totalTime);
    
    // Clamp player to screen
    _player!.position = Offset(
      _player!.position.dx.clamp(40, _screenSize.width - 40),
      _player!.position.dy.clamp(40, _screenSize.height - 40),
    );
    
    // Fire bullets
    if (_isFirePressed && _player!.tryFire(totalTime)) {
      _fireBullet(_player!.getBulletSpawnPosition());
    }
  }
  
  void _updateBullets(double deltaTime, double totalTime) {
    for (final bullet in _bullets) {
      bullet.update(deltaTime, totalTime);
    }
  }
  
  void _updateEnemies(double deltaTime, double totalTime) {
    for (final enemy in _enemies) {
      enemy.update(deltaTime, totalTime);
    }
  }
  
  void _updateParticles(double deltaTime, double totalTime) {
    for (final particle in _particles) {
      particle.update(deltaTime, totalTime);
    }
  }
  
  void _spawnEnemies(double totalTime) {
    if (totalTime - _lastEnemySpawn < _spawnInterval) return;
    
    _lastEnemySpawn = totalTime;
    
    // Spawn enemy
    final enemy = EnemyFactory.spawnRandomEnemy(
      screenWidth: _screenSize.width,
      screenHeight: _screenSize.height,
      difficulty: _difficulty,
    );
    _enemies.add(enemy);
    
    // Increase difficulty over time
    if (_gameTime > 30) {
      _difficulty = 2;
      _spawnInterval = 1.5;
    }
    if (_gameTime > 60) {
      _difficulty = 3;
      _spawnInterval = 1.0;
    }
    if (_gameTime > 90) {
      _difficulty = 4;
      _spawnInterval = 0.7;
    }
    
    // Increase score and wave
    if (_score > _wave * 1000) {
      _wave++;
    }
    
    // Adjust starfield speed based on game time
    _starfield?.setScrollSpeed(100.0 + _gameTime * 2);
  }
  
  void _fireBullet(Offset position) {
    _bullets.add(Bullet(
      startPosition: position,
      direction: 1.0,
    ));
  }
  
  void _checkCollisions() {
    if (_player == null) return;
    
    // Check bullet-enemy collisions
    for (final bullet in _bullets) {
      if (!bullet.isActive) continue;
      
      for (final enemy in _enemies) {
        if (!enemy.isActive) continue;
        
        if (bullet.collidesWith(enemy)) {
          bullet.isActive = false;
          enemy.takeDamage(1);
          
          if (enemy.isDead) {
            _addExplosion(enemy.position, enemy.size.width);
            _addScore(enemy.scoreValue);
          }
          
          break;
        }
      }
    }
    
    // Check player-enemy collisions
    for (final enemy in _enemies) {
      if (!enemy.isActive) continue;
      
      if (_player!.collidesWith(enemy)) {
        _player!.takeDamage(1);
        enemy.takeDamage(10);
        _addExplosion(enemy.position, enemy.size.width);
        if (enemy.isDead) {
          _addScore(enemy.scoreValue ~/ 2);
        }
      }
      
      // Check if enemy passed player (lose points)
      if (enemy.right < _player!.left && enemy.isActive) {
        enemy.isActive = false;
        _addScore(-50);
      }
    }
  }
  
  void _addExplosion(Offset position, double size) {
    _particles.addAll(ParticleExplosion.createExplosion(
      position: position,
      particleCount: (8 + size ~/ 5).clamp(8, 20),
      baseColor: const Color(0xFFFF6B35),
    ));
  }
  
  void _addScore(int points) {
    _score = (_score + points).clamp(0, 999999);
    onScoreChanged?.call(_score);
  }
  
  void _cleanupEntities() {
    _bullets.removeWhere((b) => !b.isActive);
    _enemies.removeWhere((e) => !e.isActive || e.isDestroyed);
    _particles.removeWhere((p) => !p.isActive);
  }
  
  // Input handlers
  void setMovement(bool up, bool down) {
    _isUpPressed = up;
    _isDownPressed = down;
  }
  
  void setFiring(bool firing) {
    _isFirePressed = firing;
  }
  
  void dispose() {
    _gameLoop.dispose();
    super.dispose();
  }
}
