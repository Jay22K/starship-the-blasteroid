import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spaceship_game/asteroid/asteroid_build_context.dart';
import 'package:spaceship_game/asteroid/asteroid_factory.dart';
import 'package:spaceship_game/bullet/bullet_build_context.dart';
import 'package:spaceship_game/bullet/bullet_factory.dart';

import '../asteroid/asteroid.dart';
import '../bullet/bullet.dart';
import '../controller.dart';
import '../game_bonus/game_bonus.dart';
import '../other/particle_utils.dart';
import '../score_board/score_board.dart';
import '../space_ship/spaceship.dart';

/// Broker: 協調者，負責處理所有需要執行的動作命令
class Broker {
  final _commandList = List<Command>.empty(growable: true);
  final _pendingCommandList = List<Command>.empty(growable: true);
  //
  // extra list to track any duplicate messages that should be unique
  final _duplicatesWatcher = List<Command>.empty(growable: true);

  /// explicit default constructor
  Broker();

  /// add the command to the broker to process
  void addCommand(Command command) {
    /// pre-condition
    if (command.mustBeUnique()) {
      if (_duplicatesWatcher
          .any((element) => element.getId() == command.getId())) {
        // 重複指令就不進行處理了
        return;
      } else {
        // add it to the watched list
        _duplicatesWatcher.add(command);
      }
    } // end of pre-condition

    // add the command to the queue
    _pendingCommandList.add(command);
  }

  void process() {
    for (var command in _commandList) {
      command.execute();
    }

    _commandList.clear();

    _commandList.addAll(_pendingCommandList);

    _pendingCommandList.clear();
  }
}

/// Abstraction of a command pattern
/// All commands have access to the controller for any state related data
/// including the ability for complex commands where a command can aggregate
/// other commands.
///
/// Each command has to be added to a [Controller] for management
abstract class Command {
  /// empty constructor
  Command();

  /// The controller to which this command was added
  late Controller _controller;

  /// getter for the controller
  Controller _getController() {
    return _controller;
  }

  /// this method adds the Command to a specific controller.
  void addToController(Controller controller) {
    _controller = controller;
    controller.addCommand(this);
  }

  /// abstract execute method. All the [Command] derivations will need to put
  /// their work code in here
  void execute();

  /// An optional title for the command for any debug or printing functionality
  String getTitle();

  /// this will get some sort of command id to identify when we have duplicate
  /// commands
  /// One solution when you want to avoid duplicates is to use create the id as
  /// follows:
  ///     - use the title of the command
  ///     - append to it the ':' followed by some sort of hash code
  String getId() {
    return "Command:0";
  }

  /// this will tell broker if the command must be unique in the existing queue
  ///
  bool mustBeUnique() {
    return false;
  }
}

/// Specific implementation of the [Command] abstraction that alerts the
/// Spaceship class that a user has tapped the screen
///
/// In this implementation we create additional commands to fire a bullet
/// and to generate the sound for the bullet firing.
class UserTapUpCommand extends Command {
  /// The receiver of this command
  SpaceShip player;

  /// default constructor
  UserTapUpCommand(this.player);

  /// work method. We simply fire a bullet in this example
  @override
  void execute() {
    // only fire the bullet if the player is alive
    if (_getController().contains(player)) {
      BulletFiredCommand().addToController(_getController());
      // BulletFiredSoundCommand().addToController(_getController());
    }
  }

  @override
  String getTitle() {
    return "UserTapUpCommand";
  }
}

class BulletFiredCommand extends Command {
  BulletFiredCommand();

  @override
  void execute() {
    BulletFiredSoundCommand().addToController(_getController());

    /// 預設子彈為往上發射
    var velocity = Vector2(0, -1);
    // rotate this vector to the same angle as the player
    velocity.rotate(_getController().getSpaceship().angle);
    // create a bullet with the specific angle and add it to the game
    BulletBuildContext context = BulletBuildContext()
      ..bulletType = _getController().getSpaceship().getBulletType
      ..position =
          _getController().getSpaceship().getMuzzleComponent.absolutePosition
      ..velocity = velocity
      ..size = Vector2.all(16);
    Bullet myBullet = BulletFactory.create(context);
    // add the bullet to the controller's game tree
    _getController().add(myBullet);
    // let the scoreboard know to update the number of shots fired
    UpdateScoreboardShotFiredCommand(_getController().getScoreBoard)
        .addToController(_getController());
  }

