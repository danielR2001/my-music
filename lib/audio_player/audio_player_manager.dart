import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/communicate_with_native/music_control_notification.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/toast_manager/toast_manager.dart';
import 'package:provider/provider.dart';

enum PlaylistMode {
  shuffle,
  loop,
}
enum PreviousMode {
  restart,
  previous,
}
enum CloseSongMode {
  completely,
  partly,
}

class AudioPlayerManager {
  AudioPlayer audioPlayer;
  Song currentSong;
  Playlist currentPlaylist;
  Playlist shuffledPlaylist;
  Playlist loopPlaylist;
  PlaylistMode playlistMode;
  Duration songDuration;
  Duration songPosition;
  bool isSongLoaded;
  bool isSongActuallyPlaying;
  PreviousMode previousMode;
  AudioPlayerState audioPlayerState;

  String _songStreamUrl;
  Song _firstSkippedSong;
  StreamSubscription<void> _audioPlayerOnCompleteStream;
  StreamSubscription<void> _audioPlayerOnDurationChangedStream;
  StreamSubscription<void> _audioPlayerOnPositionChangedStream;
  StreamSubscription<void> _audioPlayerOnStateChangedStream;

  AudioPlayerManager() {
    audioPlayer = AudioPlayer();
    previousMode = PreviousMode.restart;
    isSongLoaded = true;
    // AudioPlayer.logEnabled = true;
    audioPlayer.setReleaseMode(ReleaseMode.STOP);
    _listenForErrors();
    _listenForDurationChanged();
    _listenForPositionChanged();
    _listenIfCompleted();
    _listenForStateChanges();
  }
  //! TODO isSongActuallyPlaying notify
  Future<void> initSong(
      {@required Song song,
      @required Playlist playlist,
      @required PlaylistMode mode}) async {
    closeSong(closeSongMode: CloseSongMode.partly);
    isSongLoaded = false;
    isSongActuallyPlaying = false;
    previousMode = PreviousMode.restart;
    currentSong = song;
    songPosition = Duration(seconds: 0);

    Provider.of<PageNotifier>(GlobalVariables.homePageContext).setCurrentSong =
        song;

    if (song.imageUrl == "") {
      if (GlobalVariables.isNetworkAvailable) {
        GlobalVariables.apiService
            .getSongImageUrl(song, false)
            .then((imageUrl) {
          if (imageUrl != null) {
            song.setImageUrl = imageUrl;
            if (song.title == currentSong.title) {
              currentSong = song;
              if (audioPlayer.state == AudioPlayerState.PLAYING) {
                MusicControlNotification.makeNotification(
                    currentSong, true, true);
              } else {
                MusicControlNotification.makeNotification(
                    currentSong, false, true);
              }
            }
          }
        });
      }
    }
    if (GlobalVariables.isNetworkAvailable) {
      GlobalVariables.apiService.getLyricsPageUrl(song).then((url) {
        if (url != null) {
          GlobalVariables.apiService.getSongLyrics(url).then((lyrics) {
            if (lyrics != null) {
              song.setLyrics = lyrics;
              if (song.title == currentSong.title) {
                currentSong = song;
              }
            }
          });
        }
      });
    }

    playlistMode = mode;
    if (playlist != null) {
      if (currentPlaylist != null &&
          currentPlaylist != playlist &&
          loopPlaylist != playlist) {
        loopPlaylist = null;
        shuffledPlaylist = null;
      }
      setCurrentPlaylist(playlist: playlist);
    } else {
      loopPlaylist = null;
      shuffledPlaylist = null;
      currentPlaylist = null;
    }
    bool readyToPlay = await _checkIfReadyToPlay();
    if (readyToPlay) {
      _firstSkippedSong = null;
      _playSong();
    } else if (GlobalVariables.isNetworkAvailable) {
      if (_firstSkippedSong == null) {
        _firstSkippedSong = song;
        playNextSong();
      } else {
        if (song.songId != _firstSkippedSong.songId) {
          playNextSong();
        } else {
          isSongLoaded = true;
          songPosition = null;
          _firstSkippedSong = null;
          MusicControlNotification.makeNotification(currentSong, false, true);
        }
      }
    } else {
      isSongLoaded = true;
      songPosition = null;
      MusicControlNotification.makeNotification(currentSong, false, true);
    }
  }

