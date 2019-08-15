import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/custom_classes/custom_colors.dart';
import 'package:myapp/models/song.dart';

class NativeCommunicationService {
  static final MethodChannel _channel =
      const MethodChannel('com.daniel/myMusic')
        ..setMethodCallHandler(_handlePlatformCalls);
  static BuildContext context;

  static Future<void> startService() async {
    print("starting service");
    try {
      await _channel.invokeMethod('startService');
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
    }
  }

  static Future<void> makeNotification(
      Song song, bool isPlaying, bool loadImage) async {
    String imageUrl;
    bool isLocal =
        await GlobalVariables.manageLocalSongs.checkIfImageFileExists(song);
    if (isLocal) {
      imageUrl =
          "${GlobalVariables.manageLocalSongs.fullSongDownloadDir.path}/${song.songId}/${song.songId}.png";
    } else {
      imageUrl = song.imageUrl;
    }
    print("making notification");
    try {
      await _channel.invokeMethod('makeNotification', {
        "title": song.title,
        "artist": song.artist,
        "imageUrl": imageUrl,
        "isPlaying": isPlaying,
        "isLocal": isLocal,
        "loadImage": loadImage,
      });
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
    }
  }

  static Future<void> removeNotification() async {
    print("removing notification");
    try {
      await _channel.invokeMethod('removeNotification');
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
    }
  }

  static Future<String> getDominantColor(
      {String imagePath, bool isLocal}) async {
    String response;
    print("getting dominantColor");
    try {
      String result = await _channel.invokeMethod('getDominantColor', {
        "imagePath": imagePath,
        "isLocal": isLocal,
      });
      response = result;
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
      response = null;
    }
    return response;
  }

  static Future<dynamic> _handlePlatformCalls(MethodCall methodCall) async {
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
