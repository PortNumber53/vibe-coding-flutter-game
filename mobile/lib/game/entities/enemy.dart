import 'dart:math';
import 'package:flutter/material.dart';
import 'game_entity.dart';

/// Base class for enemies
abstract class Enemy extends GameEntity with Movable, Damageable, Rotatable {
  int scoreValue = 100;
  double _spawnTime = 0.0;
  
  Enemy({
    required Offset startPosition,
    required Size size,
    required this.scoreValue,
  }) : super(position: startPosition, size: size) {
    speed = 100.0;
    maxHealth = 1;
    currentHealth = 1;
  }
  
  double get spawnTime => _spawnTime;
  
  @override
  void update(double deltaTime, double totalTime) {
    if (_spawnTime == 0) _spawnTime = totalTime;
    // Override in subclasses
  }
}

/// Basic enemy that moves in a simple pattern
class BasicEnemy extends Enemy {
  static const Size defaultSize = Size(40, 30);
  
  double _baseY = 0;
  double _waveAmplitude = 50.0;
  double _waveFrequency = 2.0;
  
  final Paint _bodyPaint = Paint()
    ..color = const Color(0xFFE94560)
    ..style = PaintingStyle.fill;
    
  final Paint _detailPaint = Paint()
    ..color = const Color(0xFF8B0000)
    ..style = PaintingStyle.fill;
    
  final Paint _eyePaint = Paint()
    ..color = const Color(0xFFFFFF00)
    ..style = PaintingStyle.fill;

  BasicEnemy({
    required Offset startPosition,
    this.scoreValue = 100,
  }) : super(
    startPosition: startPosition,
    size: defaultSize,
    scoreValue: scoreValue,
  ) {
    speed = 150.0;
    maxHealth = 1;
    currentHealth = 1;
    _baseY = startPosition.dy;
    setVelocity(-1.0, 0);
    _waveAmplitude = 30.0 + Random().nextDouble() * 40.0;
    _waveFrequency = 2.0 + Random().nextDouble() * 2.0;
  }

  @override
  void update(double deltaTime, double totalTime) {
    super.update(deltaTime, totalTime);
    
    // Move left
    position += Offset(-speed * deltaTime, 0);
    
    // Add sine wave vertical movement
    final waveOffset = sin(totalTime * _waveFrequency) * _waveAmplitude;
    position = Offset(position.dx, _baseY + waveOffset);
    
    // Rotation based on movement
    angle = cos(totalTime * _waveFrequency) * 0.2;
    
    // Destroy if off screen
    if (position.dx < -100) {
      isActive = false;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    
    // Draw enemy body (triangle pointing left)
    final path = Path();
    path.moveTo(-size.width * 0.4, 0); // Nose
    path.lineTo(size.width * 0.3, -size.height * 0.4); // Top rear
    path.lineTo(size.width * 0.4, 0); // Engine
    path.lineTo(size.width * 0.3, size.height * 0.4); // Bottom rear
    path.close();
    canvas.drawPath(path, _bodyPaint);
    
    // Draw internal detail
    final detailPath = Path();
    detailPath.moveTo(-size.width * 0.2, 0);
    detailPath.lineTo(size.width * 0.1, -size.height * 0.2);
    detailPath.lineTo(size.width * 0.1, size.height * 0.2);
    detailPath.close();
    canvas.drawPath(detailPath, _detailPaint);
    
    // Draw eye
    canvas.drawCircle(
      Offset(-size.width * 0.15, 0),
      5,
      _eyePaint,
    );
    canvas.drawCircle(
      Offset(-size.width * 0.13, -1),
      2,
      Paint()..color = Colors.black,
    );
    
    canvas.restore();
  }

  @override
  void die() {
    destroy();
  }
}

/// Heavy enemy that takes more hits
class HeavyEnemy extends Enemy {
  static const Size defaultSize = Size(60, 50);
  
  final Paint _bodyPaint = Paint()
    ..color = const Color(0xFF9C27B0)
    ..style = PaintingStyle.fill;
    
  final Paint _armorPaint = Paint()
    ..color = const Color(0xFF4A148C)
    ..style = PaintingStyle.fill;

  HeavyEnemy({
    required Offset startPosition,
    this.scoreValue = 300,
  }) : super(
    startPosition: startPosition,
    size: defaultSize,
    scoreValue: scoreValue,
  ) {
    speed = 80.0;
    maxHealth = 3;
    currentHealth = 3;
    setVelocity(-1.0, 0);
  }

