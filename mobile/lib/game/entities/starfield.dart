import 'dart:math';
import 'package:flutter/material.dart';
import 'game_entity.dart';

/// Background starfield for parallax scrolling effect
class Starfield {
  final int starCount;
  final Size screenSize;
  late List<Star> _stars;
  
  double _scrollSpeed = 100.0;
  
  Starfield({
    required this.starCount,
    required this.screenSize,
  }) {
    _stars = List.generate(starCount, (index) => Star.random(screenSize));
  }
  
  void setScrollSpeed(double speed) {
    _scrollSpeed = speed;
  }
  
  void update(double deltaTime, double totalTime) {
    for (final star in _stars) {
      star.update(deltaTime, totalTime, _scrollSpeed);
      
      // Wrap stars around screen
      if (star.x < 0) {
        star.x = screenSize.width + Random().nextDouble() * 50;
        star.y = Random().nextDouble() * screenSize.height;
      }
    }
  }
  
  void render(Canvas canvas) {
    // Draw deep space background
    final bgGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFF0D1117),
        const Color(0xFF1A1A2E),
        const Color(0xFF16213E),
      ],
    );
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, screenSize.width, screenSize.height),
      Paint()
        ..shader = bgGradient.createShader(
          Rect.fromLTWH(0, 0, screenSize.width, screenSize.height),
        ),
    );
    
    // Draw stars
    for (final star in _stars) {
      star.render(canvas);
    }
  }
}

/// Individual star in the starfield
class Star {
  double x;
  double y;
  double size;
  double brightness;
  double twinkleOffset;
  
  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.brightness,
    required this.twinkleOffset,
  });
  
  factory Star.random(Size screenSize) {
    final random = Random();
    return Star(
      x: random.nextDouble() * screenSize.width,
      y: random.nextDouble() * screenSize.height,
      size: 0.5 + random.nextDouble() * 1.5,
      brightness: 0.3 + random.nextDouble() * 0.7,
      twinkleOffset: random.nextDouble() * 2 * pi,
    );
  }
  
  void update(double deltaTime, double totalTime, double scrollSpeed) {
    // Move star based on parallax (smaller stars move slower)
    final parallaxFactor = 0.5 + size * 0.3;
    x -= scrollSpeed * parallaxFactor * deltaTime;
    
    // Twinkle effect
    brightness = 0.5 + 0.5 * sin(totalTime * 3 + twinkleOffset);
  }
  
  void render(Canvas canvas) {
    final alpha = (brightness * 255).round().clamp(0, 255);
    
    // Draw star
    canvas.drawCircle(
      Offset(x, y),
      size,
      Paint()
        ..color = Colors.white.withAlpha(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5),
    );
    
    // Draw glow for larger stars
    if (size > 1.2) {
      canvas.drawCircle(
        Offset(x, y),
        size * 2,
        Paint()
          ..color = Colors.white.withAlpha(alpha ~/ 4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }
}
