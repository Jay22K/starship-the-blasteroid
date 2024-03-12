import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spaceship_game/asteroid/asteroid_build_context.dart';
import 'package:spaceship_game/asteroid/asteroid_factory.dart';
import 'package:spaceship_game/game.dart';
import 'package:spaceship_game/game_bonus/game_bonus_build_context.dart';
import 'package:spaceship_game/game_bonus/game_bonus_factory.dart';
import 'package:spaceship_game/other/utils.dart';
import 'package:spaceship_game/space_ship/space_ship_build_context.dart';
import 'package:spaceship_game/space_ship/space_ship_factory.dart';

import 'asteroid/asteroid.dart';
import 'command/command.dart';
import 'game_bonus/game_bonus.dart';
import 'other/json_utils.dart';
import 'score_board/score_board.dart';
import 'space_ship/spaceship.dart';

/// 管理者，掌握遊戲內的元件與操作
class Controller extends Component with HasGameRef<SpaceshipGame> {
  static const defaultNumberOfLives = 1;
  static const defaultStartLevel = 0;

  // pause between levels or new lives in seconds
  static const timeoutPauseInSeconds = 3;
  int _pauseCountdown = 0;
  bool _levelDoneFlag = false;
  int _createPlayerCountdown = 0;
  bool _playerDiedFlag = false;

  /// the broker which is a dedicated helper that executes all the commands
  /// on behalf o teh controller
  final Broker _broker = Broker();

  late JoystickComponent _joystick;

  /// all the game levels loaded from JSON
  late List<GameLevel> _gameLevels;
  int _currentGameLevelIndex = 0;

  /// a stack used to hold all the objects from the current level. Once this
  /// list/stack is empty we can go to the next level.
  List currentLevelObjectStack = List.empty(growable: true);

  /// JSON Data from initialization
  late dynamic jsonData;

  late ScoreBoard _scoreboard;

  /// The SpaceShip being controlled by Joystick
  ///
  late SpaceShip spaceShip;

  /// Parallax image assets
  ///
  final _parallaxImages = [
    ParallaxImageData('small_stars.png'),
    ParallaxImageData('big_stars.png'),
  ];

  late final ParallaxComponent parallax;
  final double parallaxSpeed = 25.0;

  /// Restart when the game over.
  ///
  late ButtonComponent restartButton;
  late ButtonComponent quitButton;

  /// add a timer which will notify the controller of the passage of time
  /// timer used to notify the controller about the passage of time
  ///
  late final TimerComponent controllerTimer;

  JoystickComponent getJoystick() {
    return _joystick;
  }

  SpaceShip getSpaceship() {
    return spaceShip;
  }

  Images getGameImages() {
    return gameRef.images;
  }

  /// initialization 'hook' this should be called right after the Controller
  /// has been created
  ///
  /// It will initialize the inner state of the
  Future<void> init() async {
    jsonData = await JSONUtils.readJSONInitData();

    await addScoreBoard();
    await addParallax();
    addJoystick();
    addTimer();

    spawnNewPlayer();
  }

  /// timer hook
  /// We will monitor here the exact passage of time in seconds for the game
  void timerNotification() {
    /// Update time passage in scoreboard
    ///
    UpdateScoreboardTimePassageInfoCommand(_scoreboard).addToController(this);

    if (_scoreboard.getCurrentLevel > 0) {
      int currentTimeTick = _scoreboard.getTimeSinceStartOfLevel;
      if (_gameLevels[_scoreboard.getCurrentLevel - 1]
          .shouldSpawnBonus(currentTimeTick)) {
        GameBonusBuildContext? context =
            _gameLevels[_scoreboard.getCurrentLevel - 1]
                .getBonus(currentTimeTick);

        if (context != null) {
          /// build the bonus and add it to the game
          ///
          GameBonus? bonus = GameBonusFactory.create(context);
          currentLevelObjectStack.add(bonus);

          if (bonus == null) {
            return;
          }

          add(bonus);
        }
      }
    }

    if (isCurrentLevelFinished()) {
      loadNextGameLevel();
    }

    if (shouldCreatePlayer()) {
      spawnNewPlayer();
    }
  }