  Future _playSong() async {
    int audioPlayerStatus;
    bool exists = await GlobalVariables.manageLocalSongs
        .checkIfSongFileExists(currentSong);
    if (exists &&
        GlobalVariables.currentUser
            .songExistsInDownloadedPlaylist(currentSong)) {
      audioPlayerStatus = await audioPlayer.play(
        "${GlobalVariables.manageLocalSongs.fullSongDownloadDir.path}/${currentSong.songId}/${currentSong.songId}.mp3",
        stayAwake: true,
        respectAudioFocus: true,
      );
    } else {
      audioPlayerStatus = await audioPlayer.play(
        _songStreamUrl,
        stayAwake: true,
        respectAudioFocus: true,
      );
    }
    if (audioPlayerStatus == 1) {
      MusicControlNotification.makeNotification(currentSong, true, true);
      isSongLoaded = true; //! TODO actual song loaded
    } else {
      closeSong(closeSongMode: CloseSongMode.partly);
      isSongLoaded = true;
      songPosition = null;
      MusicControlNotification.makeNotification(currentSong, false, true);
    }
  }

  void resumeSong({@required bool calledFromNative}) {
    audioPlayer.resume();
    if (!calledFromNative) {
      MusicControlNotification.makeNotification(currentSong, true, false);
    }
  }

  void pauseSong({@required bool calledFromNative}) {
    audioPlayer.pause();
    if (!calledFromNative) {
      MusicControlNotification.makeNotification(currentSong, false, false);
    }
  }

  void closeSong({@required CloseSongMode closeSongMode}) {
    if (closeSongMode != null) {
      if (closeSongMode == CloseSongMode.completely) {
        currentSong = null;
        currentPlaylist = null;
        loopPlaylist = null;
        shuffledPlaylist = null;
        audioPlayer.stop();
        audioPlayer.release();
        _audioPlayerOnCompleteStream.cancel();
        _audioPlayerOnDurationChangedStream.cancel();
        _audioPlayerOnPositionChangedStream.cancel();
        _audioPlayerOnStateChangedStream.cancel();
      } else if (closeSongMode == CloseSongMode.partly) {
        audioPlayer.stop();
        audioPlayer.release();
      }
    } else {
      audioPlayer.pause();
    }
  }

  void seekTime({@required Duration duration}) {
    audioPlayer.seek(duration);
  }

  void playPreviousSong() {
    if (previousMode == PreviousMode.previous) {
      if (currentPlaylist != null) {
        int i = 0;
        Song correctPreviousSong;
        Song previousSong;
        if (currentPlaylist.songs.length > 1) {
          if (currentSong.songId == currentPlaylist.songs[0].songId) {
            correctPreviousSong =
                currentPlaylist.songs[currentPlaylist.songs.length - 1];
          }
          previousSong = currentPlaylist.songs[0];
          currentPlaylist.songs.forEach((song) {
            if (i != 0) {
              if (song.songId == currentSong.songId) {
                correctPreviousSong = previousSong;
              } else {
                previousSong = song;
              }
            }
            i++;
          });
        } else {
          correctPreviousSong = currentSong;
          songDuration = Duration(seconds: 0);
          seekTime(duration: songDuration);
        }
        if (GlobalVariables.isNetworkAvailable) {
          pauseSong(calledFromNative: false);
        } else {
          closeSong(closeSongMode: CloseSongMode.partly);
        }
        initSong(
          song: correctPreviousSong,
          playlist: currentPlaylist,
          mode: playlistMode,
        );
      }
    } else {
      previousMode = PreviousMode.previous;
      if (GlobalVariables.isNetworkAvailable) {
        songPosition = Duration(seconds: 0);
        audioPlayer.seek(songPosition);
        if (audioPlayer.state == AudioPlayerState.PAUSED) {
          resumeSong(calledFromNative: false);
        }
      } else {
        playPreviousSong();
      }
    }
  }

  void playNextSong() {
    if (currentPlaylist != null) {
      bool foundSong = false;
      Song nextSong;

      if (currentPlaylist.songs.length > 1) {
        currentPlaylist.songs.forEach((song) {
          if (foundSong) {
            nextSong = song;
            foundSong = false;
          }
          if (song.songId == currentSong.songId) {
            foundSong = true;
          }
        });
      } else {
        nextSong = currentSong;
        foundSong = true;
        songDuration = Duration(seconds: 0);
        seekTime(duration: songDuration);
      }
      if (nextSong == null && foundSong) {
        nextSong = currentPlaylist.songs[0];
      }
      if (GlobalVariables.isNetworkAvailable) {
        pauseSong(calledFromNative: false);
      } else {
        closeSong(closeSongMode: CloseSongMode.partly);
      }
      initSong(
        song: nextSong,
        playlist: currentPlaylist,
        mode: playlistMode,
      );
    }
  }

