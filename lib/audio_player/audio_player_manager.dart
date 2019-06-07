import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/notifications/music_control_notification.dart';

enum PlaylistMode {
  shuffle,
  loop,
}

class AudioPlayerManager {
  AudioPlayer advancedPlayer;
  Song currentSong;
  Playlist currentPlaylist;
  Playlist shuffledPlaylist;
  Playlist loopPlaylist;
  StreamSubscription<void> _onCompleteStream;
  StreamSubscription<void> _onDurationStream;
  PlaylistMode playlistMode;
  bool isLoaded = false;

  AudioPlayerManager() {
    advancedPlayer = AudioPlayer();
    AudioPlayer.logEnabled = true;
  }
  Future initSong(
    Song song,
    Playlist playlist,
    PlaylistMode playlistMode,
  ) async {
    closeSong();
    this.playlistMode = playlistMode;
    if (playlist != null) {
      if (currentPlaylist != null) {
        if (currentPlaylist.getName != playlist.getName) {
          loopPlaylist = null;
          shuffledPlaylist = null;
        }
      }
      setCurrentPlaylist(playlist: playlist);
    } else {
      loopPlaylist = null;
      shuffledPlaylist = null;
      currentPlaylist = null;
    }
    currentSong = song;
    if (currentSong.getImageUrl == "") {
      String imageUrl = await FetchData.getSongImageUrl(currentSong);
      currentSong.setImageUrl = imageUrl;
    }
    MusicControlNotification.makeNotification(
        song.getTitle, song.getArtist, song.getImageUrl, true);
  }

  void playSong(String streamUrl) {
    if (streamUrl != null) {
      advancedPlayer.play(streamUrl);
      listenForDurationChanged();
      listenIfCompleted();
    }
  }

  void listenForDurationChanged() {
    _onDurationStream = advancedPlayer.onDurationChanged.listen((duration) {
      isLoaded = true;
    });
  }

  void resumeSong() {
    advancedPlayer.resume();
    MusicControlNotification.makeNotification(currentSong.getTitle,
        currentSong.getArtist, currentSong.getImageUrl, true);
  }

  void pauseSong() {
    advancedPlayer.pause();
    MusicControlNotification.makeNotification(currentSong.getTitle,
        currentSong.getArtist, currentSong.getImageUrl, false);
  }

  void closeSong() {
    advancedPlayer.stop();
    isLoaded = false;
    releaseSong();
    if (_onCompleteStream != null) {
      _onCompleteStream.cancel();
      _onDurationStream.cancel();
    }
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
    _onCompleteStream = advancedPlayer.onPlayerCompletion.listen((a) {
      if (currentPlaylist != null) {
        Song nextSong = getNextSong(currentPlaylist, currentSong);
        initSong(
          nextSong,
          currentPlaylist,
          playlistMode,
        );
        FetchData.getSongPlayUrlDefault(nextSong).then((streamUrl) {
          playSong(
            streamUrl,
          );
        });
      } else {
        initSong(
          currentSong,
          currentPlaylist,
          playlistMode,
        );
        FetchData.getSongPlayUrlDefault(currentSong).then((streamUrl) {
          playSong(
            streamUrl,
          );
        });
      }
    });
  }

  void playPreviousSong() {
    if (currentPlaylist != null) {
      int i = 0;
      Song correctPreviousSong;
      if (currentSong.getSongId == currentPlaylist.getSongs[0].getSongId) {
        initSong(
          currentPlaylist.getSongs[currentPlaylist.getSongs.length - 1],
          currentPlaylist,
          playlistMode,
        );
        FetchData.getSongPlayUrlDefault(
                currentPlaylist.getSongs[currentPlaylist.getSongs.length - 1])
            .then((streamUrl) {
          playSong(
            streamUrl,
          );
        });
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
        initSong(
          correctPreviousSong,
          currentPlaylist,
          playlistMode,
        );
        FetchData.getSongPlayUrlDefault(correctPreviousSong).then((streamUrl) {
          playSong(
            streamUrl,
          );
        });
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
      initSong(
        nextSong,
        currentPlaylist,
        playlistMode,
      );
      FetchData.getSongPlayUrlDefault(nextSong).then((streamUrl) {
        playSong(
          streamUrl,
        );
      });
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

  void setCurrentPlaylist({Playlist playlist}) {
    if (loopPlaylist == null) {
      loopPlaylist = playlist;
    }
    if (playlistMode == PlaylistMode.loop) {
      currentPlaylist = loopPlaylist;
    } else {
      if (shuffledPlaylist == null) {
        createShuffledPlaylist();
      }
      currentPlaylist = shuffledPlaylist;
    }
  }
}