  @override
  void update(double dt) {
    _broker.process();
    super.update(dt);

    /// Update parallax background
    if (children.contains(spaceShip)) {
      parallax.parallax?.baseVelocity =
          (gameRef.keyboardDirection + _joystick.relativeDelta) * 200;
    } else {
      parallax.parallax?.baseVelocity = Vector2.zero();
    }
  }

  @override
  void render(Canvas canvas) {
    TextPaint(
      style: const TextStyle(
        fontSize: 14.0,
        fontFamily: 'Awesome Font',
        color: Colors.grey,
      ),
    ).render(
      canvas,
      '(Can be controlled using "direction keys")',
      Vector2(gameRef.size.x - 260, gameRef.size.y - 30),
    );
  }

  Future<void> addScoreBoard() async {
    // Get game level information
    _gameLevels = JSONUtils.extractGameLevels(jsonData);

    // Create scoreboard
    _scoreboard =
        ScoreBoard(defaultNumberOfLives, defaultStartLevel, _gameLevels.length);

    // Create local database
    final sharedPreferences = await SharedPreferences.getInstance();

    // Load the highest score
    int? userHighScore = sharedPreferences.getInt('highScore') ?? 0;
    _scoreboard.highScore = userHighScore;

    // Add scoreboard to game
    add(_scoreboard);
  }

  void resetLevel() {
    for (final asteroid in currentLevelObjectStack) {
      remove(asteroid);
    }
    currentLevelObjectStack.clear();
    _currentGameLevelIndex = 0;
  }

  void resetScoreBoard() {
    addCommand(ResetScoreboardCommand(_scoreboard));
  }

  Future<void> addParallax() async {
    parallax = await gameRef.loadParallaxComponent(
      _parallaxImages,
      baseVelocity: Vector2(0, 0),
      velocityMultiplierDelta: Vector2(1.0, 1.5),
      repeat: ImageRepeat.repeat,
    );

    add(parallax);
  }