  @override
  void update(double deltaTime, double totalTime) {
    super.update(deltaTime, totalTime);
    
    // Move left slowly
    position += Offset(-speed * deltaTime, 0);
    
    // Slight tilt based on movement
    angle = -0.1;
    
    // Destroy if off screen
    if (position.dx < -100) {
      isActive = false;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    
    // Draw armor plates
    canvas.drawRect(
      Rect.fromCenter(
        center: const Offset(0, -size.height * 0.2),
        width: size.width * 0.6,
        height: 6,
      ),
      _armorPaint,
    );
    
    canvas.drawRect(
      Rect.fromCenter(
        center: const Offset(0, size.height * 0.2),
        width: size.width * 0.6,
        height: 6,
      ),
      _armorPaint,
    );
    
    // Draw main body (hexagon-ish shape)
    final path = Path();
    path.moveTo(-size.width * 0.4, 0);
    path.lineTo(-size.width * 0.2, -size.height * 0.35);
    path.lineTo(size.width * 0.3, -size.height * 0.4);
    path.lineTo(size.width * 0.4, 0);
    path.lineTo(size.width * 0.3, size.height * 0.4);
    path.lineTo(-size.width * 0.2, size.height * 0.35);
    path.close();
    canvas.drawPath(path, _bodyPaint);
    
    // Draw core
    canvas.drawCircle(
      const Offset(0, 0),
      10,
      Paint()..color = const Color(0xFFE91E63),
    );
    
    // Health indicator (small bars at top)
    final barWidth = 8.0;
    final barSpacing = 10.0;
    for (int i = 0; i < maxHealth; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          -size.width * 0.3 + i * barSpacing,
          -size.height * 0.45,
          barWidth,
          4,
        ),
        Paint()..color = i < currentHealth ? Colors.green : Colors.grey,
      );
    }
    
    canvas.restore();
  }

  @override
  void die() {
    destroy();
  }
}

/// Fast enemy that moves quickly
class FastEnemy extends Enemy {
  static const Size defaultSize = Size(35, 25);
  
  double _baseY = 0;
  double _zigzagAmplitude = 100.0;
  double _zigzagFrequency = 3.0;
  
  final Paint _bodyPaint = Paint()
    ..color = const Color(0xFF00E676)
    ..style = PaintingStyle.fill;
    
  final Paint _accentPaint = Paint()
    ..color = const Color(0xFF00C853)
    ..style = PaintingStyle.fill;

  FastEnemy({
    required Offset startPosition,
    this.scoreValue = 200,
  }) : super(
    startPosition: startPosition,
    size: defaultSize,
    scoreValue: scoreValue,
  ) {
    speed = 300.0;
    maxHealth = 1;
    currentHealth = 1;
    _baseY = startPosition.dy;
    setVelocity(-1.0, 0);
    _zigzagAmplitude = 60.0 + Random().nextDouble() * 80.0;
  }

  @override
  void update(double deltaTime, double totalTime) {
    super.update(deltaTime, totalTime);
    
    // Fast movement
    position += Offset(-speed * deltaTime, 0);
    
    // Sharp zigzag pattern
    final zigzag = (totalTime * _zigzagFrequency).floor() % 2 == 0 ? 1 : -1;
    position = Offset(
      position.dx,
      _baseY + zigzag * _zigzagAmplitude,
    );
    
    // Bank based on direction
    angle = zigzag * 0.3;
    
    // Destroy if off screen
    if (position.dx < -100) {
      isActive = false;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    
    // Draw sleek body
    final path = Path();
    path.moveTo(-size.width * 0.45, 0);
    path.lineTo(size.width * 0.2, -size.height * 0.3);
    path.lineTo(size.width * 0.35, 0);
    path.lineTo(size.width * 0.2, size.height * 0.3);
    path.close();
    canvas.drawPath(path, _bodyPaint);
    
    // Draw accent stripe
    final stripe = Path();
    stripe.moveTo(-size.width * 0.2, -size.height * 0.1);
    stripe.lineTo(size.width * 0.1, -3);
    stripe.lineTo(size.width * 0.1, 3);
    stripe.lineTo(-size.width * 0.2, size.height * 0.1);
    stripe.close();
    canvas.drawPath(stripe, _accentPaint);
    
    // Draw engine trails
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.3,
        -size.height * 0.1,
        8 + Random().nextDouble() * 6,
        size.height * 0.2,
      ),
      Paint()..color = const Color(0xFF69F0AE).withAlpha(180),
    );
    
    canvas.restore();
  }

  @override
  void die() {
    destroy();
  }
}

/// Factory for creating enemies
class EnemyFactory {
  static Enemy spawnRandomEnemy({
    required double screenWidth,
    required double screenHeight,
    int difficulty = 1,
  }) {
    final random = Random();
    final y = 50.0 + random.nextDouble() * (screenHeight - 100);
    final x = screenWidth + 50.0;
    
    // Spawn probability based on difficulty
    final roll = random.nextDouble();
    
    if (difficulty >= 3 && roll < 0.15) {
      // 15% chance for heavy enemy at higher difficulty
      return HeavyEnemy(
        startPosition: Offset(x, y),
        scoreValue: 300 + (difficulty * 50),
      );
    } else if (difficulty >= 2 && roll < 0.35) {
      // 20% chance for fast enemy
      return FastEnemy(
        startPosition: Offset(x, y),
        scoreValue: 200 + (difficulty * 30),
      );
    } else {
      // 65% basic enemy
      return BasicEnemy(
        startPosition: Offset(x, y),
        scoreValue: 100 + (difficulty * 20),
      );
    }
  }
}
