import 'dart:async';
import 'package:flutter/scheduler.dart';

/// Callback function for game loop ticks
typedef GameLoopCallback = void Function(double deltaTime, double totalTime);

/// Event types for the game loop
enum GameLoopEvent {
  start,
  pause,
  resume,
  stop,
}

/// Manages the game loop using Flutter's Ticker for smooth 60fps updates.
/// Uses an event-driven architecture where widgets can subscribe to updates.
class GameLoop {
  Ticker? _ticker;
  final List<GameLoopCallback> _callbacks = [];
  final StreamController<GameLoopEvent> _eventController = StreamController<GameLoopEvent>.broadcast();
  
  Duration _lastFrameTime = Duration.zero;
  Duration _totalPausedTime = Duration.zero;
  Duration _pauseStartTime = Duration.zero;
  
  bool _isRunning = false;
  bool _isPaused = false;
  
  // Stream for game loop events
  Stream<GameLoopEvent> get events => _eventController.stream;
  
  /// Whether the game loop is currently running
  bool get isRunning => _isRunning;
  
  /// Whether the game loop is currently paused
  bool get isPaused => _isPaused;

  /// Starts the game loop
  void start() {
    if (_isRunning) return;
    
    _isRunning = true;
    _isPaused = false;
    _lastFrameTime = Duration.zero;
    _totalPausedTime = Duration.zero;
    
    _ticker = Ticker(_onTick);
    _ticker!.start();
    
    _eventController.add(GameLoopEvent.start);
  }

  /// Pauses the game loop
  void pause() {
    if (!_isRunning || _isPaused) return;
    
    _isPaused = true;
    _pauseStartTime = _ticker!.lastElapsedDuration ?? Duration.zero;
    _ticker?.stop();
    
    _eventController.add(GameLoopEvent.pause);
  }

  /// Resumes the game loop from pause
  void resume() {
    if (!_isRunning || !_isPaused) return;
    
    _isPaused = false;
    final currentTime = _ticker?.lastElapsedDuration ?? Duration.zero;
    _totalPausedTime += currentTime - _pauseStartTime;
    
    _ticker?.start();
    
    _eventController.add(GameLoopEvent.resume);
  }

  /// Stops the game loop
  void stop() {
    if (!_isRunning) return;
    
    _ticker?.dispose();
    _ticker = null;
    _isRunning = false;
    _isPaused = false;
    
    _eventController.add(GameLoopEvent.stop);
  }

  /// Add a callback to receive game loop updates
  void addCallback(GameLoopCallback callback) {
    _callbacks.add(callback);
  }

  /// Remove a callback from game loop updates
  void removeCallback(GameLoopCallback callback) {
    _callbacks.remove(callback);
  }

  /// Handle ticker updates
  void _onTick(Duration elapsed) {
    // Calculate delta time in seconds
    final actualElapsed = elapsed - _totalPausedTime;
    
    if (_lastFrameTime == Duration.zero) {
      _lastFrameTime = actualElapsed;
      return;
    }
    
    final delta = actualElapsed - _lastFrameTime;
    final deltaTime = delta.inMicroseconds / Duration.microsecondsPerSecond;
    final totalTime = actualElapsed.inMicroseconds / Duration.microsecondsPerSecond;
    
    _lastFrameTime = actualElapsed;
    
    // Notify all callbacks
    for (final callback in List<GameLoopCallback>.from(_callbacks)) {
      callback(deltaTime, totalTime);
    }
  }

  /// Dispose of the game loop and clean up resources
  void dispose() {
    stop();
    _eventController.close();
    _callbacks.clear();
  }
}
