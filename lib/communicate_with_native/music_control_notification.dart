import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/main.dart';
import 'package:myapp/ui/decorations/page_change_animation.dart';
import 'package:myapp/ui/pages/music_player_page.dart';

class MusicControlNotification {
  static const platform = const MethodChannel('flutter.native/helper');
  static BuildContext context;

  static Future<bool> startService(BuildContext cntxt) async {
    context = cntxt;
    bool response;
    try {
      final bool result = await platform.invokeMethod('startService');
      response = result;
      platform.setMethodCallHandler(myUtilsHandler);
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
      response = false;
    }
    return response;
  }

  static Future<bool> makeNotification(
      String title, String artist, String imageUrl, bool isPlaying) async {
    bool response;
    try {
      print("making notification: " +
          title +
          " " +
          artist +
          " " +
          imageUrl +
          " $isPlaying");
      final bool result = await platform.invokeMethod('makeNotification', {
        "title": title,
        "artist": artist,
        "imageUrl": imageUrl,
        "isPlaying": isPlaying,
      });
      response = result;
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
      response = false;
    }
    return response;
  }

  static Future<dynamic> myUtilsHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'playOrPause':
        audioPlayerManager.audioPlayer.state == AudioPlayerState.PLAYING
            ? audioPlayerManager.pauseSong(true)
            : audioPlayerManager.resumeSong(true);
        break;
      case 'nextSong':
        audioPlayerManager.playNextSong();
        break;
      case 'prevSong':
        audioPlayerManager.playPreviousSong();
        break;
      case 'openMusicplayerPage':
        Navigator.push(
          context,
          MyCustomRouteAnimation(builder: (context) => MusicPlayerPage()),
        );
        break;
      default:
      // todo - throw not implemented
    }
  }
}
