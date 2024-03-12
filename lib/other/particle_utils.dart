import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:spaceship_game/other/utils.dart';

enum ExplosionEnum {
  largeParticleExplosion,
  mediumParticleExplosion,
  fieryExplosion,
  bonusExplosion,
}

abstract class Explosion {
  static const double defaultLifespan = 1.0;
  static const int defaultParticleCount = 1;
  static final Vector2 defaultPosition = Vector2(-1, -1);
  static final Vector2 defaultSize = Vector2.zero();
  static final ExplosionEnum defaultExplosionType = ExplosionEnum.values[0];
  static final Vector2 defaultMultiplier = Vector2.all(1.0);

  double _lifespan = defaultLifespan;
  late Vector2 _position = defaultPosition;
  Vector2 _size = defaultSize;
  int _particleCount = defaultParticleCount;
  Images? _images;

  //
  // default constructor with default values
  Explosion(Vector2 resolutionMultiplier, Vector2 position) {
    _position = position;
  }

  //
  // named constructor
  Explosion.fullInit(Vector2 position,
      {double? lifespan, int? particleCount, Vector2? size, Images? images})
      : _position = position,
        _lifespan = lifespan ?? defaultLifespan,
        _particleCount = particleCount ?? defaultParticleCount,
        _size = size ?? defaultSize,
        _images = images;

  ////////////////////////////////////////////////////////
  // business methods
  //

  //
  // Called when the explosion has been created but not yet rendered.
  Future<void> onCreate();

  //
  // Called when the explosion has been hit. The ‘other’ is what the explosion hit, or was hit by.
  void onHit(PositionComponent other);

  //
  // Main generator method. This will create the actual particle simulation to the caller
  ParticleSystemComponent getParticleSimulation(Vector2 position);

  //////////////////////////////////////////////////////////
  /// overrides
  ///

  @override

  /// We are defining our own stringify method so that we can see our
  /// values when debugging.
  ///
  String toString() {
    return 'particle count: $_particleCount , position: $_position , lifespan: $_lifespan, size: $_size';
  }
}

/// This class creates a particle explosion class which can be used to customize
/// particle-based explosions.
/// This is an extension of [Explosion] class which is really just a convenience
/// of being able to wrap functionality in a simple to generate particle
/// generator.
///
class ParticleExplosion360 extends Explosion {
  static const double defaultLifespan = 3.0;
  static final Vector2 defaultSize = Vector2.all(2.0);
  static const int defaultParticleCount = 45;
  // color of the particles
  static final _paint = Paint()..color = Colors.red;

  ParticleExplosion360(Vector2 position)
      : super.fullInit(position,
            size: defaultSize,
            lifespan: defaultLifespan,
            particleCount: defaultParticleCount);

  //
  // named constructor
  ParticleExplosion360.fullInit(
      Vector2 position, Vector2? size, double? lifespan, int? particleCount)
      : super.fullInit(position,
            size: size, lifespan: lifespan, particleCount: particleCount);

  @override
  void onHit(PositionComponent other) {}

  @override
  Future<void> onCreate() async {}

  @override

  /// implementation of the particle generator which will return a wrapped
  /// particle simulation in a [ParticleComponent]
  ///
  /// This is a simple explosion simulation which creates circular particles
  /// which travel in all directions in a random fashion.
  ///
  ParticleSystemComponent getParticleSimulation(Vector2 position) {
    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: _particleCount,
        lifespan: _lifespan,
        generator: (i) {
          final acceleration = Utils.randomVector()..scale(100);

          return AcceleratedParticle(
            speed: acceleration,
            child: CircleParticle(
              paint: Paint()..color = _paint.color,
              radius: _size.x / 2,
            ),
          );
        },
      ),
    );
  }
}

/// This class creates a particle explosion class which can be used to customize
/// particle-based explosions.
/// This is an extension of [Explosion] class which is really just a convenience
/// of being able to wrap functionality in a simple to generate particle
/// generator.
///
class ParticleBonusExplosion extends Explosion {
  static const double defaultLifespan = 3.0;
  static final Vector2 defaultSize = Vector2.all(2.0);
  static const int defaultParticleCount = 45;
  // color of the particles
  static final _paint = Paint()..color = Colors.white;

  ParticleBonusExplosion(Vector2 position)
      : super.fullInit(position,
            size: defaultSize,
            lifespan: defaultLifespan,
            particleCount: defaultParticleCount);

  //
  // named constructor
  ParticleBonusExplosion.fullInit(Vector2 resolutionMultiplier,
      Vector2 position, Vector2? size, double? lifespan, int? particleCount)
      : super.fullInit(position,
            size: size, lifespan: lifespan, particleCount: particleCount);

  @override
  void onHit(PositionComponent other) {}

  @override
  Future<void> onCreate() async {}

  @override

