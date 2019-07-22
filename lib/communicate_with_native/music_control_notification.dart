import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/models/song.dart';

class MusicControlNotification {
  static const platform = const MethodChannel('flutter.native/notifications');
  static BuildContext context;

  static Future<bool> startService(BuildContext contxt) async {
    context = contxt;
    bool response;
    try {
      final bool result = await platform.invokeMethod('startService');
      response = result;
      platform.setMethodCallHandler(_myUtilsHandler);
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
      response = false;
    }
    return response;
  }

  static Future<void> makeNotification(
      Song song, bool isPlaying, bool loadImage) async {
    String localPath =
        "${GlobalVariables.manageLocalSongs.fullSongDownloadDir.path}/${song.songId}/${song.songId}.png";
    print("making notification");
    try {
      await platform.invokeMethod('makeNotification', {
        "title": song.title,
        "artist": song.artist,
        "imageUrl": song.imageUrl,
        "isPlaying": isPlaying,
        "localPath": localPath,
        "loadImage": loadImage,
      });
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
    }
  }

  static Future<void> removeNotification() async {
    print("removing notification");
    try {
      await platform.invokeMethod('removeNotification');
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
    }
  }

  static Future<dynamic> _myUtilsHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'playOrPause':
        if (GlobalVariables.audioPlayerManager.isSongLoaded &&
            GlobalVariables.audioPlayerManager.isSongActuallyPlaying) {
          GlobalVariables.audioPlayerManager.audioPlayer.state ==
                  AudioPlayerState.PLAYING
              ? GlobalVariables.audioPlayerManager
                  .pauseSong(calledFromNative: false)
              : GlobalVariables.audioPlayerManager.audioPlayer.state ==
                      AudioPlayerState.PAUSED
                  ? GlobalVariables.audioPlayerManager
                      .resumeSong(calledFromNative: false)
                  : _playSong();
        }
        break;
      case 'nextSong':
        if (GlobalVariables.audioPlayerManager.isSongLoaded) {
          GlobalVariables.audioPlayerManager.playNextSong();
        }
        break;
      case 'prevSong':
        if (GlobalVariables.audioPlayerManager.isSongLoaded) {
          GlobalVariables.audioPlayerManager.playPreviousSong();
        }
        break;

      default:
    }
  }

  static void _playSong() {
    GlobalVariables.audioPlayerManager.initSong(
      song: GlobalVariables.audioPlayerManager.currentSong,
      playlist: GlobalVariables.audioPlayerManager.currentPlaylist,
      mode: GlobalVariables.audioPlayerManager.playlistMode,
    );
  }
}
