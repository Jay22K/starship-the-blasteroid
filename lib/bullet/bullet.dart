import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:spaceship_game/game.dart';

import '../command/command.dart';
import '../other/utils.dart';

enum BulletEnum {
  slowBullet,
  fastBullet,
}

abstract class Bullet extends PositionComponent
    with HasGameRef<SpaceshipGame>, CollisionCallbacks {
  static const double defaultSpeed = 100.00;
  static const int defaultDamage = 1;
  static const int defaultHealth = 1;
  static final Vector2 defaultSize = Vector2.all(6.0);

  // velocity vector for the bullet.
  late Vector2 _velocity;

  // speed of the bullet
  late final double _speed;

  // health of the bullet
  late final int? _health;

  // damage that the bullet does
  late final int? _damage;

  //
  // default constructor with default values
  Bullet(Vector2 position, Vector2 velocity)
      : _velocity = velocity.normalized(),
        _speed = defaultSpeed,
        _health = defaultHealth,
        _damage = defaultDamage,
        super(
          size: defaultSize,
          position: position,
          anchor: Anchor.center,
        );

  //
  // named constructor
  Bullet.fullInit(Vector2 position, Vector2 velocity,
      {Vector2? size, double? speed, int? health, int? damage})
      : _velocity = velocity.normalized(),
        _speed = speed ?? defaultSpeed,
        _health = health ?? defaultHealth,
        _damage = damage ?? defaultDamage,
        super(
          size: size,
          position: position,
          anchor: Anchor.center,
        );

  ///////////////////////////////////////////////////////
  // getters
  //
  int? get getDamage {
    return _damage;
  }

  int? get getHealth {
    return _health;
  }

  ////////////////////////////////////////////////////////
  // Overrides
  //
  @override
  void update(double dt) {
    _onOutOfBounds(position);
  }

  void onCreate() {
    add(RectangleHitbox());
  }

  void onDestroy();

  void onHit(Component other);

  void _onOutOfBounds(Vector2 position) {
    if (Utils.isPositionOutOfBounds(gameRef.size, position)) {
      BulletDestroyCommand(this).addToController(gameRef.controller);
    }
  }
}

/// This class creates a fast bullet implementation of the [Bullet] contract and
/// renders the bullet as a simple green square.
/// Speed has been defaulted to 150 p/s but can be changed through the
/// constructor. It is set with a damage of 1 which is the lowest damage and
/// with health of 1 which means that it will be destroyed on impact since it
/// is also the lowest health you can have.
///
class FastBullet extends Bullet {
  static const double defaultSpeed = 175.00;
  static final Vector2 defaultSize = Vector2.all(6.00);
  // color of the bullet
  static final _paint = Paint()..color = Colors.green;

  FastBullet(Vector2 position, Vector2 velocity)
      : super.fullInit(position, velocity,
            size: defaultSize,
            speed: defaultSpeed,
            health: Bullet.defaultHealth,
            damage: Bullet.defaultDamage);

  //
  // named constructor
  FastBullet.fullInit(Vector2 position, Vector2 velocity, Vector2? size,
      double? speed, int? health, int? damage)
      : super.fullInit(position, velocity,
            size: size, speed: speed, health: health, damage: damage);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _velocity = (_velocity)..scaleTo(_speed);
  }

  @override
  void update(double dt) {
    position.add(_velocity * dt);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _paint);
  }

  @override
  void onDestroy() {}

  @override
  void onHit(Component other) {}
}

/// This class creates a slow bullet implementation of the [Bullet] contract and
/// renders the bullet as a simple red filled-in circle.
/// Speed has been defaulted to 50 p/s but can be changed through the
/// constructor. It is set with a damage of 1 which is the lowest damage and
/// with health of 1 which means that it will be destroyed on impact since it
/// is also the lowest health you can have.
///
class SlowBullet extends Bullet {
  static const double defaultSpeed = 50.00;
  static final Vector2 defaultSize = Vector2.all(6.0);
  // color of the bullet
  static final _paint = Paint()..color = Colors.red;

  SlowBullet(Vector2 position, Vector2 velocity)
      : super.fullInit(position, velocity,
            size: defaultSize,
            speed: defaultSpeed,
            health: Bullet.defaultHealth,
            damage: Bullet.defaultDamage);

  //
  // named constructor
  SlowBullet.fullInit(Vector2 position, Vector2 velocity, Vector2? size,
      double? speed, int? health, int? damage)
      : super.fullInit(position, velocity,
            size: size, speed: speed, health: health, damage: damage);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // _velocity is a unit vector so we need to make it account for the actual
    // speed.
    _velocity = (_velocity)..scaleTo(_speed);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, _paint);
    //canvas.drawCircle(size.toRect(), _paint);
  }

  @override
  void update(double dt) {
    position.add(_velocity * dt);
    super.update(dt);
  }

  @override
  void onDestroy() {}

  @override
  void onHit(Component other) {}
}
