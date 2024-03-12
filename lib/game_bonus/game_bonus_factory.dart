import 'package:spaceship_game/game_bonus/game_bonus.dart';
import 'package:spaceship_game/game_bonus/game_bonus_build_context.dart';

class GameBonusFactory {
  GameBonusFactory._();

  static GameBonus? create(GameBonusBuildContext context) {
    GameBonus? result;

    switch (context.gameBonusType) {
      case GameBonusEnum.ufoBonus:
        {
          if (context.size != GameBonusBuildContext.defaultSize) {
            result = UFOGameBonus.fullInit(
                context.position,
                context.velocity,
                context.size,
                context.timeTriggerSeconds,
                context.speed,
                context.health,
                context.damage);
          } else {
            result = UFOGameBonus(
              context.position,
              context.velocity,
              context.timeTriggerSeconds,
            );
          }
        }
        break;
    }

    return result;
  }
}
