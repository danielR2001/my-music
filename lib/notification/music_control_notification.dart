import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/song.dart';

class MusicControlNotification {
  static const platform = const MethodChannel('flutter.native/helper');

  static Future<bool> responseFromNativeCode(
      String title, String artist, String imageUrl, bool isPlaying) async {
    bool response;
    try {
      final bool result = await platform.invokeMethod('makeNotification', {
        "title": title,
        "artist": artist,
        "imageUrl": imageUrl,
        "isPlaying": isPlaying
      });
      response = result;
      platform.setMethodCallHandler(myUtilsHandler);
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
      response = false;
    }
    return response;
  }

  static Future<dynamic> myUtilsHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'playOrPause':
        playingNow.advancedPlayer.state == AudioPlayerState.PLAYING
            ? playingNow.pauseSong()
            : playingNow.resumeSong();
        break;
      case 'nextSong':
        playNextSong();
        break;
      case 'prevSong':
        playPreviousSong();
        break;
      default:
      // todo - throw not implemented
    }
  }

  static void playPreviousSong() {
    if (playingNow.currentPlaylist != null) {
      int i = 0;
      Song correctPreviousSong;
      if (playingNow.currentSong.getSongId ==
          playingNow.currentPlaylist.getSongs[0].getSongId) {
        playingNow.playSong(playingNow.currentPlaylist
            .getSongs[playingNow.currentPlaylist.getSongs.length - 1]);
      } else {
        Song previousSong = playingNow.currentPlaylist.getSongs[0];
        playingNow.currentPlaylist.getSongs.forEach((song) {
          if (i != 0) {
            if (song.getSongId == playingNow.currentSong.getSongId) {
              correctPreviousSong = previousSong;
            } else {
              previousSong = song;
            }
          }
          i++;
        });
        playingNow.playSong(correctPreviousSong);
      }
    }
  }

  static void playNextSong() {
    if (playingNow.currentPlaylist != null) {
      bool foundSong = false;
      Song nextSong;
      playingNow.currentPlaylist.getSongs.forEach((song) {
        if (foundSong) {
          nextSong = song;
          foundSong = false;
        }
        if (song.getSongId == playingNow.currentSong.getSongId) {
          foundSong = true;
        }
      });
      if (nextSong == null && foundSong) {
        nextSong = playingNow.currentPlaylist.getSongs[0];
      }
      playingNow.playSong(nextSong);
    }
  }
}
