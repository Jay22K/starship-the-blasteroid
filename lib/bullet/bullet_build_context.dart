import 'package:flame/components.dart';
import 'package:spaceship_game/bullet/bullet.dart';

class BulletBuildContext {
  static const double defaultSpeed = 0.0;
  static const int defaultHealth = 1;
  static const int defaultDamage = 1;
  static final Vector2 defaultVelocity = Vector2.zero();
  static final Vector2 defaultPosition = Vector2(-1, -1);
  static final Vector2 defaultSize = Vector2.zero();
  static final BulletEnum defaultBulletType = BulletEnum.values[0];

  double speed = defaultSpeed;
  Vector2 velocity = defaultVelocity;
  Vector2 position = defaultPosition;
  Vector2 size = defaultSize;
  int health = defaultHealth;
  int damage = defaultDamage;
  BulletEnum bulletType = defaultBulletType;

  BulletBuildContext();
}
