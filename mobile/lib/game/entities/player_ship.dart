import 'dart:math';
import 'package:flutter/material.dart';
import 'game_entity.dart';

/// Player ship entity for horizontal shoot 'em up
class PlayerShip extends GameEntity with Movable, Damageable, Rotatable {
  // Ship configuration
  static const double defaultSpeed = 300.0;
  static const double fireRate = 0.15; // seconds between shots
  static const double bulletSpeed = 600.0;
  
  // State
  double _lastFireTime = 0.0;
  int _lives = 3;
  bool isMovingUp = false;
  bool isMovingDown = false;
  bool isFiring = false;
  
  // Visual
  final Paint _bodyPaint = Paint()
    ..color = const Color(0xFF00D4FF)
    ..style = PaintingStyle.fill;
    
  final Paint _enginePaint = Paint()
    ..color = const Color(0xFFFF6B35)
    ..style = PaintingStyle.fill;
    
  final Paint _glowPaint = Paint()
    ..color = const Color(0xFF00D4FF).withAlpha(77)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  int get lives => _lives;
  
  PlayerShip({
    required Offset startPosition,
  }) : super(
    position: startPosition,
    size: const Size(48, 32),
  ) {
    speed = defaultSpeed;
    maxHealth = 3;
    currentHealth = 3;
  }

  @override
  void update(double deltaTime, double totalTime) {
    // Calculate velocity based on input
    double vy = 0;
    if (isMovingUp) vy -= 1;
    if (isMovingDown) vy += 1;
    
    // Normalize vertical movement
    setVelocity(0, vy);
    
    // Move the ship
    move(deltaTime);
    
    // Slight bobbing animation
    angle = sin(totalTime * 3) * 0.1;
    
    // Handle firing
    if (isFiring && totalTime - _lastFireTime >= fireRate) {
      _lastFireTime = totalTime;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    
    // Draw engine glow
    final glowPath = Path();
    glowPath.moveTo(-size.width * 0.6, 0);
    glowPath.lineTo(-size.width * 0.9, -5);
    glowPath.lineTo(-size.width * 1.1, 0);
    glowPath.lineTo(-size.width * 0.9, 5);
    glowPath.close();
    canvas.drawPath(glowPath, _enginePaint);
    
    // Draw ship body (triangle pointing right)
    final path = Path();
    path.moveTo(size.width * 0.5, 0); // Nose
    path.lineTo(-size.width * 0.25, -size.height * 0.4); // Top rear
    path.lineTo(-size.width * 0.5, 0); // Engine center
    path.lineTo(-size.width * 0.25, size.height * 0.4); // Bottom rear
    path.close();
    canvas.drawPath(path, _bodyPaint);
    
    // Draw cockpit
    final cockpitPaint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.1, 0),
      6,
      cockpitPaint,
    );
    
    // Draw wings
    final wingPaint = Paint()
      ..color = const Color(0xFF0099CC)
      ..style = PaintingStyle.fill;
    
    // Top wing
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(-size.width * 0.1, -size.height * 0.3),
        width: size.width * 0.3,
        height: 4,
      ),
      wingPaint,
    );
    
    // Bottom wing
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(-size.width * 0.1, size.height * 0.3),
        width: size.width * 0.3,
        height: 4,
      ),
      wingPaint,
    );
    
    // Draw glow effect
    canvas.drawPath(path, _glowPaint);
    
    canvas.restore();
  }

  @override
  void die() {
    _lives--;
    if (_lives <= 0) {
      destroy();
    } else {
      // Respawn invulnerable
      currentHealth = maxHealth;
      isInvulnerable = true;
      Future.delayed(const Duration(seconds: 2), () {
        isInvulnerable = false;
      });
    }
  }
  
  /// Try to fire a bullet - returns true if bullet was fired
  bool tryFire(double totalTime) {
    if (totalTime - _lastFireTime >= fireRate) {
      _lastFireTime = totalTime;
      return true;
    }
    return false;
  }
  
  /// Get the position where bullets should spawn
  Offset getBulletSpawnPosition() {
    return Offset(right, position.dy);
  }
  
  void moveUp(bool active) => isMovingUp = active;
  void moveDown(bool active) => isMovingDown = active;
  void startFiring() => isFiring = true;
  void stopFiring() => isFiring = false;
}
