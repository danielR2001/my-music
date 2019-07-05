import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/communicate_with_native/internet_connection_check.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/main.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/communicate_with_native/music_control_notification.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
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
  bool isLoaded;
  PreviousMode previousMode;

  Song _firstSkippedSong;
  bool _isNetworkAvailable;
  StreamSubscription<void> _audioPlayerOnCompleteStream;
  StreamSubscription<void> _audioPlayerOnDurationChangedStream;
  StreamSubscription<void> _audioPlayerOnPositionChangedStream;

  AudioPlayerManager() {
    audioPlayer = AudioPlayer();
    previousMode = PreviousMode.restart;
    isLoaded = true;
    AudioPlayer.logEnabled = true;
    _listenForErrors();
    audioPlayer.setReleaseMode(ReleaseMode.STOP);
  }

  Future<void> initSong(
      {Song song, Playlist playlist, PlaylistMode playlistMode}) async {
    isLoaded = false;
    previousMode = PreviousMode.restart;
    currentSong = song;
    songPosition = Duration(seconds: 0);
    Provider.of<PageNotifier>(GlobalVariables.homePageContext).setCurrentSong =
        song;
    _isNetworkAvailable = await InternetConnectionCheck.check();

    if (song.getImageUrl == "") {
      if (_isNetworkAvailable) {
        FetchData.getSongImageUrl(song, false).then((imageUrl) {
          song.setImageUrl = imageUrl;
          if (song.getTitle == currentSong.getTitle) {
            currentSong = song;
            MusicControlNotification.makeNotification(currentSong, true, false);
          }
        });
      }
    }
    if (_isNetworkAvailable) {
      FetchData.getLyricsPageUrl(song).then((url) {
        if (url != null) {
          FetchData.getSongLyrics(url).then((lyrics) {
            song.setLyrics = lyrics;
            if (song.getTitle == currentSong.getTitle) {
              currentSong = song;
            }
          });
        }
      });
    }

    this.playlistMode = playlistMode;
    if (playlist != null) {
      if (currentPlaylist != null) {
        if (currentPlaylist != playlist && loopPlaylist != playlist) {
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
    bool readyToPlay = await _setAudioPlayerUrl();
    if (readyToPlay) {
      _firstSkippedSong = null;
      _playSong();
    } else if (_isNetworkAvailable) {
      if (_firstSkippedSong == null) {
        _firstSkippedSong = song;
        playNextSong();
      } else {
        if (song.getSongId != _firstSkippedSong.getSongId) {
          playNextSong();
        } else {
          isLoaded = true;
          songPosition = null;
          _firstSkippedSong = null;
          closeSong(closeSongMode: CloseSongMode.partly);
        }
      }
    } else {
      isLoaded = true;
      songPosition = null;
    }
  }

  Future _playSong() async {
    closeSong();
    MusicControlNotification.makeNotification(currentSong, true, false);
    await audioPlayer.resume();
    isLoaded = true;

    _listenForDurationChanged();
    _listenForPositionChanged();
    _listenIfCompleted();
  }

  void resumeSong({bool calledFromNative}) {
    audioPlayer.resume();
    if (!calledFromNative) {
      MusicControlNotification.makeNotification(currentSong, true, true);
    }
  }

  void pauseSong({bool calledFromNative}) {
    audioPlayer.pause();
    if (!calledFromNative) {
      MusicControlNotification.makeNotification(currentSong, false, true);
    }
  }

  void closeSong({CloseSongMode closeSongMode}) {
    if (closeSongMode != null) {
      if (closeSongMode == CloseSongMode.completely) {
        currentSong = null;
        currentPlaylist = null;
        loopPlaylist = null;
        shuffledPlaylist = null;
      } else if (closeSongMode == CloseSongMode.partly) {
        audioPlayer.stop();
        audioPlayer.release();
      }
    }
    if (_audioPlayerOnCompleteStream != null) {
      _audioPlayerOnCompleteStream.cancel();
      _audioPlayerOnDurationChangedStream.cancel();
      _audioPlayerOnPositionChangedStream.cancel();
    }
  }

  void seekTime({Duration duration}) {
    audioPlayer.seek(duration);
  }

  Future playPreviousSong(bool automaticPlayNext) async {
    if (previousMode == PreviousMode.previous) {
      if (currentPlaylist != null) {
        int i = 0;
        Song correctPreviousSong;
        _isNetworkAvailable = await InternetConnectionCheck.check();
        Song previousSong;
        if (currentPlaylist.getSongs.length > 1) {
          if (currentSong.getSongId == currentPlaylist.getSongs[0].getSongId) {
            correctPreviousSong =
                currentPlaylist.getSongs[currentPlaylist.getSongs.length - 1];
          }
          previousSong = currentPlaylist.getSongs[0];
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
        } else {
          correctPreviousSong = currentSong;
          songDuration = Duration(seconds: 0);
          seekTime(duration: songDuration);
        }
        if (_isNetworkAvailable) {
          pauseSong(calledFromNative: false);
        } else {
          closeSong(closeSongMode: CloseSongMode.partly);
        }
        initSong(
          song: correctPreviousSong,
          playlist: currentPlaylist,
          playlistMode: playlistMode,
        );
      }
    } else {
      previousMode = PreviousMode.previous;
      if (_isNetworkAvailable) {
        songPosition = Duration(seconds: 0);
        audioPlayer.seek(songPosition);
        if (audioPlayer.state == AudioPlayerState.PAUSED) {
          resumeSong(calledFromNative: false);
        }
      } else {
        playPreviousSong(true);
      }
    }
  }

  Future playNextSong() async {
    if (currentPlaylist != null) {
      bool foundSong = false;
      Song nextSong;

      _isNetworkAvailable = await InternetConnectionCheck.check();
      if (currentPlaylist.getSongs.length > 1) {
        currentPlaylist.getSongs.forEach((song) {
          if (foundSong) {
            nextSong = song;
            foundSong = false;
          }
          if (song.getSongId == currentSong.getSongId) {
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
        nextSong = currentPlaylist.getSongs[0];
      }
      if (_isNetworkAvailable) {
        pauseSong(calledFromNative: false);
      } else {
        closeSong(closeSongMode: CloseSongMode.partly);
      }
      initSong(
        song: nextSong,
        playlist: currentPlaylist,
        playlistMode: playlistMode,
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
    while (shuffledlist.length != loopPlaylist.getSongs.length) {
      shuffledlist.add(loopPlaylist.getSongs[randomPosList[pos]]);
      pos++;
    }
    shuffledPlaylist = Playlist(loopPlaylist.getName);
    shuffledPlaylist.setSongs = shuffledlist;
  }

  List<int> _createRandomPosList() {
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

  void _listenForDurationChanged() {
    _audioPlayerOnDurationChangedStream =
        audioPlayer.onDurationChanged.listen((duration) {
      songDuration = duration;
    });
  }

  void _listenForPositionChanged() {
    _audioPlayerOnPositionChangedStream =
        audioPlayer.onAudioPositionChanged.listen((duration) {
      if (songPosition != null) {
        if (duration.inSeconds - songPosition.inSeconds == 1) {
          songPosition = duration;
          print(songPosition.inSeconds);
          // if (songPosition.inSeconds % 5 == 0) {
          //   if (audioPlayer.state == AudioPlayerState.PLAYING) {
          //     MusicControlNotification.makeNotification(currentSong, true, true);
          //   } else {
          //     MusicControlNotification.makeNotification(currentSong, false, true);
          //   }
          // }
        }
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
          playlistMode: playlistMode,
        );
      }
    });
  }

  void _listenForErrors() {
    audioPlayer.onPlayerError.listen((eror) {
      closeSong(closeSongMode: CloseSongMode.completely);
      _makeToast(text: "Media Player error occurred");
      print("MediaPlayerError: $eror");
    });
  }

  void _makeToast({String text}) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIos: 1,
      fontSize: 16.0,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: GlobalVariables.pinkColor,
      textColor: Colors.white,
    );
  }

  Future<bool> _setAudioPlayerUrl() async {
    isLoaded = false;
    bool exists = await ManageLocalSongs.checkIfFileExists(currentSong);
    if (exists && currentUser.songExistsInDownloadedPlaylist(currentSong)) {
      await audioPlayer.setUrl(
          "${ManageLocalSongs.fullSongDownloadDir.path}/${currentSong.getSongId}/${currentSong.getSongId}.mp3");
      return true;
    } else {
      if (_isNetworkAvailable) {
        String streamUrl = await FetchData.getSongPlayUrl(currentSong);
        if (streamUrl != null) {
          await audioPlayer.setUrl(streamUrl);
          return true;
        } else {
          _makeToast(text: "oops something went wrong :(");
          return false;
        }
      } else {
        _makeToast(text: "no intenet connection");
        MusicControlNotification.makeNotification(currentSong, false, false);
        return false;
      }
    }
  }
}
