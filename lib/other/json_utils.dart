import 'dart:convert';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:spaceship_game/asteroid/asteroid_build_context.dart';
import 'package:spaceship_game/controller.dart';
import 'package:spaceship_game/game_bonus/game_bonus_build_context.dart';

class JSONUtils {
 /// Get game information
  static dynamic readJSONInitData() async {
    final String response =
        await rootBundle.loadString('assets/game_config.json');
    final data = await json.decode(response);

    return data;
  }

/// Get level data from JSON
  static List<GameLevel> extractGameLevels(dynamic data) {
    List<GameLevel> result = List.empty(growable: true);

    List jsonDataLevels = [];
    jsonDataLevels = data["game_data"]["levels"];

    for (var level in jsonDataLevels) {
      GameLevel gameLevel = GameLevel();
      List<AsteroidBuildContext> asteroidContextList =
          _buildAsteroidData(level);
      List<GameBonusBuildContext> gameBonusContextList =
          _buildGameBonusData(level);
      gameLevel
        ..asteroidConfig = asteroidContextList
        ..gameBonusConfig = gameBonusContextList;
      gameLevel.init();
      result.add(gameLevel);
    }

    return result;
  }

  static Vector2 extractBaseGameResolution(dynamic data) {
    Vector2 result = Vector2.zero();
    Map jsonDataResolution = {};

    jsonDataResolution = data["game_data"]["resolution"];
    result = Vector2(
        jsonDataResolution["x"].toDouble(), jsonDataResolution["y"].toDouble());

    return result;
  }

/// Get meteorite data from JSON [AsteroidBuildContext]
  static List<AsteroidBuildContext> _buildAsteroidData(Map data) {
    List<AsteroidBuildContext> result = List.empty(growable: true);

    for (final element in data['asteroids']) {
      AsteroidBuildContext asteroid = AsteroidBuildContext();
      asteroid.asteroidType =
          AsteroidBuildContext.asteroidFromString(element['name']);

      asteroid.position = Vector2(
          element['position.x'].toDouble(), element['position.y'].toDouble());
      asteroid.velocity = Vector2(
          element['velocity.x'].toDouble(), element['velocity.y'].toDouble());

      result.add(asteroid);
    }

    return result;
  }
  
/// Get bonus information from JSON [GameBonusBuildContext]
  static List<GameBonusBuildContext> _buildGameBonusData(Map data) {
    List<GameBonusBuildContext> result = List.empty(growable: true);

    ///
    /// precondition
    ///
    /// check that the actual element exists in the JSON
    if (data['gameBonus'] == null) {
      return result;
    }

    for (final element in data['gameBonus']) {
      GameBonusBuildContext gameBonus = GameBonusBuildContext();
      gameBonus.gameBonusType =
          GameBonusBuildContext.gameBonusFromString(element['name']);
      gameBonus.position = Vector2(
          element['position.x'].toDouble(), element['position.y'].toDouble());
      gameBonus.velocity = Vector2(
          element['velocity.x'].toDouble(), element['velocity.y'].toDouble());
      gameBonus.timeTriggerSeconds = element['trigger.time.seconds'].toInt();

      result.add(gameBonus);
    }

    return result;
  }
}