  @override
  String getTitle() {
    return "BulletFiredCommand";
  }
}

class BulletDestroyCommand extends Command {
  late Bullet targetBullet;

  BulletDestroyCommand(Bullet bullet) {
    targetBullet = bullet;
  }

  @override
  void execute() {
    // let the bullet know its being destroyed.
    targetBullet.onDestroy();
    // remove the bullet from the game
    if (_getController().children.any((element) => targetBullet == element)) {
      _getController().remove(targetBullet);
    }
  }

  @override
  String getTitle() {
    return "BulletDestroyCommand";
  }
}

class BulletFiredSoundCommand extends Command {
  BulletFiredSoundCommand();

  @override
  void execute() {
    // sounds used for the shot
    FlameAudio.play('missile_shot.wav', volume: 0.1);
    // layered sounds for missile transition/flyby
    FlameAudio.play('missile_flyby.wav', volume: 0.1);
  }

  @override
  String getTitle() {
    return "BulletFiredSoundCommand";
  }
}

/// Implementation of the [Command] to notify a bullet that it has been hit
///
class BulletCollisionCommand extends Command {
  late Bullet targetBullet;
  late Component collisionObject;

  BulletCollisionCommand(Bullet bullet, Component other) {
    targetBullet = bullet;
    collisionObject = other;
  }

  @override
  void execute() {
    // let the bullet know its being destroyed.
    targetBullet.onDestroy();
    // remove the bullet from the game
    _getController().remove(targetBullet);
  }

  @override
  String getTitle() {
    return "BulletCollisionCommand";
  }

  @override
  String getId() {
    return '${getTitle()}:${targetBullet.hashCode}';
  }

  @override
  bool mustBeUnique() {
    return true;
  }
}

/// Implementation of the [Command] to notify a bullet that it has been hit
///
class AsteroidCollisionCommand extends Command {
  /// the bullet being operated on
  late Asteroid _targetAsteroid;
  Vector2? _collisionPosition;

  AsteroidCollisionCommand(Asteroid asteroid) {
    _targetAsteroid = asteroid;
    _collisionPosition = _targetAsteroid.position.clone();
  }

  @override
  void execute() {
    // check if this is still on the stack
    if (_getController().currentLevelObjectStack.contains(_targetAsteroid)) {
      _getController().currentLevelObjectStack.remove(_targetAsteroid);

      /// 檢查隕石是否還能被分裂
      bool canBeSplit = _targetAsteroid.canBeSplit();

      if (canBeSplit) {
        ExplosionOfSplitAsteroidRenderCommand(_targetAsteroid)
            .addToController(_getController());

        // clone the vector target data so that we have a safe copy
        Vector2 asteroidAVelocity = _targetAsteroid.getVelocity.clone();
        Vector2 asteroidBVelocity = _targetAsteroid.getVelocity.clone();
        // rotate the vector by 45 degrees clockwise and anti-clockwise
        asteroidAVelocity.rotate(pi / 4);
        asteroidBVelocity.rotate(-pi / 4);

        AsteroidBuildContext contextA = AsteroidBuildContext()
          ..asteroidType = _targetAsteroid.getSplitAsteroids()[0]
          ..position = _collisionPosition!
          ..velocity = asteroidAVelocity;

        AsteroidBuildContext contextB = AsteroidBuildContext()
          ..asteroidType = _targetAsteroid.getSplitAsteroids()[1]
          ..position = _collisionPosition!
          ..velocity = asteroidBVelocity;
        // create the two new asteroids
        Asteroid asteroidA = AsteroidFactory.create(contextA);
        Asteroid asteroidB = AsteroidFactory.create(contextB);

        //
        // add them to the stack and the game
        _getController().currentLevelObjectStack.addAll([asteroidA, asteroidB]);
        _getController().addAll([asteroidA, asteroidB]);
      } else {
        ExplosionOfDestroyedAsteroidRenderCommand(_targetAsteroid)
            .addToController(_getController());
      }

      // let the asteroid know its being destroyed.
      _targetAsteroid.onDestroy();
      // remove the target asteroid  from the game
      _getController().remove(_targetAsteroid);
    } else {
      // this is an incorrect collision which we dismiss
      return;
    }
  }

  @override
  String getTitle() {
    return "BulletCollisionCommand";
  }
}

/// Implementation of the [Command] to notify the scoreboard that shots should
/// be updated
class UpdateScoreboardShotFiredCommand extends Command {
  /// the receiver
  late ScoreBoard _scoreboard;

