import 'package:flame/components.dart';
import 'package:spaceship_game/asteroid/asteroid.dart';

/// This is a simple data holder for the context data when we create a new
/// Asteroid instance through the Factory method using the [AsteroidFactory]
///
/// We have a number of default values here as well in case callers do not
/// define all the entries.
class AsteroidBuildContext {
  static const double defaultSpeed = 0.0;
  static const int defaultHealth = 1;
  static const int defaultDamage = 1;
  static final Vector2 defaultVelocity = Vector2.zero();
  static final Vector2 defaultPosition = Vector2(-1, -1);
  static final Vector2 defaultSize = Vector2.zero();
  static final AsteroidType defaultAsteroidType = AsteroidType.values[0];
  static final Vector2 defaultMultiplier = Vector2.all(1.0);

  /// helper method for parsing out strings into corresponding enum values
  ///
  static AsteroidType asteroidFromString(String value) {
    return AsteroidType.values.firstWhere(
        (e) => e.toString().split('.')[1].toUpperCase() == value.toUpperCase());
  }

  double speed = defaultSpeed;
  Vector2 velocity = defaultVelocity;
  Vector2 position = defaultPosition;
  Vector2 size = defaultSize;
  int health = defaultHealth;
  int damage = defaultDamage;
  Vector2 multiplier = defaultMultiplier;
  AsteroidType asteroidType = defaultAsteroidType;

  AsteroidBuildContext();

  @override
  String toString() {
    return 'name: $asteroidType , speed: $speed , position: $position , velocity: $velocity, multiplier: $multiplier';
  }
}
