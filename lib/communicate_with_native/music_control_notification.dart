import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/main.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/decorations/page_change_animation.dart';
import 'package:myapp/ui/pages/music_player_page.dart';

class MusicControlNotification {
  static const platform = const MethodChannel('flutter.native/helper');
  static BuildContext context;

  static Future<bool> startService(BuildContext contxt) async {
    context = contxt;
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

  static Future<void> removeNotification() async {
    try {
      await platform.invokeMethod('removeNotification');
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
    }
  }

  static Future<bool> makeNotification(Song song, bool isPlaying) async {
    bool response;
    String localPath = "${ManageLocalSongs.fullSongImageDir.path}/${song.getSongId}.png";
    try {
      final bool result = await platform.invokeMethod('makeNotification', {
        "title": song.getTitle,
        "artist": song.getArtist,
        "imageUrl": song.getImageUrl,
        "isPlaying": isPlaying,
        "localPath": localPath,
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
            ? audioPlayerManager.pauseSong(false)
            : audioPlayerManager.audioPlayer.state == AudioPlayerState.PAUSED
                ? audioPlayerManager.resumeSong(false)
                : _playSong();
        break;
      case 'nextSong':
        if (audioPlayerManager.isLoaded) {
          audioPlayerManager.playNextSong();
        }
        break;
      case 'prevSong':
        if (audioPlayerManager.isLoaded) {
          audioPlayerManager.playPreviousSong();
        }
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

  static void _playSong() {
    audioPlayerManager.initSong(
      audioPlayerManager.currentSong,
      audioPlayerManager.currentPlaylist,
      audioPlayerManager.playlistMode,
    );
    audioPlayerManager.playSong();
  }
}
