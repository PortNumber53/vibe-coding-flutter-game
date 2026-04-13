import 'package:flutter/material.dart';
import 'game_entity.dart';

/// Bullet entity fired by the player
class Bullet extends GameEntity with Movable {
  static const double defaultSpeed = 800.0;
  static const Size defaultSize = Size(16, 4);
  
  final Paint _paint = Paint()
    ..color = const Color(0xFFFFEB3B)
    ..style = PaintingStyle.fill;
    
  final Paint _glowPaint = Paint()
    ..color = const Color(0xFFFFEB3B).withAlpha(128)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  Bullet({
    required Offset startPosition,
    required double direction, // 1.0 for right, -1.0 for left
    this.speed = defaultSpeed,
  }) : super(
    position: startPosition,
    size: defaultSize,
  ) {
    setVelocity(direction, 0);
  }

  @override
  void update(double deltaTime, double totalTime) {
    move(deltaTime);
    
    // Deactivate bullets that go off-screen
    if (position.dx > 1000 || position.dx < -100) {
      isActive = false;
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw bullet
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: position,
          width: size.width,
          height: size.height,
        ),
        const Radius.circular(2),
      ),
      _paint,
    );
    
    // Draw glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: position,
          width: size.width + 4,
          height: size.height + 4,
        ),
        const Radius.circular(3),
      ),
      _glowPaint,
    );
  }

  @override
  void die() {
    destroy();
  }
}

/// Enemy bullet entity
class EnemyBullet extends GameEntity with Movable {
  static const double defaultSpeed = 400.0;
  
  final Paint _paint = Paint()
    ..color = const Color(0xFFE94560)
    ..style = PaintingStyle.fill;

  EnemyBullet({
    required Offset startPosition,
    required Offset velocity,
    this.speed = defaultSpeed,
  }) : super(
    position: startPosition,
    size: const Size(8, 8),
  ) {
    // Normalize velocity
    final magnitude = velocity.distance;
    if (magnitude > 0) {
      setVelocity(velocity.dx / magnitude, velocity.dy / magnitude);
    }
  }

  @override
  void update(double deltaTime, double totalTime) {
    move(deltaTime);
    
    // Deactivate bullets that go off-screen
    if (position.dx > 1000 || position.dx < -100 ||
        position.dy > 1000 || position.dy < -100) {
      isActive = false;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      position,
      4,
      _paint,
    );
  }

  @override
  void die() {
    destroy();
  }
}
