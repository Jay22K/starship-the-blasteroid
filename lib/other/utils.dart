import 'dart:math';

import 'package:flame/components.dart';

class Utils {
  /// randomly generated vectors
  static Vector2 randomVector() {
    Vector2 result;

    final Random rnd = Random();
    const int min = -1;
    const int max = 1;
    double numX = min + ((max - min) * rnd.nextDouble());
    double numY = min + ((max - min) * rnd.nextDouble());
    result = Vector2(numX, numY);

    return result;
  }

  /// Generate a random vector and add velocity, which is how many pixels you can move in one second
  static Vector2 randomSpeed({required double movePixels}) {
    return randomVector()..scale(movePixels);
  }

  /// Randomly generate a location
  static Vector2 generateRandomPosition({
    required Vector2 screenSize,
    Vector2? margins,
  }) {
    var result = Vector2.zero();
    var randomGenerator = Random();

    final marginX = (margins?.x ?? 0);
    final marginY = (margins?.y ?? 0);

    result = Vector2(
        randomGenerator
                .nextInt(screenSize.x.toInt() - 2 * marginX.toInt())
                .toDouble() +
            marginX,
        randomGenerator
                .nextInt(screenSize.y.toInt() - 2 * marginY.toInt())
                .toDouble() +
            marginY);

    return result;
  }

  //Randomly generate a vector and add a random velocity
  static Vector2 generateRandomVelocity(Vector2 screenSize, int min, int max) {
    var result = Vector2.zero();
    var randomGenerator = Random();
    double velocity;

    while (result == Vector2.zero()) {
      result = Vector2(
          (randomGenerator.nextInt(3) - 1) * randomGenerator.nextDouble(),
          (randomGenerator.nextInt(3) - 1) * randomGenerator.nextDouble());
    }
    result.normalize();
    velocity = (randomGenerator.nextInt(max - min) + min).toDouble();

    return result * velocity;
  }

  // Randomly generated vectors, represented by quadrants, with (0,0) in the middle
  static Vector2 generateRandomDirection() {
    var result = Vector2.zero();
    var randomGenerator = Random();

    while (result == Vector2.zero()) {
      result = Vector2(
          (randomGenerator.nextInt(3) - 1), (randomGenerator.nextInt(3) - 1));
    }

    return result;
  }

  // Randomly generate moving pixels based on the range, that is, how many pixels can be moved in one second
  static double generateRandomSpeed(int min, int max) {
    var randomGenerator = Random();
    double speed;

    speed = (randomGenerator.nextInt(max - min) + min).toDouble();

    return speed;
  }

  // Check whether the target position exceeds the screen boundary
  static bool isPositionOutOfBounds(Vector2 bounds, Vector2 position) {
    bool result = false;

    if (position.x < 0 || position.x > bounds.x) {
      result = true;
    }

    if (position.y < 0 || position.y > bounds.y) {
      result = true;
    }

    return result;
  }

/// Ensure that objects are on the screen and within the frame
   /// If it goes beyond the screen, it will appear from the other side
  static Vector2 wrapPosition(Vector2 bounds, Vector2 position) {
    Vector2 result = position;

    if (position.x >= bounds.x) {
      result.x = 0;
    } else if (position.x <= 0) {
      result.x = bounds.x;
    }

    if (position.y >= bounds.y) {
      result.y = 0;
    } else if (position.y <= 0) {
      result.y = bounds.y;
    }

    return result;
  }

  static Vector2 vector2Multiply(Vector2 v1, Vector2 v2) {
    v1.multiply(v2);
    return v1;
  }
}
