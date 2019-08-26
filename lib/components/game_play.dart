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
  double sizeX=0;  // size of the screen in the x direction
  double sizeY=0;  // size of the screen in the y direction
  double splashOver;  // when to stop showing splash screen
  int ballsLeft = 0;
  Paint paint = Paint();  // paint the lines showing sides not ignored
  TextDraw ballsLeftMessage;  // show balls left for current level
  int ballBounces = 10;  // how many bounces new ball gets
  TextDraw bouncesLeftMessage;  // show bounces left for current ball
  TextDraw launchMessage;  // tell player to launch the ball
  InteractiveBallReleaser launcher;  // ball launcher
  double speedScale=0.0;  // speed of launch

  // constructor
  GamePlay(this.game, ) : super() {
    paint.color = Colors.white;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
  }

  // while game is playing, see if level is over and set status accordingly
  // - player wins level
  // - player loses level
  // - player needs to launch new ball
  void checkPlay() {
    // count the number of blocks and balls on screen
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
        print("state = splash");
      } else {
        // reached last level
        state = GameState.OVER;
      }
    } else if (ball == null && ballsLeft <= 0) {  // no more balls left
      print("no more ball: ballsLeft=$ballsLeft");
      state = GameState.LOST;
      print("state = lost");
      makeLoseSplashScreen(game,this);
    } else if (ball == null) {  // still balls left to launch
      print("no more ball: ballsLeft=$ballsLeft");
      // need to launch another ball, but don't put up a splash screen
      updateBouncesLeftMessage(this,0);
      state = GameState.BALL_OVER;  // launch new ball
      print("state = ball over");
    } else {
      // still playing, so get the count for the total bounces left
      updateBallsLeftMessage(this);
      updateBouncesLeftMessage(this, ball.lives);
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
        print("state = splash");
        break;
      case GameState.SPLASH:
      case GameState.BALL_OVER:
        if (game.currentTime() > splashOver) {
          // put up level screen if we just put up splash screen
          if (state == GameState.SPLASH) {
            makeLevel(game,this);
            addBallsLeftMessage(game,this);
            addBouncesLeftMessage(game,this);
          }

          // add component that launches the ball
          launcher = InteractiveBallReleaser(game, lives: ballBounces, speedScale: speedScale);
          game.add(launcher);
          addLaunchMessage(game,this);
          state = GameState.LAUNCHING;
          print("state = launching");
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
          print("state = playing");
        }
        break;
      case GameState.PLAYING:
        checkPlay();  // check if anything is over
        break;
      case GameState.LOST:
      case GameState.OVER:
        if (game.currentTime() > splashOver) {
          // down showing lose screen
          // go back to start screen
          game.clearComponents();
          GameIntro gameIntro = GameIntro(game);
          game.add(gameIntro);
          state = GameState.DEAD;
          print("state = dead");
        }
        break;
      default:
    }
  }

  bool destroy() => state == GameState.DEAD;

  void resize(Size size) {
    if (size.width <= 0) return;

    // save screen width and height
    sizeX = size.width;
    sizeY = size.height;
    state = GameState.STARTING;
    print("state = starting");
  }

  void render(Canvas c) {
    if (state == GameState.LAUNCHING || state == GameState.PLAYING) {
      // draw lines showing which sides are ignored
    }
  }

}