  void setCurrentPlaylist({Playlist playlist}) {
    if (loopPlaylist == null) {
      loopPlaylist = playlist;
      audioPlayer.release();
    }
    if (playlistMode == PlaylistMode.loop) {
      currentPlaylist = loopPlaylist;
    } else {
      if (shuffledPlaylist == null) {
        _createShuffledPlaylist();
      }
      currentPlaylist = shuffledPlaylist;
    }
  }

  void _createShuffledPlaylist() {
    List<Song> shuffledlist = List();
    List<int> randomPosList = _createRandomPosList();
    int pos = 0;
    while (shuffledlist.length != loopPlaylist.songs.length) {
      shuffledlist.add(loopPlaylist.songs[randomPosList[pos]]);
      pos++;
    }
    shuffledPlaylist = Playlist(loopPlaylist.name);
    shuffledPlaylist.setSongs = shuffledlist;
  }

  List<int> _createRandomPosList() {
    List<int> randomPosList = List();
    var rnd = Random();
    int pos;
    while (randomPosList.length != loopPlaylist.songs.length) {
      pos = rnd.nextInt(loopPlaylist.songs.length);
      if (!randomPosList.contains(pos)) {
        randomPosList.add(pos);
      }
    }
    return randomPosList;
  }

  void _listenForDurationChanged() {
    _audioPlayerOnDurationChangedStream =
        audioPlayer.onDurationChanged.listen((duration) {
      songDuration = duration;
    });
  }

  void _listenForPositionChanged() {
    _audioPlayerOnPositionChangedStream =
        audioPlayer.onAudioPositionChanged.listen((duration) {
      songPosition = duration;
      isSongActuallyPlaying = true;
      if (duration.inSeconds - songPosition.inSeconds == 1) {
        // if (songPosition.inSeconds % 5 == 0) {
        //   if (audioPlayer.state == AudioPlayerState.PLAYING) {
        //     MusicControlNotification.makeNotification(
        //         currentSong, true, false);
        //   } else {
        //     MusicControlNotification.makeNotification(
        //         currentSong, false, false);
        //   }
        // }
      }
    });
  }

  void _listenIfCompleted() {
    _audioPlayerOnCompleteStream = audioPlayer.onPlayerCompletion.listen((a) {
      if (currentPlaylist != null) {
        playNextSong();
      } else {
        initSong(
          song: currentSong,
          playlist: currentPlaylist,
          mode: playlistMode,
        );
      }
    });
  }

  void _listenForErrors() {
    audioPlayer.onPlayerError.listen((eror) {
      closeSong(closeSongMode: CloseSongMode.completely);
      GlobalVariables.toastManager
          .makeToast(text: ToastManager.mediaPlayerError);
      print("MediaPlayerError: $eror");
    });
  }

  void _listenForStateChanges() {
    _audioPlayerOnStateChangedStream =
        audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        MusicControlNotification.makeNotification(currentSong, true, false);
        audioPlayerState = AudioPlayerState.PLAYING;
      } else if (state == AudioPlayerState.PAUSED) {
        MusicControlNotification.makeNotification(currentSong, false, false);
        audioPlayerState = AudioPlayerState.PAUSED;
      } else if (state == AudioPlayerState.STOPPED) {
        audioPlayerState = AudioPlayerState.STOPPED;
      } else if (state == AudioPlayerState.COMPLETED) {
        audioPlayerState = AudioPlayerState.COMPLETED;
      }
    });
  }

  Future<bool> _checkIfReadyToPlay() async {
    bool exists = await GlobalVariables.manageLocalSongs
        .checkIfSongFileExists(currentSong);
    if (exists &&
        GlobalVariables.currentUser
            .songExistsInDownloadedPlaylist(currentSong)) {
      return true;
    } else {
      if (GlobalVariables.isNetworkAvailable) {
        _songStreamUrl =
            await GlobalVariables.apiService.getSongPlayUrl(currentSong);
        if (_songStreamUrl != null) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    }
  }
}
