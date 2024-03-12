import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import './controller.dart';
import 'command/command.dart';

class SpaceshipGame extends FlameGame
    with TapDetector, HasCollisionDetection, KeyboardEvents {
  /// 管理者，掌握遊戲內的元件與操作
  late final Controller controller;

  Vector2 keyboardDirection = Vector2.all(0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    loadResources();
    await addGameController();
  }

  @override
  void onTap() {
    UserTapUpCommand(controller.getSpaceship()).addToController(controller);

    super.onTap();
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is RawKeyDownEvent;

    final isDownSpace = keysPressed.contains(LogicalKeyboardKey.space);
    final isDownLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isDownRight = keysPressed.contains(LogicalKeyboardKey.arrowRight);
    final isDownUp = keysPressed.contains(LogicalKeyboardKey.arrowUp);
    final isDownDown = keysPressed.contains(LogicalKeyboardKey.arrowDown);

    if (isKeyDown) {
      if (isDownSpace) {
        BulletFiredCommand().addToController(controller);
      }

      if (isDownLeft && isDownUp) {
        keyboardDirection = Vector2(-1, -1);
      } else if (isDownLeft && isDownDown) {
        keyboardDirection = Vector2(-1, 1);
      } else if (isDownRight && isDownUp) {
        keyboardDirection = Vector2(1, -1);
      } else if (isDownRight && isDownDown) {
        keyboardDirection = Vector2(1, 1);
      } else if (isDownLeft) {
        keyboardDirection = Vector2(-1, 0);
      } else if (isDownRight) {
        keyboardDirection = Vector2(1, 0);
      } else if (isDownUp) {
        keyboardDirection = Vector2(0, -1);
      } else if (isDownDown) {
        keyboardDirection = Vector2(0, 1);
      }

      return KeyEventResult.handled;
    }

    keyboardDirection = Vector2(0, 0);

    return KeyEventResult.handled;
  }

  /// Cache and preload the assets
  void loadResources() async {
    await images.load('boom.png');
  }

  Future<void> addGameController() async {
    controller = Controller();
    add(controller);

    await controller.init();
  }
}