  UpdateScoreboardShotFiredCommand(scoreBoard) {
    _scoreboard = scoreBoard;
  }

  @override
  void execute() {
    // update the scoreboard
    _scoreboard.addBulletFired();
  }

  @override
  String getTitle() {
    return "UpdateShotFiredCommand";
  }
}

/// Implementation of the [Command] to notify the scoreboard that shots should
/// be updated
class UpdateScoreboardScoreCommand extends Command {
  /// the receiver
  late ScoreBoard _scoreboard;

  UpdateScoreboardScoreCommand(scoreBoard) {
    _scoreboard = scoreBoard;
  }

  @override
  void execute() {
    // update the scoreboard
    _scoreboard.addScorePoints(1);
  }

  @override
  String getTitle() {
    return "UpdateScoreboardScoreCommand";
  }
}

/// Implementation of the [Command] to notify the scoreboard that level should
/// be updated
class UpdateScoreboardLevelInfoCommand extends Command {
  /// the receiver
  late ScoreBoard _scoreboard;

  UpdateScoreboardLevelInfoCommand(scoreBoard) {
    _scoreboard = scoreBoard;
  }

  @override
  void execute() {
    // update the scoreboard
    _scoreboard.progressLevel();
    _scoreboard.resetLevelTimer();
  }

  @override
  String getTitle() {
    return "UpdateScoreboardLevelInfoCommand";
  }
}

/// Implementation of the [Command] to notify the scoreboard about passage of
/// time, we are assuming here of adding 1 second
class UpdateScoreboardTimePassageInfoCommand extends Command {
  /// the receiver
  late ScoreBoard _scoreboard;

  UpdateScoreboardTimePassageInfoCommand(scoreBoard) {
    _scoreboard = scoreBoard;
  }

  @override
  void execute() {
    // update the scoreboard
    _scoreboard.addTimeTick();
  }

  @override
  String getTitle() {
    return "UpdateScoreboardTimePassageInfoCommand";
  }
}

class ResetScoreboardCommand extends Command {
  /// the receiver
  late ScoreBoard _scoreboard;

  ResetScoreboardCommand(scoreBoard) {
    _scoreboard = scoreBoard;
  }

  @override
  void execute() {
    _scoreboard.reset();
  }

  @override
  String getTitle() {
    return "ResetScoreboardCommand";
  }
}

/// Implementation of the [Command] to notify a player that it has been hit
///
class PlayerCollisionCommand extends Command {
  /// the bullet being operated on
  late SpaceShip targetPlayer;
  late Component collisionObject;

  PlayerCollisionCommand(SpaceShip player, Component other) {
    targetPlayer = player;
    collisionObject = other;
  }

  @override
  void execute() {
    //
    // test if this was already captured
    if (_getController().children.contains(targetPlayer)) {
      // let the bullet know its being destroyed.
      targetPlayer.onDestroy();
      FlameAudio.play('missile_hit.wav', volume: 0.7);
      // render the camera shake effect for a short duration
      _getController().gameRef.camera.shake(intensity: 20);

      // remove the bullet from the game
      _getController().remove(targetPlayer);
      // generate explosion render
      ExplosionOfSpaceshipRenderCommand().addToController(_getController());
      // remove the life
      PlayerRemoveLifeCommand().addToController(_getController());
    } else {
      // we already dealt with this collision
    }
  }

  @override
  String getTitle() {
    return "BulletCollisionCommand";
  }
}

/// Implementation of the [Command] to notify a player that it has been hit
///
class PlayerRemoveLifeCommand extends Command {
  PlayerRemoveLifeCommand();

  @override
  void execute() {
    // remove the bullet from the game
    _getController().getScoreBoard.removeLife();
  }

  @override
  String getTitle() {
    return "RemovePlayerLifeCommand";
  }
}

/// Implementation of the [Command] to notify the controller that the game is
/// done
///
class GameOverCommand extends Command {
  GameOverCommand();

  @override
  void execute() async {
    if (_getController().getScoreBoard.getScore >
        _getController().getScoreBoard.getHighScore) {
      // 儲存最高分數
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setInt(
          'highScore', _getController().getScoreBoard.getScore);
    }

    _getController().getScoreBoard.stop();
    _getController().removeJoystick();
    _getController().addRestartButton();
    _getController().addQuitButton();
  }

  @override
  String getTitle() {
    return "GameOverCommand";
  }
}

