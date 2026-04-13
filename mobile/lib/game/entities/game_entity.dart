import 'dart:math';
import 'package:flutter/material.dart';

/// Base class for all game entities
abstract class GameEntity {
 Offset position;
 Size size;
 bool isActive;
 bool isDestroyed;
 
 GameEntity({
 required this.position,
 required this.size,
 this.isActive = true,
 this.isDestroyed = false,
 });

 /// Update entity logic
 void update(double deltaTime, double totalTime);
 
 /// Render the entity
 void render(Canvas canvas);
 
 /// Get the bounding rectangle for collision detection
 Rect get hitBox => Rect.fromCenter(
 center: position,
 width: size.width,
 height: size.height,
 );
 
 /// Check if this entity collides with another
 bool collidesWith(GameEntity other) {
 return hitBox.overlaps(other.hitBox);
 }
 
 /// Mark entity for removal
 void destroy() {
 isDestroyed = true;
 isActive = false;
 }
 
 /// Get center position
 Offset get center => position;
 
 /// Get left edge
 double get left => position.dx - size.width / 2;
 
 /// Get right edge 
 double get right => position.dx + size.width / 2;
 
 /// Get top edge
 double get top => position.dy - size.height / 2;
 
 /// Get bottom edge
 double get bottom => position.dy + size.height / 2;
}

/// Mixin for entities that move
mixin Movable on GameEntity {
 Offset velocity = Offset.zero;
 double speed = 100.0;
 
 void move(double deltaTime) {
 position += velocity * speed * deltaTime;
 }
 
 void setVelocity(double vx, double vy) {
 velocity = Offset(vx, vy);
 }
}

/// Mixin for entities that rotate
mixin Rotatable on GameEntity {
 double angle = 0.0;
 double angularVelocity = 0.0;
 
 void rotate(double deltaTime) {
 angle += angularVelocity * deltaTime;
 }
}

/// Mixin for entities with health
mixin Damageable on GameEntity {
 int maxHealth = 1;
 int currentHealth = 1;
 
 void takeDamage(int damage) {
 if ((this as dynamic).isInvulnerable == true) return;
 currentHealth -= damage;
 if (currentHealth <= 0) {
 die();
 }
 }
 
 void heal(int amount) {
 currentHealth = (currentHealth + amount).clamp(0, maxHealth);
 }
 
 void die();
 
 double get healthPercent => currentHealth / maxHealth;
 bool get isDead => currentHealth <= 0;
}

/// Mixin for entities that can be invulnerable
mixin Invulnerable on GameEntity {
 bool isInvulnerable = false;
 double _invulnerabilityTime = 0.0;
 
 void startInvulnerability(double duration) {
 isInvulnerable = true;
 _invulnerabilityTime = duration;
 }
 
 void updateInvulnerability(double deltaTime) {
 if (isInvulnerable && _invulnerabilityTime > 0) {
 _invulnerabilityTime -= deltaTime;
 if (_invulnerabilityTime <= 0) {
 isInvulnerable = false;
 _invulnerabilityTime = 0;
 }
 }
 }
}