  /// implementation of the particle generator which will return a wrapped
  /// particle simulation in a [ParticleComponent]
  ///
  /// This is a simple explosion simulation which creates circular particles
  /// which travel in all directions in a random fashion.
  ///
  ParticleSystemComponent getParticleSimulation(Vector2 position) {
    return ParticleSystemComponent(
      position: _position,
      particle: Particle.generate(
        count: _particleCount,
        lifespan: _lifespan,
        generator: (i) => AcceleratedParticle(
          acceleration: Utils.randomVector()..scale(100),
          child: CircleParticle(
            paint: Paint()..color = _paint.color,
            radius: _size.x / 2,
          ),
        ),
      ),
    );
  }
}

/// This class creates a particle explosion class which can be used to customize
/// particle-based explosions.
/// This is an extension of [Explosion] class which is really just a convenience
/// of being able to wrap functionality in a simple to generate particle
/// generator.
///
class FieryExplosion extends Explosion {
  static const double defaultLifespan = 3.0;
  static final Vector2 defaultSize = Vector2.all(1.5);

  FieryExplosion(Vector2 position)
      : super.fullInit(position,
            size: defaultSize,
            lifespan: defaultLifespan,
            particleCount: Explosion.defaultParticleCount);

  //
  // named constructor
  FieryExplosion.fullInit(Vector2 position, Vector2? size, double? lifespan,
      int? particleCount, Images? images)
      : super.fullInit(position,
            size: size,
            lifespan: lifespan,
            particleCount: particleCount,
            images: images);

  @override
  void onHit(PositionComponent other) {}

  @override
  Future<void> onCreate() async {
    //await gameRef.images.load('boom.png');
  }

  @override

  /// implementation of the particle generator which will return a wrapped
  /// particle simulation in a [ParticleComponent]
  ///
  /// This is a simple explosion simulation which creates circular particles
  /// which travel in all directions in a random fashion.
  ///
  ParticleSystemComponent getParticleSimulation(Vector2 position) {
    // create the ParticleComponent
    return ParticleSystemComponent(
      position: position,
      particle: AcceleratedParticle(
        lifespan: 2,
        child: SpriteAnimationParticle(
          animation: _getBoomAnimation(),
        ),
      ),
    );
  }

  ///
  /// Load up the sprite sheet with an even step time framerate
  SpriteAnimation _getBoomAnimation() {
    const columns = 8;
    const rows = 8;
    const frames = columns * rows;
    final spriteImage = _images!.fromCache('boom.png');
    final spriteSheet = SpriteSheet.fromColumnsAndRows(
      image: spriteImage,
      columns: columns,
      rows: rows,
    );
    final sprites = List<Sprite>.generate(frames, spriteSheet.getSpriteById);
    return SpriteAnimation.spriteList(sprites, stepTime: 0.1);
  }
}

/// This is a Factory Method Design pattern example implementation for explosions
/// for our game
///
/// The class will return an instance of the specific ParticleComponent asked for based
/// on a valid explosion type choice.
class ExplosionFactory {
  ExplosionFactory._();

  static ParticleSystemComponent create(ExplosionBuildContext context) {
    Explosion preResult;
    ParticleSystemComponent result;

    /// collect all the Asteroid definitions here
    switch (context.explosionType) {
      case ExplosionEnum.largeParticleExplosion:
        {
          preResult = ParticleExplosion360(context.position);
        }
        break;

      case ExplosionEnum.mediumParticleExplosion:
        {
          preResult = ParticleExplosion360(context.position)
            .._particleCount = 20
            .._lifespan = 1.5;
        }
        break;

      case ExplosionEnum.bonusExplosion:
        {
          preResult = ParticleBonusExplosion(context.position)
            .._particleCount = 60
            .._lifespan = 2.0;
        }
        break;

      case ExplosionEnum.fieryExplosion:
        {
          preResult = FieryExplosion(context.position)
            .._images = context.images;
        }
        break;
    }

    preResult.onCreate();
    result = preResult.getParticleSimulation(context.position);
    return result;
  }
}

class ExplosionBuildContext {
  static const double defaultLifespan = 1.0;
  static const int defaultParticleCount = 1;
  static final Vector2 defaultPosition = Vector2(-1, -1);
  static final Vector2 defaultSize = Vector2.zero();
  static final ExplosionEnum defaultExplosionType = ExplosionEnum.values[0];

  /// helper method for parsing out strings into corresponding enum values
  ///
  static ExplosionEnum explosionFromString(String value) {
    return ExplosionEnum.values.firstWhere(
        (e) => e.toString().split('.')[1].toUpperCase() == value.toUpperCase());
  }

  double lifespan = defaultLifespan;
  Vector2 position = defaultPosition;
  Vector2 size = defaultSize;
  int particleCount = defaultParticleCount;
  ExplosionEnum explosionType = defaultExplosionType;
  Images? images;

  ExplosionBuildContext();

  @override

  /// We are defining our own stringify method so that we can see our
  /// values when debugging.
  ///
  String toString() {
    return 'name: $explosionType , position: $position , lifespan: $lifespan';
  }
}
