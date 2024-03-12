import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:spaceship_game/game.dart';

import '../command/command.dart';

// Information version
class ScoreBoard extends PositionComponent with HasGameRef<SpaceshipGame> {
  int _highScore = 0;
  int _shotsCount = 0;
  int _score = 0;
  int _livesLeft = 0;
  int _currentLevel = 0;

  // game play time
  int _playSeconds = 0;

  // Level play time
  int _timeSinceStartOfLevelInSeconds = 0;

  int beginLives = 0;

  bool isActive = true;

  final TextPaint _livesLeftTextPaint = TextPaint(
    style: const TextStyle(
      fontSize: 18.0,
      fontFamily: "Bruce-Forever",
      color: Colors.red,
    ),
  );

  //
  // passage of time in seconds
  final TextPaint _passageOfTimePaint = TextPaint(
    style: const TextStyle(
      fontSize: 9.0,
      fontFamily: 'Bruce-Forever',
      color: Colors.grey,
    ),
  );

  //
  // Score
  final TextPaint _scorePaint = TextPaint(
    style: const TextStyle(
      fontSize: 9.0,
      fontFamily: 'Bruce-Forever',
      color: Colors.green,
    ),
  );

  //
  // High Score
  final TextPaint _highScorePaint = TextPaint(
    style: const TextStyle(
      fontSize: 9.0,
      fontFamily: 'Bruce-Forever',
      color: Colors.blueAccent,
    ),
  );

  //
  // Score
  final TextPaint _shotsFiredPaint = TextPaint(
    style: const TextStyle(
      fontSize: 9.0,
      fontFamily: 'Bruce-Forever',
      color: Colors.blue,
    ),
  );

  //
  // Score
  final TextPaint _levelInfoPaint = TextPaint(
    style: const TextStyle(
      fontSize: 9.0,
      fontFamily: 'Bruce-Forever',
      color: Colors.amber,
    ),
  );

  ScoreBoard(int livesLeft, int currentLevel, int maxLevels)
      : beginLives = livesLeft,
        _livesLeft = livesLeft,
        _currentLevel = currentLevel,
        super(priority: 120);

  set highScore(int highScore) {
    if (highScore > 0) {
      _highScore = highScore;
    }
  }

  set lives(int lives) {
    if (lives > 0) {
      _livesLeft = lives;
    }
  }

  set level(int level) {
    if (level > 0) {
      _currentLevel = level;
      _timeSinceStartOfLevelInSeconds = 0;
    }
  }

  /// getters
  ///

  int get getLivesLeft {
    return _livesLeft;
  }

  int get getCurrentLevel {
    return _currentLevel;
  }

  int get getTimeSinceStart {
    return _playSeconds;
  }

  int get getTimeSinceStartOfLevel {
    return _timeSinceStartOfLevelInSeconds;
  }

  int get getScore {
    return _score;
  }

  int get getHighScore {
    return _highScore;
  }

  void addBulletFired() {
    _shotsCount++;
  }

  void addBulletsFired(int numOfBullets) {
    if (numOfBullets > 0) {
      _shotsCount += numOfBullets;
    }
  }

  void addScorePoints(int points) {
    if (points > 0) {
      _score += points;
    }
  }

  void removeLife() {
    if (_livesLeft > 0) {
      _livesLeft--;
    }
    if (_livesLeft <= 0) {
      GameOverCommand().addToController(gameRef.controller);
    }
  }

  void addExtraLife() {
    _livesLeft++;
  }

  void addTimeTick() {
    if (!isActive) {
      return;
    }

    _playSeconds++;
    _timeSinceStartOfLevelInSeconds++;
  }

  void resetLevelTimer() {
    _timeSinceStartOfLevelInSeconds = 0;
  }

  void progressLevel() {
    _currentLevel++;
  }

  void stop() {
    isActive = false;
  }

  void reset() {
    _shotsCount = 0;
    _score = 0;
    _livesLeft = beginLives;
    _currentLevel = 0;
    _playSeconds = 0;
    _timeSinceStartOfLevelInSeconds = 0;

    isActive = true;
  }

  /// Overrides
  ///

  @override
  void render(Canvas canvas) {
    _livesLeftTextPaint.render(
      canvas,
      formatNumberOfLives(),
      Vector2(18, 16),
    );

    //
    // render the angle in radians for reference
    _scorePaint.render(
      canvas,
      'Current score: ${_score.toString()}',
      Vector2(gameRef.size.x - 150, 16),
    );

    //
    // render the angle in radians for reference
    _highScorePaint.render(
      canvas,
      'High score: ${_highScore.toString()}',
      Vector2(gameRef.size.x - 150, 35),
    );

    //
    // render the angle in radians for reference
    _shotsFiredPaint.render(
      canvas,
      'Number of launches: ${_shotsCount.toString()}',
      Vector2(18, 48),
    );

    //
    // render the angle in radians for reference
    _levelInfoPaint.render(
      canvas,
      formatLevelData(),
      Vector2(gameRef.size.x - 150, 55),
    );

    //
    // render the passage of time
    _passageOfTimePaint.render(
      canvas,
      'Game time: $_playSeconds',
      Vector2(gameRef.size.x - 150, 75),
    );
  }

  @override

  /// We are defining our own stringify method so that we can see our
  /// values when debugging.
  ///
  String toString() {
    return 'highScore: $_highScore , numOfShotsFired: $_shotsCount , '
        'score: $_score , livesLeft: $_livesLeft, currentLevel: $_currentLevel, '
        ' time since start: $_playSeconds, timer for this level: $_timeSinceStartOfLevelInSeconds  ';
  }

  /// Helper Methods
  ///
  String formatNumberOfLives() {
    if (_livesLeft > 0) {
      return 'Remaining life: $_livesLeft';
    } else {
      return "Game Over";
    }
  }

  String formatLevelData() {
    if (_currentLevel > 0) {
      return 'level: $_currentLevel';
    } else {
      return '';
    }
  }
}
