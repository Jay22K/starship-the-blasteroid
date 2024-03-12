import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:spaceship_game/game.dart';

import '../bullet/bullet.dart';
import '../other/utils.dart';

enum SpaceShipEnum { simpleSpaceShip }

abstract class SpaceShip extends SpriteComponent
    with HasGameRef<SpaceshipGame>, CollisionCallbacks {
  // default values
  static const double defaultSpeed = 100.00;
  static const double defaultMaxSpeed = 300.00;
  static const int defaultDamage = 1;
  static const int defaultHealth = 1;
  static final defaultSize = Vector2.all(5.0);

  // speed of the asteroid
  late double _speed;

  // health of the asteroid
  late final int? _health;

  // damage that the asteroid does
  late final int? _damage;


  /// Pixels/s
  late final double _maxSpeed = defaultMaxSpeed;

  /// current bullet type
  final BulletEnum _currentBulletType = BulletEnum.fastBullet;

  /// Single pixel at the location of the tip of the spaceship
  /// We use it to quickly calculate the position of the rotated nose of the
  /// ship so we can get the position of where the bullets are shooting from.
  /// We make it transparent so it is not visible at all.
  static final _paint = Paint()..color = Colors.transparent;

  /// Muzzle pixel for shooting
  final RectangleComponent _muzzleComponent =
      RectangleComponent(size: Vector2(1, 1), paint: _paint);

  late final JoystickComponent _joystick;

  //
  // default constructor with default values
  SpaceShip(JoystickComponent joystick)
      : _health = defaultHealth,
        _damage = defaultDamage,
        _joystick = joystick,
        super(
          size: defaultSize,
          anchor: Anchor.center,
        );

  //
  // named constructor
  SpaceShip.fullInit(JoystickComponent joystick,
      {Vector2? size, double? speed, int? health, int? damage})
      : _joystick = joystick,
        _speed = speed ?? defaultSpeed,
        _health = health ?? defaultHealth,
        _damage = damage ?? defaultDamage,
        super(
          size: size,
          anchor: Anchor.center,
        );

  ///////////////////////////////////////////////////////
  // getters
  //
  BulletEnum get getBulletType {
    return _currentBulletType;
  }

  RectangleComponent get getMuzzleComponent {
    return _muzzleComponent;
  }

  void onCreate() {
    anchor = Anchor.center;

    // Set the volume of the spaceship
    size = Vector2.all(60.0);

    //Set the appearance and appearance of the spacecraft
    add(RectangleHitbox());
  }

  void onDestroy();

  //
  // Called when the Bullet has been hit. The ‘other’ is what the bullet hit, or was hit by.
  void onHit(PositionComponent other);

  Vector2 getNextPosition() {
    return Utils.wrapPosition(gameRef.size, position);
  }
}

class SimpleSpaceShip extends SpaceShip {
  static const double defaultSpeed = 300.00;
  static final Vector2 defaultSize = Vector2.all(2.00);

  SimpleSpaceShip( JoystickComponent joystick)
      : super.fullInit(joystick,
            size: defaultSize,
            speed: defaultSpeed,
            health: SpaceShip.defaultHealth,
            damage: SpaceShip.defaultDamage);

  //
  // named constructor
  SimpleSpaceShip.fullInit(
      JoystickComponent joystick,
      Vector2? size,
      double? speed,
      int? health,
      int? damage)
      : super.fullInit(joystick,
            size: size, speed: speed, health: health, damage: damage);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    size.y = size.x;

    // Set the appearance and appearance of the spacecraft
    sprite = await gameRef.loadSprite('asteroids_ship.png');
    // The initial position of the spacecraft, in the middle of the screen
    position = gameRef.size / 2;

    _muzzleComponent.position.x = size.x / 2;
    _muzzleComponent.position.y = size.y / 10;
    add(_muzzleComponent);
  }

  @override
  void update(double dt) {
    final isUsingJoystick = !_joystick.delta.isZero();
    final joystickAngle = _joystick.delta.screenAngle();

    // Check whether the joystick is now used to operate the spacecraft
    if (isUsingJoystick) {
      // Update the spacecraft position, calculate the movement amount of one frame through delta and speed, and add new movement distance
      getNextPosition().add(_joystick.relativeDelta * _maxSpeed * dt);

      // Update the spacecraft angle according to the angle of the joystick
      angle = joystickAngle;

      return;
    }

    // Check if the keyboard is now used to operate the ship
    final isUsingKeyboard = !gameRef.keyboardDirection.isZero();
    if (isUsingKeyboard) {
      // Update the spacecraft position, calculate the movement amount of one frame through delta and speed, and add new movement distance
      getNextPosition().add(gameRef.keyboardDirection * _maxSpeed * dt);

      // Update the angle of the spacecraft and judge the angle of the spacecraft according to the pressing of the keyboard direction keys.
      final keyboardAngle = gameRef.keyboardDirection.screenAngle();
      angle = keyboardAngle + joystickAngle;

      return;
    }
  }

  @override
  void onDestroy() {}

  @override
  void onHit(PositionComponent other) {}
}
