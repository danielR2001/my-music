import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/notifications/music_control_notification.dart';

enum PlaylistMode {
  shuffle,
  loop,
}

class AudioPlayerManager {
  AudioPlayer advancedPlayer;
  Duration songDuration;
  Duration songPosition;
  Song currentSong;
  Playlist currentPlaylist;
  Playlist shuffledPlaylist;
  Playlist loopPlaylist;
  StreamSubscription<void> _onCompletestream;
  StreamSubscription<void> _onPosChangedstream;
  StreamSubscription<void> _onDurChangedstream;
  PlaylistMode playlistMode;

  AudioPlayerManager() {
    advancedPlayer = AudioPlayer();
    songDuration = Duration();
    songPosition = Duration();
    AudioPlayer.logEnabled = false;
  }

  void playSong(Song song,
      {Playlist playlist, PlaylistMode playlistMode}) async {
    closeSong();
    this.playlistMode = playlistMode;
    loopPlaylist = playlist;
    if (this.playlistMode == PlaylistMode.loop) {
      currentPlaylist = loopPlaylist;
    } else {
      createShuffledPlaylist();
      currentPlaylist = shuffledPlaylist;
    }
    currentSong = song;
    advancedPlayer.play(song.getStreamUrl);
    await MusicControlNotification.responseFromNativeCode(
        song.getTitle, song.getArtist, song.getImageUrl, true);

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
        currentSong.getArtist, currentSong.getImageUrl, true);
  }

  void pauseSong() async {
    advancedPlayer.pause();
    await MusicControlNotification.responseFromNativeCode(currentSong.getTitle,
        currentSong.getArtist, currentSong.getImageUrl, false);
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
        playSong(getNextSong(currentPlaylist, currentSong));
      } else {
        playSong(currentSong);
      }
    });
  }

  void playPreviousSong() {
    if (currentPlaylist != null) {
      int i = 0;
      Song correctPreviousSong;
      if (currentSong.getSongId == currentPlaylist.getSongs[0].getSongId) {
        playSong(currentPlaylist.getSongs[currentPlaylist.getSongs.length - 1]);
      } else {
        Song previousSong = currentPlaylist.getSongs[0];
        currentPlaylist.getSongs.forEach((song) {
          if (i != 0) {
            if (song.getSongId == currentSong.getSongId) {
              correctPreviousSong = previousSong;
            } else {
              previousSong = song;
            }
          }
          i++;
        });
        playSong(correctPreviousSong);
      }
    }
  }

  void playNextSong() {
    if (currentPlaylist != null) {
      bool foundSong = false;
      Song nextSong;
      currentPlaylist.getSongs.forEach((song) {
        if (foundSong) {
          nextSong = song;
          foundSong = false;
        }
        if (song.getSongId == currentSong.getSongId) {
          foundSong = true;
        }
      });
      if (nextSong == null && foundSong) {
        nextSong = currentPlaylist.getSongs[0];
      }
      playSong(nextSong);
    }
  }

  void createShuffledPlaylist() {
    List<Song> shuffledlist = List();
    List<int> randomPosList = createRandomPosList();
    int pos = 0;
    while (shuffledlist.length != loopPlaylist.getSongs.length) {
      shuffledlist.add(loopPlaylist.getSongs[randomPosList[pos]]);
      pos++;
    }
    shuffledPlaylist = Playlist(loopPlaylist.getName);
    shuffledPlaylist.setSongs = shuffledlist;
  }

  List<int> createRandomPosList() {
    List<int> randomPosList = List();
    var rnd = Random();
    int pos;
    while (randomPosList.length != loopPlaylist.getSongs.length) {
      pos = rnd.nextInt(loopPlaylist.getSongs.length);
      if (!randomPosList.contains(pos)) {
        randomPosList.add(pos);
      }
    }
    return randomPosList;
  }

  void setCurrentPlaylist() {
    if (playlistMode == PlaylistMode.loop) {
      currentPlaylist = loopPlaylist;
    } else {
      createShuffledPlaylist();
      currentPlaylist = shuffledPlaylist;
    }
  }
}
