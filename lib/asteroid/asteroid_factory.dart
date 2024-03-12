import 'package:spaceship_game/asteroid/asteroid.dart';
import 'package:spaceship_game/asteroid/asteroid_build_context.dart';

/// This is a Factory Method Design pattern example implementation for Asteroids
/// in our game.
///
/// The class will return an instance of the specific asteroid asked for based
/// on a valid asteroid type choice.
class AsteroidFactory {
  /// private constructor to prevent instantiation
  AsteroidFactory._();

  /// main factory method to create instances of Bullet children
  static Asteroid create(AsteroidBuildContext context) {
    Asteroid result;

    /// collect all the Asteroid definitions here
    switch (context.asteroidType) {
      case AsteroidType.smallAsteroid:
        {
          if (context.size != AsteroidBuildContext.defaultSize) {
            result = SmallAsteroid.fullInit(
                context.position,
                context.velocity,
                context.multiplier,
                context.size,
                context.speed,
                context.health,
                context.damage);
          } else {
            result = SmallAsteroid(context.position, context.velocity);
          }
        }
        break;

      case AsteroidType.mediumAsteroid:
        {
          if (context.size != AsteroidBuildContext.defaultSize) {
            result = MediumAsteroid.fullInit(
                context.position,
                context.velocity,
                context.multiplier,
                context.size,
                context.speed,
                context.health,
                context.damage);
          } else {
            result = MediumAsteroid(context.position, context.velocity);
          }
        }
        break;

      case AsteroidType.largeAsteroid:
        {
          if (context.size != AsteroidBuildContext.defaultSize) {
            result = LargeAsteroid.fullInit(context.position, context.velocity,
                context.size, context.speed, context.health, context.damage);
          } else {
            result = LargeAsteroid(context.position, context.velocity);
          }
        }
        break;
    }

    ///
    /// trigger any necessary behavior *before* the instance is handed to the
    /// caller.
    result.onCreate();

    return result;
  }
}
