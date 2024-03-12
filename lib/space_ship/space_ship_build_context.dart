import 'package:flame/components.dart';
import 'package:spaceship_game/space_ship/spaceship.dart';

class SpaceShipBuildContext {
  static const double defaultSpeed = 0.0;
  static const int defaultHealth = 1;
  static const int defaultDamage = 1;
  static final Vector2 defaultVelocity = Vector2.zero();
  static final Vector2 defaultPosition = Vector2(-1, -1);
  static final Vector2 defaultSize = Vector2.zero();
  static final SpaceShipEnum defaultSpaceShipType = SpaceShipEnum.values[0];

  /// helper method for parsing out strings into corresponding enum values
  ///
  static SpaceShipEnum spaceShipFromString(String value) {
    return SpaceShipEnum.values.firstWhere(
        (e) => e.toString().split('.')[1].toUpperCase() == value.toUpperCase());
  }

  double speed = defaultSpeed;
  Vector2 velocity = defaultVelocity;
  Vector2 position = defaultPosition;
  Vector2 size = defaultSize;
  int health = defaultHealth;
  int damage = defaultDamage;
  SpaceShipEnum spaceShipType = defaultSpaceShipType;
  late JoystickComponent joystick;

  SpaceShipBuildContext();

  @override

  /// We are defining our own stringify method so that we can see our
  /// values when debugging.
  ///
  String toString() {
    return 'name: $spaceShipType , speed: $speed , position: $position , velocity: $velocity';
  }
}
