import 'dart:math';
import 'package:flutter/material.dart';
import 'game_entity.dart';

/// Particle effect for explosions and visual effects
class Particle extends GameEntity with Movable {
  final double lifetime;
  final Color color;
  final double startSize;
  final double endSize;
  final double fadeRate;
  
  double _age = 0.0;
  double _alpha = 1.0;
  
  late final Paint _paint;

  Particle({
    required Offset startPosition,
    required this.lifetime,
    required this.color,
    double speed = 0,
    Offset velocity = Offset.zero,
    this.startSize = 4.0,
    this.endSize = 0.0,
    this.fadeRate = 1.0,
  }) : super(
    position: startPosition,
    size: Size(startSize, startSize),
  ) {
    this.speed = speed;
    this.velocity = velocity;
    _paint = Paint()..color = color;
  }

  @override
  void update(double deltaTime, double totalTime) {
    _age += deltaTime;
    
    if (_age >= lifetime) {
      isActive = false;
      return;
    }
    
    // Move
    move(deltaTime);
    
    // Fade out
    _alpha = 1.0 - (_age / lifetime) * fadeRate;
    _alpha = _alpha.clamp(0.0, 1.0);
    
    // Shrink
    final progress = _age / lifetime;
    final currentSize = startSize + (endSize - startSize) * progress;
    size = Size(currentSize, currentSize);
  }

  @override
  void render(Canvas canvas) {
    if (_alpha <= 0) return;
    
    _paint.color = color.withAlpha((255 * _alpha).round());
    
    canvas.drawCircle(
      position,
      size.width / 2,
      _paint,
    );
  }

  Particle clone() {
    return Particle(
      startPosition: position,
      lifetime: lifetime,
      color: color,
      speed: speed,
      velocity: velocity,
      startSize: startSize,
      endSize: endSize,
      fadeRate: fadeRate,
    );
  }
}

/// Creates explosion effects
class ParticleExplosion {
  static List<Particle> createExplosion({
    required Offset position,
    int particleCount = 12,
    double minSpeed = 50.0,
    double maxSpeed = 150.0,
    double lifetime = 0.5,
    Color? baseColor,
    double spread = 0.8,
  }) {
    final random = Random();
    final particles = <Particle>[];
    
    final colors = [
      baseColor ?? const Color(0xFFFF6B35),
      const Color(0xFFFFEB3B),
      const Color(0xFFF44336),
      Colors.white,
    ];
    
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi + random.nextDouble() * spread - spread/2;
      final speed = minSpeed + random.nextDouble() * (maxSpeed - minSpeed);
      
      particles.add(Particle(
        startPosition: position,
        lifetime: lifetime + random.nextDouble() * 0.3,
        color: colors[random.nextInt(colors.length)],
        speed: speed,
        velocity: Offset(cos(angle), sin(angle)),
        startSize: 3.0 + random.nextDouble() * 4.0,
        endSize: 0.5,
        fadeRate: 0.9,
      ));
    }
    
    return particles;
  }
  
  static List<Particle> createEngineTrail({
    required Offset position,
    required Offset direction,
  }) {
    final random = Random();
    return [
      Particle(
        startPosition: position + Offset(
          random.nextDouble() * 4 - 2,
          random.nextDouble() * 4 - 2,
        ),
        lifetime: 0.2 + random.nextDouble() * 0.2,
        color: const Color(0xFFFF6B35).withAlpha(180),
        speed: 30.0 + random.nextDouble() * 30.0,
        velocity: direction,
        startSize: 4.0 + random.nextDouble() * 2.0,
        endSize: 1.0,
        fadeRate: 0.7,
      ),
    ];
  }
}
