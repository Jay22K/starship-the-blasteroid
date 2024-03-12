import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:spaceship_game/game.dart';

import '../bullet/bullet.dart';
import '../command/command.dart';
import '../other/utils.dart';
import '../space_ship/spaceship.dart';

enum AsteroidType {
  largeAsteroid,
  mediumAsteroid,
  smallAsteroid,
}

abstract class Asteroid extends PositionComponent
    with CollisionCallbacks, HasGameRef<SpaceshipGame> {
  static const double defaultSpeed = 100.00;
  static const int defaultDamage = 1;
  static const int defaultHealth = 1;
  static final defaultSize = Vector2.all(5.0);

  // velocity vector for the asteroid.
  late Vector2 _velocity;

  // speed of the asteroid
  late double _speed;

  // health of the asteroid
  late final int? _health;

  // damage that the asteroid does
  late final int? _damage;

  //
  // default constructor with default values
  Asteroid(Vector2 position, Vector2 velocity)
      : _velocity = velocity.normalized(),
        _health = defaultHealth,
        _damage = defaultDamage,
        super(
          size: defaultSize,
          position: position,
          anchor: Anchor.center,
        );

  //
  // named constructor
  Asteroid.fullInit(Vector2 position, Vector2 velocity,
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

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bullet) {
      BulletCollisionCommand(other, this).addToController(gameRef.controller);
      AsteroidCollisionCommand(this).addToController(gameRef.controller);
      UpdateScoreboardScoreCommand(gameRef.controller.getScoreBoard)
          .addToController(gameRef.controller);
    }

    if (other is SpaceShip) {
      PlayerCollisionCommand(other, this).addToController(gameRef.controller);
    }

    super.onCollision(intersectionPoints, other);
  }

  ///////////////////////////////////////////////////////
  // getters
  //
  int? get getDamage {
    return _damage;
  }

  int? get getHealth {
    return _health;
  }

  Vector2 get getVelocity {
    return _velocity;
  }

  ////////////////////////////////////////////////////////
  // business methods
  //

  //
  // Called when the asteroid has been created.
  void onCreate() {
    position = position;
    add(CircleHitbox());
  }

  //
  // Called when the asteroid is being destroyed.
  void onDestroy();

  //
  // Called when the asteroid has been hit. The ‘other’ is what the asteroid
  // hit, or was hit by.
  void onHit(Component other);

  //
  // getter to check of this asteroid can be split
  bool canBeSplit() {
    return getSplitAsteroids().isNotEmpty;
  }

  // should return the list of the astroid types to split this asteroid into
  // or empty list if there is none (i.e. no split)
  // You will override this method to return a non-empty list if valid enum
  // values for when the astroid gets split when it is hit
  List<AsteroidType> getSplitAsteroids() {
    return List.empty();
  }

  /// Get the latest position. If it exceeds the boundary, it will appear from the other side.
  Vector2 getNextPosition() {
    return Utils.wrapPosition(gameRef.size, position);
  }

  @override

  /// We are defining our own stringify method so that we can see our
  /// values when debugging.
  ///
  String toString() {
    return 'speed: $_speed , position: $position , velocity: $_velocity';
  }
}

/// This class creates a small asteroid implementation of the [Asteroid] contract and
/// renders the asteroid as a simple green circle.
/// Speed has been defaulted to 150 p/s but can be changed through the
/// constructor. It is set with a damage of 1 which is the lowest damage and
/// with health of 1 which means that it will be destroyed on impact since it
/// is also the lowest health you can have.
///
class SmallAsteroid extends Asteroid {
  static const double defaultSpeed = 150.0;
  static final Vector2 defaultSize = Vector2.all(24);
  static final _paint = Paint()..color = Colors.green;

  SmallAsteroid(Vector2 position, Vector2 velocity)
      : super.fullInit(position, velocity,
            speed: defaultSpeed,
            health: Asteroid.defaultHealth,
            damage: Asteroid.defaultDamage,
            size: defaultSize);

  SmallAsteroid.fullInit(
      Vector2 position,
      Vector2 velocity,
      Vector2 resolutionMultiplier,
      Vector2? size,
      double? speed,
      int? health,
      int? damage)
      : super.fullInit(position, velocity,
            size: size,
            speed: speed ?? defaultSpeed,
            health: health,
            damage: damage);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _velocity = (_velocity) * _speed;
  }

  @override
  void update(double dt) {
    getNextPosition().add(_velocity * dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the circle component
    final localCenter = (scaledSize / 2).toOffset();
    canvas.drawCircle(localCenter, size.x / 2, _paint);
  }

  @override
  void onDestroy() {}

  @override
  void onHit(Component other) {}
}

