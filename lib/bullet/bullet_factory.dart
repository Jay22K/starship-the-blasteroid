import 'package:spaceship_game/bullet/bullet.dart';
import 'package:spaceship_game/bullet/bullet_build_context.dart';

class BulletFactory {
  BulletFactory._();

  static Bullet create(BulletBuildContext context) {
    Bullet result;

    /// collect all the Bullet definitions here
    switch (context.bulletType) {
      case BulletEnum.slowBullet:
        {
          if (context.speed != BulletBuildContext.defaultSpeed) {
            result = SlowBullet.fullInit(context.position, context.velocity,
                context.size, context.speed, context.health, context.damage);
          } else {
            result = SlowBullet(context.position, context.velocity);
          }
        }
        break;

      case BulletEnum.fastBullet:
        {
          if (context.speed != BulletBuildContext.defaultSpeed) {
            result = FastBullet.fullInit(context.position, context.velocity,
                context.size, context.speed, context.health, context.damage);
          } else {
            result = FastBullet(context.position, context.velocity);
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