/// Implementation of the [Command] to destroy the instance of game bonus
/// game
class GameBonusDestroyCommand extends Command {
  late GameBonus targetBonus;

  GameBonusDestroyCommand(GameBonus bonus) {
    targetBonus = bonus;
  }

  @override
  void execute() {
    // let the bullet know its being destroyed.
    targetBonus.onDestroy();
    // remove the bonus from the game and form the stack
    if (_getController()
        .currentLevelObjectStack
        .any((element) => targetBonus == element)) {
      _getController().currentLevelObjectStack.remove(targetBonus);
    }
    if (_getController().children.any((element) => targetBonus == element)) {
      _getController().remove(targetBonus);
    }
  }

  @override
  String getTitle() {
    return "GameBonusDestroyCommand";
  }
}

/// Implementation of the [Command] to notify a bullet that it has been hit
///
class GameBonusCollisionCommand extends Command {
  /// the bullet being operated on
  late GameBonus target;
  late Component collisionObject;

  GameBonusCollisionCommand(GameBonus gameBonus, Component other) {
    target = gameBonus;
    collisionObject = other;
  }

  @override
  void execute() {
    ExplosionOfGameBonusRenderCommand(target).addToController(_getController());
    // check if this is still on the stack
    if (_getController().currentLevelObjectStack.contains(target)) {
      _getController().currentLevelObjectStack.remove(target);

      // let the target know its being destroyed.
      target.onDestroy();

      // remove the target from the game
      _getController().remove(target);
    } else {
      // this is an incorrect collision which we dismiss
      return;
    }
  }

  @override
  String getTitle() {
    return "GameBonusCollisionCommand";
  }
}

/// Implementation of the [Command] to create an explosion and add it to the
/// game
class ExplosionOfSpaceshipRenderCommand extends Command {
  ExplosionOfSpaceshipRenderCommand();

  @override
  void execute() {
    // 為太空船新增爆炸粒子效果
    ExplosionBuildContext context = ExplosionBuildContext()
      ..position = _getController().getSpaceship().position
      ..images = _getController().getGameImages()
      ..explosionType = ExplosionEnum.fieryExplosion;
    ParticleSystemComponent explosion = ExplosionFactory.create(context);

    _getController().add(explosion);
  }

  @override
  String getTitle() {
    return "ExplosionOfSpaceshipRenderCommand";
  }
}

/// Implementation of the [Command] to create an explosion and add it to the
/// game
class ExplosionOfDestroyedAsteroidRenderCommand extends Command {
  /// the asteroid being operated on
  late Asteroid _target;

  ExplosionOfDestroyedAsteroidRenderCommand(target) {
    _target = target;
  }
  @override
  void execute() {
    ExplosionBuildContext context = ExplosionBuildContext()
      ..position = _target.position
      ..explosionType = ExplosionEnum.largeParticleExplosion;
    ParticleSystemComponent explosion = ExplosionFactory.create(context);

    _getController().add(explosion);
  }

  @override
  String getTitle() {
    return "ExplosionOfDestroyedAsteroidRenderCommand";
  }
}

/// Implementation of the [Command] to create an explosion and add it to the
/// game
class ExplosionOfSplitAsteroidRenderCommand extends Command {
  late Asteroid _target;

  ExplosionOfSplitAsteroidRenderCommand(target) {
    _target = target;
  }

  @override
  void execute() {
    ExplosionBuildContext context = ExplosionBuildContext()
      ..position = _target.position
      ..explosionType = ExplosionEnum.mediumParticleExplosion;
    ParticleSystemComponent explosion = ExplosionFactory.create(context);

    _getController().add(explosion);
  }

  @override
  String getTitle() {
    return "ExplosionOfSplitAsteroidRenderCommand";
  }
}

/// Implementation of the [Command] to create an explosion and add it to the
/// game
class ExplosionOfGameBonusRenderCommand extends Command {
  late GameBonus _target;

  ExplosionOfGameBonusRenderCommand(target) {
    _target = target;
  }

  @override
  void execute() {
    ExplosionBuildContext context = ExplosionBuildContext()
      ..position = _target.position
      ..explosionType = ExplosionEnum.bonusExplosion;
    ParticleSystemComponent explosion = ExplosionFactory.create(context);

    _getController().add(explosion);
  }

  @override
  String getTitle() {
    return "ExplosionOfGameBonusRenderCommand";
  }
}
