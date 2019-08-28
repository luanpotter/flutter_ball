import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_ball/flutterball_game.dart';
import 'package:flutter_ball/components/text.dart';
import 'package:flutter_ball/components/game_play.dart';

const double SPLASH_TIME = 5.0;

void addLaunchMessage(FlutterballGame game, GamePlay gp) {
  TextStyle messageStyle = TextStyle(fontSize: 15, color: Colors.white);
  TextSpan messageSpan = TextSpan(text: "Level ${game.level} Launch...", style: messageStyle);
  gp.launchMessage = TextDraw(Rect.fromLTWH(0, gp.height*0.4, gp.width, 50), messageSpan,
    boxColor: null, borderColor: null,
  );
  game.add(gp.launchMessage);
}

// set up splash screen for completed level
void makeCompletedSplash(FlutterballGame game, GamePlay gp) {
  game.clearComponents();
  TextStyle messageStyle = TextStyle(fontSize: 20, color: Colors.blue);
  TextSpan messageSpan = TextSpan(text: "Good Job!\n\n\nYou Finished\nLevel ${game.level}", style: messageStyle);
  TextDraw message = TextDraw(Rect.fromLTWH(0, 0, gp.width, gp.height), messageSpan,
    boxColor: null, borderColor: null,
  );

  game.add(message);
  gp.splashOver = game.currentTime() + 3.0;
}

// set up splash screen for lost game
void makeLoseSplashScreen(FlutterballGame game, GamePlay gp) {
  game.clearComponents();
  TextStyle messageStyle = TextStyle(fontSize: 20, color: Colors.blue);
  TextSpan messageSpan = TextSpan(text: "You Lose!\n\n\nGame Over", style: messageStyle);
  TextDraw message = TextDraw(Rect.fromLTWH(0, 0, gp.width, gp.height), messageSpan,
    boxColor: null, borderColor: null,
  );
  game.add(message);
  gp.splashOver = game.currentTime() + SPLASH_TIME;
}
