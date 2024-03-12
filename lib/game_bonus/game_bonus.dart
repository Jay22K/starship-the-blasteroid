import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:spaceship_game/game.dart';
import 'package:spaceship_game/other/utils.dart';
import 'package:spaceship_game/space_ship/spaceship.dart';

import '../bullet/bullet.dart';
import '../command/command.dart';

enum GameBonusEnum {
  ufoBonus,
}

abstract class GameBonus extends PositionComponent
    with CollisionCallbacks, HasGameRef<SpaceshipGame> {
  static const double defaultSpeed = 100.00;
  static const int defaultDamage = 1;
  static const int defaultHealth = 1;
  static final defaultSize = Vector2.all(5.0);

  // velocity vector for the asteroid.
  late Vector2 _velocity;

  // speed of the asteroid
  late final double _speed;

  // health of the asteroid
  late final int? _health;

  // damage that the asteroid does
  late final int? _damage;

  // trigger time in seconds
  late final int _triggerTimeSeconds;

  //
  // default constructor with default values
  GameBonus(
    Vector2 position,
    Vector2 velocity,
    int triggerTimeSeconds,
  )   : _velocity = velocity.normalized(),
        _speed = defaultSpeed,
        _health = defaultHealth,
        _damage = defaultDamage,
        _triggerTimeSeconds = triggerTimeSeconds,
        super(
          size: defaultSize,
          position: position,
          anchor: Anchor.center,
        );

  //
  // named constructor
  GameBonus.fullInit(Vector2 position, Vector2 velocity, int triggerTimeSeconds,
      {Vector2? size, double? speed, int? health, int? damage})
      : _velocity = velocity.normalized(),
        _speed = speed ?? defaultSpeed,
        _health = health ?? defaultHealth,
        _damage = damage ?? defaultDamage,
        _triggerTimeSeconds = triggerTimeSeconds,
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

  int? get getTriggerTime {
    return _triggerTimeSeconds;
  }

  ////////////////////////////////////////////////////////
  // business methods
  //

  //
  // Called when the asteroid has been created.
  void onCreate();

  //
  // Called when the asteroid is being destroyed.
  void onDestroy();

  //
  // Called when the asteroid has been hit. The ‘other’ is what the asteroid
  // hit, or was hit by.
  void onHit(PositionComponent other);

  ////////////////////////////////////////////////////////
  // Overrides
  //
  @override
  void update(double dt) {
    _onOutOfBounds(position);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bullet) {
      BulletCollisionCommand(other, this).addToController(gameRef.controller);
      GameBonusCollisionCommand(this, other)
          .addToController(gameRef.controller);
    }

    if (other is SpaceShip) {
      PlayerCollisionCommand(other, this).addToController(gameRef.controller);
    }

    super.onCollision(intersectionPoints, other);
  }

  ////////////////////////////////////////////////////////////
  // Helper methods
  //

  void _onOutOfBounds(Vector2 position) {
    if (Utils.isPositionOutOfBounds(gameRef.size, position)) {
      GameBonusDestroyCommand(this).addToController(gameRef.controller);
      //FlameAudio.audioCache.play('missile_hit.wav');
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
class UFOGameBonus extends GameBonus {
  static final Vector2 defaultSize = Vector2(100.0, 20.0);
  // color of the asteroid
  static final _paint = Paint()..color = Colors.white;

  UFOGameBonus(
    Vector2 position,
    Vector2 velocity,
    int triggerTimeSeconds,
  ) : super.fullInit(position, velocity, triggerTimeSeconds,
            size: defaultSize,
            speed: GameBonus.defaultSpeed,
            health: GameBonus.defaultHealth,
            damage: GameBonus.defaultDamage) {
    add(RectangleHitbox());
  }

  //
  // named constructor
  UFOGameBonus.fullInit(Vector2 position, Vector2 velocity, Vector2 size,
      int triggerTimeSeconds, double? speed, int? health, int? damage)
      : super.fullInit(position, velocity, triggerTimeSeconds,
            size: size, speed: speed, health: health, damage: damage) {
    add(RectangleHitbox());
  }

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
    canvas.drawRect(size.toRect(), _paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(_velocity * dt);
  }

  @override
  void onCreate() {}

  @override
  void onDestroy() {}

  @override
  void onHit(PositionComponent other) {}
}
