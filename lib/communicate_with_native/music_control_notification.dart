import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/main.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/decorations/page_change_animation.dart';
import 'package:myapp/ui/pages/music_player_page.dart';

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

  static Future<bool> makeNotification(
      Song song, bool isPlaying, bool loadImage) async {
    bool response;
    String localPath =
        "${ManageLocalSongs.fullSongDownloadDir.path}/${song.getSongId}/${song.getSongId}.png";
    print("making notification");
    try {
      final bool result = await platform.invokeMethod('makeNotification', {
        "title": song.getTitle,
        "artist": song.getArtist,
        "imageUrl": song.getImageUrl,
        "isPlaying": isPlaying,
        "localPath": localPath,
        "loadImage": loadImage,
      });
      response = result;
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
      response = false;
    }
    return response;
  }

  static Future<dynamic> _myUtilsHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'playOrPause':
        if (audioPlayerManager.isLoaded &&
            audioPlayerManager.songPosition != Duration(milliseconds: 0)) {
          audioPlayerManager.audioPlayer.state == AudioPlayerState.PLAYING
              ? audioPlayerManager.pauseSong(calledFromNative: false)
              : audioPlayerManager.audioPlayer.state == AudioPlayerState.PAUSED
                  ? audioPlayerManager.resumeSong(calledFromNative: false)
                  : _playSong();
        }
        break;
      case 'nextSong':
        if (audioPlayerManager.isLoaded &&
            audioPlayerManager.songPosition != Duration(milliseconds: 0)) {
          audioPlayerManager.playNextSong();
        }
        break;
      case 'prevSong':
        if (audioPlayerManager.isLoaded &&
            audioPlayerManager.songPosition != Duration(milliseconds: 0)) {
          audioPlayerManager.playPreviousSong(false);
        }
        break;
      case 'openMusicplayerPage':
        Navigator.push(
          context,
          MyCustomRouteAnimation(builder: (context) => MusicPlayerPage()),
        );
        break;
      default:
    }
  }

  static void _playSong() {
    audioPlayerManager.initSong(
      song: audioPlayerManager.currentSong,
      playlist: audioPlayerManager.currentPlaylist,
      playlistMode: audioPlayerManager.playlistMode,
    );
  }
}