/// This class creates a medium asteroid implementation of the [Asteroid] contract and
/// renders the asteroid as a simple red circle.
/// Speed has been defaulted to 150 p/s but can be changed through the
/// constructor. It is set with a damage of 1 which is the lowest damage and
/// with health of 1 which means that it will be destroyed on impact since it
/// is also the lowest health you can have.
///
class MediumAsteroid extends Asteroid {
  static const double defaultSpeed = 100.0;
  static final Vector2 defaultSize = Vector2.all(32);

  static final _paint = Paint()..color = Colors.blue;

  MediumAsteroid(Vector2 position, Vector2 velocity)
      : super.fullInit(position, velocity,
            speed: defaultSpeed,
            health: Asteroid.defaultHealth,
            damage: Asteroid.defaultDamage,
            size: defaultSize);

  MediumAsteroid.fullInit(
      Vector2 position,
      Vector2 velocity,
      Vector2 resolutionMultiplier,
      Vector2? size,
      double? speed,
      int? health,
      int? damage)
      : super.fullInit(position, velocity,
            size: size,
            speed: speed ?? defaultSpeed,
            health: health,
            damage: damage);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // _velocity is a unit vector so we need to make it account for the actual
    // speed.
    _velocity = (_velocity)..scaleTo(_speed);
  }

  @override

  /// we will render the asteroid as a ball initially
  void render(Canvas canvas) {
    super.render(canvas);

    final localCenter = (scaledSize / 2).toOffset();
    canvas.drawCircle(localCenter, size.x / 2, _paint);
  }

  @override
  void update(double dt) {
    getNextPosition().add(_velocity * dt);
  }

  @override
  void onDestroy() {}

  @override
  void onHit(Component other) {}

  @override

  /// If collision appear, split this asteroid into 2 small asteroids
  ///
  List<AsteroidType> getSplitAsteroids() {
    return [AsteroidType.smallAsteroid, AsteroidType.smallAsteroid];
  }
}

/// This class creates a medium asteroid implementation of the [Asteroid] contract and
/// renders the asteroid as a simple red circle.
/// Speed has been defaulted to 150 p/s but can be changed through the
/// constructor. It is set with a damage of 1 which is the lowest damage and
/// with health of 1 which means that it will be destroyed on impact since it
/// is also the lowest health you can have.
///
class LargeAsteroid extends Asteroid {
  static const double defaultSpeed = 50.0;
  static final Vector2 defaultSize = Vector2.all(48);
  static final _paint = Paint()..color = Colors.red;

  LargeAsteroid(Vector2 position, Vector2 velocity)
      : super.fullInit(position, velocity,
            speed: defaultSpeed,
            health: Asteroid.defaultHealth,
            damage: Asteroid.defaultDamage,
            size: defaultSize);

  LargeAsteroid.fullInit(Vector2 position, Vector2 velocity, Vector2? size,
      double? speed, int? health, int? damage)
      : super.fullInit(position, velocity,
            size: size,
            speed: speed ?? defaultSpeed,
            health: health,
            damage: damage);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _velocity = (_velocity)..scaleTo(_speed);

    /// Let LargeAsteroid to be a "dash" image
    // final spriteImage = await Sprite.load('dash.png');
    // final sprite = SpriteComponent(
    //   anchor: Anchor.center,
    //   size: defaultSize,
    //   sprite: spriteImage,
    // );
    // add(sprite);
  }

  @override

  /// we will render the asteroid as a ball initially
  void render(Canvas canvas) {
    super.render(canvas);

    final localCenter = (scaledSize / 2).toOffset();
    canvas.drawCircle(localCenter, size.x / 2, _paint);
  }

  @override
  void update(double dt) {
    getNextPosition().add(_velocity * dt);
  }

  @override
  void onDestroy() {}

  @override
  void onHit(Component other) {}

  @override

  /// If collision appear, split this asteroid into 2 medium asteroids
  ///
  List<AsteroidType> getSplitAsteroids() {
    return [AsteroidType.mediumAsteroid, AsteroidType.mediumAsteroid];
  }
}
