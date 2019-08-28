import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_ball/flutterball_game.dart';
import 'package:flutter_ball/game_levels.dart';
import 'package:flutter_ball/game_text.dart';
import 'package:flame/components/component.dart';
import 'package:flutter_ball/components/block.dart';
import 'package:flutter_ball/components/ball.dart';
import 'package:flutter_ball/components/interactive_ball_releaser.dart';
import 'package:flutter_ball/components/game_intro.dart';
import 'package:flutter_ball/components/text.dart';

enum GameState {
  WAITING,  // waiting for screen size info
  STARTING, // putting up the game blocks
  SPLASH,  // showing splash screen
  LAUNCHING,// launching new ball
  PLAYING,// playing game
  BALL_OVER,  // ball is done, need to use next one
  COMPLETED, // completed level
  LOST, // no more balls but still blocks
  LEVEL, // showing level screen
  OVER, // game over screen
  DEAD, // destroy component
}

class GamePlay extends Component {
  // constants
  static const int MAX_LEVELS = 10;
  static const double BALL_SIZE = 5.0;
  static const PaintingStyle BALL_STYLE = PaintingStyle.fill;

  // instance variables
  final FlutterballGame game;
  GameState state = GameState.WAITING;
  double width=0;  // size of the screen in the x direction
  double height=0;  // size of the screen in the y direction
  double splashOver;  // when to stop showing splash screen
  int ballsLeft = 0;  // how many balls the player gets in the level
  int ballBounces = 1;  // how many bounces each ball gets
  TextDraw launchMessage;  // tell player to launch the ball
  InteractiveBallReleaser launcher;  // ball launcher
  double speedScale=0.0;  // speed of launch

  // constructor
  GamePlay(this.game, ) : super() {
  }

  // while game is playing, see if level is over and set status accordingly
  // - player wins level
  // - player loses level
  // - player needs to launch new ball
  void checkPlay() {
    // check for blocks and balls on screen
    Block block; // found a block that ball can bounce on
    Ball ball;  // found a ball that is bouncing

    game.components.forEach((c) {
      if (c is Block) {
        if (!c.draggableBlock) {
          block = c;  // found a game block
        }
      } else if (c is Ball) {
        ball = c;
      }
    });

    if (block == null) {
      // level cleared
      makeCompletedSplash(game,this);
      if (game.level < MAX_LEVELS) {
        game.level++;  // go to next level
        state = GameState.COMPLETED;  // wait for splash
      } else {
        // reached last level
        state = GameState.OVER;
      }
    } else if (ball == null && ballsLeft <= 0) {  // no more balls left
      state = GameState.LOST;
      makeLoseSplashScreen(game,this);
    } else if (ball == null) {  // still balls left to launch
      // need to launch another ball, but don't put up a splash screen
      state = GameState.BALL_OVER;  // launch new ball
    } else {
    }
  }

  // check if ball has been launched yet
  bool checkLaunch() {
    bool launched = false;
    game.components.forEach((c) {
      if (c is Ball) {
        Ball ball = c;
        launched = true;  // found a bouncing one
      }
    });
    return launched;
  }

  void update(double t) {
    switch (state) {
      case GameState.STARTING:
        // put up level splash screen
        makeLevelSplashScreen(game,this);
        splashOver = game.currentTime() + SPLASH_TIME;
        state = GameState.SPLASH;
        break;
      case GameState.SPLASH:
      case GameState.BALL_OVER:
        if (game.currentTime() > splashOver) {
          // put up level screen if we just put up splash screen
          if (state == GameState.SPLASH) {
            makeLevel(game,this);
          }

          // add component that launches the ball
          launcher = InteractiveBallReleaser(game, speedScale: speedScale, lives: ballBounces);
          game.add(launcher);
          addLaunchMessage(game,this);
          state = GameState.LAUNCHING;
        }
        break;
      case GameState.COMPLETED:
        if (game.currentTime() > splashOver) {
          // restart next level
          state = GameState.STARTING;
        }
        break;
      case GameState.LAUNCHING:
        // see if ball launched yet
        if (checkLaunch()) {
          ballsLeft--;
          launchMessage.lives = 0;  // remove launch message
          launcher.lives = 0;  // remove launcher
          state = GameState.PLAYING;
        }
        break;
      case GameState.PLAYING:
        checkPlay();  // check if anything is over
        break;
      case GameState.LOST:
      case GameState.OVER:
        if (game.currentTime() > splashOver) {
          // done showing lose screen
          // go back to start screen
          game.clearComponents();
          GameIntro gameIntro = GameIntro(game);
          game.add(gameIntro);
          state = GameState.DEAD;
        }
        break;
      default:
    }
  }

  bool destroy() => state == GameState.DEAD;

  void resize(Size size) {
    if (size.width <= 0) return;

    // save screen width and height
    width = size.width;
    height = size.height;
    state = GameState.STARTING;
  }

  void render(Canvas c) {
  }

}