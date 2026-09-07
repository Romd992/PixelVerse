import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../systems/farming_system.dart';

/// Manages the in-game time: day/night cycle, dates, seasons, weather.
class TimeSystem {
  // One in-game day = 8 real minutes = 480 seconds
  // 18 hours of gameplay (6AM to midnight) = 480 seconds
  // So 1 in-game hour = 480/18 = 26.67 real seconds
  static const double secondsPerInGameDay = 480.0;
  static const double hoursPerDay = 24.0;
  static const double startTime = 6.0; // 6 AM
  static const double bedtime = 24.0; // midnight

  final GameState gameState;
  final Random _rand = Random();

  // Callbacks
  void Function()? onDayStart;
  void Function()? onBedtime;
  void Function()? onSeasonChange;

  TimeSystem(this.gameState);

  /// Update time based on real delta time.
  void update(double dt) {
    // Advance time
    final hoursPerSecond = hoursPerDay / secondsPerInGameDay;
    gameState.timeOfDay += dt * hoursPerSecond;

    // Check for bedtime
    if (gameState.timeOfDay >= bedtime) {
      gameState.timeOfDay = bedtime;
      onBedtime?.call();
    }
  }

  /// Advance to the next day (called after sleeping).
  void advanceDay() {
    gameState.day++;
    gameState.timeOfDay = startTime;
    gameState.energy = gameState.maxEnergy;

    // Advance crops
    FarmingSystem.advanceDay(gameState);

    // Check for season change (28 days per season)
    if (gameState.day > 28) {
      gameState.day = 1;
      final nextIndex = (gameState.season.index + 1) % Season.values.length;
      gameState.season = Season.values[nextIndex];
      if (nextIndex == 0) {
        gameState.year++;
      }
      onSeasonChange?.call();
    }

    // Roll weather for the new day
    _rollWeather();

    // Respawn destroyed objects (trees/rocks regrow)
    gameState.destroyedObjects.clear();

    onDayStart?.call();
  }

  /// Roll weather for a new day.
  void _rollWeather() {
    // Higher rain chance in spring and autumn
    double rainChance = 0.2;
    switch (gameState.season) {
      case Season.spring:
        rainChance = 0.35;
        break;
      case Season.summer:
        rainChance = 0.15;
        break;
      case Season.autumn:
        rainChance = 0.3;
        break;
      case Season.winter:
        rainChance = 0.25;
        break;
    }
    gameState.weather =
        _rand.nextDouble() < rainChance ? Weather.rainy : Weather.sunny;
  }

  /// Get the darkness overlay alpha (0-1) for night rendering.
  double get darknessAlpha => gameState.darkness;

  /// Check if it's currently nighttime.
  bool get isNight => gameState.timeOfDay >= 19 || gameState.timeOfDay < 6;

  /// Check if shops are open (9 AM - 9 PM).
  bool get shopsOpen =>
      gameState.timeOfDay >= 9 && gameState.timeOfDay < 21;

  /// Format the current date as a string.
  String get dateString =>
      'Day ${gameState.day} of ${gameState.seasonName}, Year ${gameState.year}';

  /// Get the ambient color filter based on time of day.
  /// Morning/evening = warm orange, night = cool blue, midday = transparent.
  Color getFilterColor() {
    final t = gameState.timeOfDay;

    // Dawn (6-8 AM): warm orange fade-in then out
    if (t >= 6 && t < 8) {
      final a = (t - 6) / 2; // 0->1
      final alpha = sin(a * pi) * 0.15;
      return const Color(0xFFFF9933).withOpacity(alpha);
    }

    // Golden hour evening (17-19): warm orange
    if (t >= 17 && t < 19.5) {
      final a = (t - 17) / 2.5;
      final alpha = sin(a * pi) * 0.18;
      return const Color(0xFFFF6633).withOpacity(alpha);
    }

    // Night (19.5-5): cool blue tint
    if (t >= 19.5 || t < 5) {
      return const Color(0xFF1a237e).withOpacity(0.12);
    }

    // Midday: no filter
    return Colors.transparent;
  }
}
