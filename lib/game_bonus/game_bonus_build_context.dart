import 'package:flame/components.dart';
import 'package:spaceship_game/game_bonus/game_bonus.dart';

class GameBonusBuildContext {
  static const double defaultSpeed = 0.0;
  static const int defaultHealth = 1;
  static const int defaultDamage = 1;
  static final Vector2 defaultVelocity = Vector2.zero();
  static final Vector2 defaultPosition = Vector2(-1, -1);
  static final Vector2 defaultSize = Vector2.zero();
  static final GameBonusEnum defaultGameBonusType = GameBonusEnum.values[0];
  static const int defaultTimeTriggerSeconds = 0;

  double speed = defaultSpeed;
  Vector2 velocity = defaultVelocity;
  Vector2 position = defaultPosition;
  Vector2 size = defaultSize;
  int health = defaultHealth;
  int damage = defaultDamage;
  GameBonusEnum gameBonusType = defaultGameBonusType;
  int timeTriggerSeconds = defaultTimeTriggerSeconds;

  GameBonusBuildContext();

  /// helper method for parsing out strings into corresponding enum values
  ///
  static GameBonusEnum gameBonusFromString(String value) {
    return GameBonusEnum.values.firstWhere(
        (e) => e.toString().split('.')[1].toUpperCase() == value.toUpperCase());
  }

  @override
  String toString() {
    return 'name: $gameBonusType , speed: $speed , position: $position , velocity: $velocity, trigger.time: $timeTriggerSeconds ';
  }
}
