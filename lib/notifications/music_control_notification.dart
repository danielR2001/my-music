import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:myapp/main.dart';

class MusicControlNotification {
  static const platform = const MethodChannel('flutter.native/helper');

  static Future<bool> startService() async {
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
      print("making notification: "+title+" "+artist+" "+imageUrl+" $isPlaying");
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
            ? audioPlayerManager.pauseSong()
            : audioPlayerManager.resumeSong();
        break;
      case 'nextSong':
        audioPlayerManager.playNextSong();
        break;
      case 'prevSong':
        audioPlayerManager.playPreviousSong();
        break;
      default:
      // todo - throw not implemented
    }
  }
}
