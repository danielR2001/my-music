import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';

class PlayingNow {
  AudioPlayer advancedPlayer;
  AudioCache audioCache;
  Duration songDuration;
  Duration songPosition;
  Song currentSong;
  Playlist currentPlaylist;
  StreamSubscription<void> _stream;

  PlayingNow() {
    advancedPlayer = new AudioPlayer();
    audioCache = audioCache = new AudioCache(fixedPlayer: advancedPlayer);
    songDuration = new Duration();
    songPosition = new Duration();
  }

  void playSong(Song song) {
    closeSong();
    currentSong = song;
    advancedPlayer.play(currentSong.getSongUrl);
    listenIfCompleted();
  }

  void resumeSong() {
    advancedPlayer.resume();
  }

  void pauseSong() {
    advancedPlayer.pause();
  }

  void closeSong() {
    advancedPlayer.stop();
    releaseSong();
    if (_stream != null) {
      _stream.cancel();
    }
    currentSong = null;
  }

  void releaseSong() {
    advancedPlayer.release();
  }

  void seekTime(Duration duration) {
    advancedPlayer.seek(duration);
  }

  Song getNextSong(Playlist playlist, Song song) {
    bool foundSong = false;
    Song nextSong;
    playlist.getSongs.forEach(
      (songFromPlaylist) {
        if (foundSong) {
          nextSong = songFromPlaylist;
          foundSong = false;
        }
        if (songFromPlaylist.getSongUrl == song.getSongUrl) {
          foundSong = true;
        }
      },
    );
    if (foundSong && nextSong == null) {
      nextSong = playlist.getSongs[0];
    }
    return nextSong;
  }

  void listenIfCompleted() {
    _stream = advancedPlayer.onPlayerCompletion.listen((a) {
      if (currentPlaylist != null) {
        playSong(getNextSong(currentPlaylist, currentSong));
      } else {
        playSong(currentSong);
      }
    });
  }
}