  void addJoystick() {
    // joystick knob and background skin styles
    final knobPaint = BasicPalette.lightBlue.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.lightBlue.withAlpha(100).paint();
    //
    // Actual Joystick component creation
    _joystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: knobPaint),
      background: CircleComponent(radius: 70, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 20, bottom: 20),
    );

    ///
    /// we add the player and joystick to the controller's tree of components
    add(_joystick);
  }

  void removeJoystick() {
    remove(_joystick);
  }

  void addTimer() {
    controllerTimer = TimerComponent(
      period: 1,
      repeat: true,
      onTick: () {
        timerNotification();
      },
    );
    add(controllerTimer);
  }

  void addRestartButton() {
    restartButton = ButtonComponent(
      size: Vector2.all(100),
      button: PositionComponent(
        children: [
          TextComponent(
            text: 'Restart',
            textRenderer: TextPaint(
              style: TextStyle(
                fontFamily: 'Bruce-Forever',
                fontSize: 21,
              ),
            ),
          ),
        ],
      ),
      position: Vector2(
        gameRef.size.x / 2 - 50,
        gameRef.size.y / 2 - 50,
      ),
      onPressed: () {
        restart();
      },
    );

    add(restartButton);
  }

  void removeRestartButton() {
    remove(restartButton);
  }

  void addQuitButton() {
    quitButton = ButtonComponent(
      size: Vector2.all(100),
      button: PositionComponent(
        children: [
          TextComponent(
            text: 'Quit',
            textRenderer: TextPaint(
              style: TextStyle(
                fontFamily: 'Bruce-Forever',
                fontSize: 21,
              ),
            ),
          ),
        ],
      ),
      position: Vector2(
        gameRef.size.x / 2 - 20,
        gameRef.size.y / 2 - 10, // Adjust position accordingly
      ),
      onPressed: () {
        // quit(); // Function to quit the game
        log("exit game");
        exit(0);
        gameRef.buildContext;
      },
    );

    add(quitButton);
  }

  void removeQuitButton() {
    remove(quitButton);
  }

  void addCommand(Command command) {
    _broker.addCommand(command);
  }

  /// getters
  ///
  List<GameLevel> get getLevels {
    return _gameLevels;
  }

  ScoreBoard get getScoreBoard {
    return _scoreboard;
  }

  /// Load next game level
  void loadNextGameLevel() {
    // reset data
    List<Asteroid> asteroids = List.empty(growable: true);

    currentLevelObjectStack.clear();

    // make sure that there are more levels left
    //
    if (_currentGameLevelIndex < _gameLevels.length) {
      // load the asteroid elements
      //
      for (var asteroid in _gameLevels[_currentGameLevelIndex].asteroidConfig) {
        // Help the meteorite generate a random appearance location
        asteroid.position =
            Utils.generateRandomPosition(screenSize: gameRef.size);

        // The location of the spaceship
        var spaceShipPosition = spaceShip.position;

        // Check the distance between the meteorite and the spacecraft. If it is too close, push the meteorite outward to prevent the player from being hit at the beginning.
        final distance = asteroid.position.distanceTo(spaceShipPosition);

        // If the distance is within 200 pixels, add 200 pixels to the position of the meteorite.
        if (distance < 200) {
          asteroid.position.add(Vector2(200, 200));
        }

        // create each asteroid
        Asteroid newAsteroid = AsteroidFactory.create(asteroid);
        asteroids.add(newAsteroid);

        currentLevelObjectStack.add(asteroids.last);
      }
      // add all the asteroids to the component tree so that they are part of
      // the game play
      addAll(asteroids);
      // load the game bonus elements

      // update the level counter
      _currentGameLevelIndex++;
      UpdateScoreboardLevelInfoCommand(getScoreBoard).addToController(this);
    }
  }

  void spawnNewPlayer() {
    //
    // creating the player that will be controlled by our joystick
    SpaceShipBuildContext context = SpaceShipBuildContext()
      ..spaceShipType = SpaceShipEnum.simpleSpaceShip
      ..joystick = _joystick;
    spaceShip = SpaceShipFactory.create(context);
    add(spaceShip);
  }

  // Check if the current level is completed
  bool isCurrentLevelFinished() {
    if (currentLevelObjectStack.isEmpty) {
      if (_levelDoneFlag == false) {
        _levelDoneFlag = true;
        _pauseCountdown = timeoutPauseInSeconds;
        return false;
      }
      if (_levelDoneFlag == true) {
        if (_pauseCountdown == 0) {
          _levelDoneFlag = false;
          return true;
        } else {
          _pauseCountdown--;
          return false;
        }
      }
      return false;
    } else {
      return false;
    }
  }

  /// check if the current level is done.
  ///
  /// We also add a barrier of a couple seconds to pause teh level generation
  /// so that the player has a few seconds in between levels
  ///
  bool shouldCreatePlayer() {
    if (!children.any((element) => element is SpaceShip)) {
      if (_playerDiedFlag == false) {
        _playerDiedFlag = true;
        _createPlayerCountdown = timeoutPauseInSeconds;
        return false;
      }
      if (_playerDiedFlag == true && _scoreboard.getLivesLeft > 0) {
        if (_createPlayerCountdown == 0) {
          _playerDiedFlag = false;
          return true;
        } else {
          _createPlayerCountdown--;
          return false;
        }
      }
      return false;
    } else {
      return false;
    }
  }

  void restart() {
    resetLevel();
    resetScoreBoard();
    addJoystick();
    spawnNewPlayer();
    removeRestartButton();
    removeQuitButton();
  }
}

class GameLevel {
  List<AsteroidBuildContext> asteroidConfig = [];
  List<GameBonusBuildContext> gameBonusConfig = [];
  final Map<int, GameBonusBuildContext> _gameBonusMap = {};

  GameLevel();

  void init() {
    for (GameBonusBuildContext bonus in gameBonusConfig) {
      _gameBonusMap[bonus.timeTriggerSeconds] = bonus;
    }
  }

  /// business methods
  ///
  bool shouldSpawnBonus(int timeTick) {
    if (_gameBonusMap[timeTick] != null) {
      return true;
    } else {
      return false;
    }
  }

  GameBonusBuildContext? getBonus(int timeTick) {
    return _gameBonusMap[timeTick];
  }

  @override

  /// We are defining our own stringify method so that we can see our
  /// values when debugging.
  ///
  String toString() {
    return 'level data: [ asteroids: $asteroidConfig ] , gameBonus: [$gameBonusConfig]';
  }
}
