import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/notification/music_control_notification.dart';
import 'package:path_provider/path_provider.dart';

enum PlaylistMode {
  shuffle,
  loop,
}

class PlayingNow {
  var dir;
  AudioPlayer advancedPlayer;
  AudioCache audioCache;
  Duration songDuration;
  Duration songPosition;
  Song currentSong;
  Playlist currentPlaylist;
  StreamSubscription<void> _onCompletestream;
  StreamSubscription<void> _onPosChangedstream;
  StreamSubscription<void> _onDurChangedstream;
  PlaylistMode playlistMode;

  PlayingNow() {
    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);
    songDuration = new Duration();
    songPosition = new Duration();
    AudioPlayer.logEnabled = false;
    initCacheDir();
  }

  void playSong(Song song) async {
    closeSong();
    currentSong = song;
    advancedPlayer.play(
        "https://cdns-preview-7.dzcdn.net/stream/c-7ddea0c2a4b20840f9d087df278336a4-5.mp3");
    //advancedPlayer.play(
    //   "${dir.path}/${song.getTitle}-${song.getArtist.getName}.mp3",
    //     isLocal: true);
    await MusicControlNotification.responseFromNativeCode(
        song.getTitle, song.getArtist.getName, song.getAlbum.getImageUrl, true);

    listenIfCompleted();
    updateSongPosition();
    getSongDuration();
  }

  void updateSongPosition() {
    _onPosChangedstream =
        advancedPlayer.onAudioPositionChanged.listen((duration) {
      songPosition = duration;
    });
  }

  void getSongDuration() {
    _onDurChangedstream = advancedPlayer.onDurationChanged.listen((duration) {
      songDuration = duration;
    });
  }

  void resumeSong() async {
    advancedPlayer.resume();
    await MusicControlNotification.responseFromNativeCode(currentSong.getTitle,
        currentSong.getArtist.getName, currentSong.getAlbum.getImageUrl, true);
  }

  void pauseSong() async {
    advancedPlayer.pause();
    await MusicControlNotification.responseFromNativeCode(currentSong.getTitle,
        currentSong.getArtist.getName, currentSong.getAlbum.getImageUrl, false);
  }

  void closeSong() {
    advancedPlayer.stop();
    releaseSong();
    if (_onCompletestream != null) {
      _onCompletestream.cancel();
      _onPosChangedstream.cancel();
      _onDurChangedstream.cancel();
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
        if (songFromPlaylist.getSongId == song.getSongId) {
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
    _onCompletestream = advancedPlayer.onPlayerCompletion.listen((a) {
      if (currentPlaylist != null) {
        if (playlistMode == PlaylistMode.loop) {
          playSong(getNextSong(currentPlaylist, currentSong));
        } else {
          playSong(getRandomSong(currentPlaylist, currentSong));
        }
      } else {
        playSong(currentSong);
      }
    });
  }

  Song getRandomSong(Playlist currentPlaylist, Song song) {
    var rnd = new Random();
    int pos = rnd.nextInt(currentPlaylist.getSongs.length);
    Song nextSong = currentPlaylist.getSongs[pos];
    while (nextSong.getSongId == song.getSongId) {
      pos = rnd.nextInt(currentPlaylist.getSongs.length);
      nextSong = currentPlaylist.getSongs[pos];
    }
    return nextSong;
  }

  void initCacheDir() async {
    dir = await getApplicationDocumentsDirectory();
  }
}
