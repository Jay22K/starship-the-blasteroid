import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'aboutUs.dart';
import 'game.dart';

class MainMenu extends StatelessWidget {
  static const routeName = '/main-menu';
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final example = SpaceshipGame();
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: const RiveAnimation.asset(
              'assets/animation/cosmos-transparent.riv',
              fit: BoxFit.fill,
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Starship The Blasteroid',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontFamily: 'Bruce-Forever',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => GameWidget(game: example)));
                      },
                      style: TextButton.styleFrom(
                        primary: Colors.amber,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        textStyle: TextStyle(
                          fontFamily: 'OtraMasStf',
                          fontSize: 30,
                        ),
                      ),
                      child: Text(
                        'Play',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: TextButton(
                      onPressed: () {
                        // Navigator.of(context).pushNamed(GamePlay.routeName);
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => AboutUs()));
                      },
                      style: TextButton.styleFrom(
                        primary: Colors.amber,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        textStyle: TextStyle(
                          fontFamily: 'OtraMasStf',
                          fontSize: 30,
                        ),
                      ),
                      child: Text(
                        'About Us',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
