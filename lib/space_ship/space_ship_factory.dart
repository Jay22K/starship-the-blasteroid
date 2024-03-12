import 'package:spaceship_game/space_ship/space_ship_build_context.dart';
import 'package:spaceship_game/space_ship/spaceship.dart';

class SpaceShipFactory {
  SpaceShipFactory._();

  static SpaceShip create(SpaceShipBuildContext context) {
    SpaceShip result;

    /// collect all the Bullet definitions here
    switch (context.spaceShipType) {
      case SpaceShipEnum.simpleSpaceShip:
        {
          if (context.speed != SpaceShipBuildContext.defaultSpeed) {
            result = SimpleSpaceShip.fullInit(context.joystick, context.size,
                context.speed, context.health, context.damage);
          } else {
            result = SimpleSpaceShip(context.joystick);
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
