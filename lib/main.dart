import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spaceship_game/game.dart';

import 'mainMenu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Flame.device.setLandscape();
  await Flame.device.fullScreen();

  final example = SpaceshipGame();

  runApp(
    MaterialApp(
      home: const MainMenu(),
    ),
  );
}
