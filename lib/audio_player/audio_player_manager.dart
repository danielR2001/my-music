import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/Constants/constants.dart';
import 'package:myapp/communicate_with_native/internet_connection_check.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
import 'package:myapp/main.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/communicate_with_native/music_control_notification.dart';

enum PlaylistMode {
  shuffle,
  loop,
}

class AudioPlayerManager {
  AudioPlayer audioPlayer;
  Song currentSong;
  Playlist currentPlaylist;
  Playlist shuffledPlaylist;
  Playlist loopPlaylist;
  StreamSubscription<void> _audioPlayerOnCompleteStream;
  StreamSubscription<void> _audioPlayerOnDurationChangedStream;
  StreamSubscription<void> _audioPlayerOnPositionChangedStream;
  PlaylistMode playlistMode;
  Duration songDuration;
  Duration songPosition;
  bool isLoaded = true;
  int skippedCounter = 0;

  AudioPlayerManager() {
    audioPlayer = AudioPlayer();
    AudioPlayer.logEnabled = true;
  }
  void initSong(Song song, Playlist playlist, PlaylistMode playlistMode) {
    songPosition = Duration(seconds: 0);
    if (song.getImageUrl == "") {
      InternetConnectioCheck.check().then((isNetworkAvailable) async {
        if (isNetworkAvailable) {
          String imageUrl = await FetchData.getSongImageUrl(song, false);
          song.setImageUrl = imageUrl;
        }
      });
    }
    currentSong = song;
    closeSong();
    this.playlistMode = playlistMode;
    if (playlist != null) {
      if (currentPlaylist != null) {
        if (currentPlaylist != playlist) {
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
  }

  void playSong() {
    ManageLocalSongs.checkIfFileExists(currentSong).then((exists) {
      if (exists && currentUser.songExistsInDownloadedPlaylist(currentSong)) {
        skippedCounter = 0;
        MusicControlNotification.makeNotification(currentSong, true);
        audioPlayer.play(
            "${ManageLocalSongs.fullSongDownloadDir.path}/${currentSong.getSongId}.mp3");
        Fluttertoast.showToast(
          msg: "Playing from local",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Constants.pinkColor,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        InternetConnectioCheck.check().then((isNetworkAvailable) {
          if (isNetworkAvailable) {
            FetchData.getSongPlayUrlPage1(currentSong).then((streamUrl) {
              if (streamUrl != null) {
                skippedCounter = 0;
                MusicControlNotification.makeNotification(currentSong, true);
                audioPlayer.play(streamUrl);
                Fluttertoast.showToast(
                  msg: "Playing from network",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIos: 1,
                  backgroundColor: Constants.pinkColor,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              } else {
                playNextSong();
                Fluttertoast.showToast(
                  msg: "oops something went wrong :(",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIos: 10,
                  backgroundColor: Constants.pinkColor,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            });
          } else {
            if (skippedCounter != currentPlaylist.getSongs.length) {
              skippedCounter++;
              playNextSong();
              Fluttertoast.showToast(
                msg: "No Internet Connection",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIos: 1,
                backgroundColor: Constants.pinkColor,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            } else {
              MusicControlNotification.makeNotification(currentSong, false);
              skippedCounter = 0;
              isLoaded = true;
            }
          }
        });
      }
      listenForDurationChanged();
      listenForPositionChanged();
      listenIfCompleted();
    });
  }

  void resumeSong(bool calledFromNative) {
    audioPlayer.resume();
    if (!calledFromNative) {
      MusicControlNotification.makeNotification(currentSong, true);
    }
  }

  void pauseSong(bool calledFromNative) {
    audioPlayer.pause();
    if (!calledFromNative) {
      MusicControlNotification.makeNotification(currentSong, false);
    }
  }

  void closeSong() {
    audioPlayer.stop();
    isLoaded = false;
    releaseSong();
    if (_audioPlayerOnCompleteStream != null) {
      _audioPlayerOnCompleteStream.cancel();
      _audioPlayerOnDurationChangedStream.cancel();
      _audioPlayerOnPositionChangedStream.cancel();
    }
  }

  void releaseSong() {
    audioPlayer.release();
  }

  void seekTime(Duration duration) {
    audioPlayer.seek(duration);
  }

  void listenForDurationChanged() {
    _audioPlayerOnDurationChangedStream =
        audioPlayer.onDurationChanged.listen((duration) {
      isLoaded = true;
      songDuration = duration;
    });
  }

  void listenForPositionChanged() {
    _audioPlayerOnPositionChangedStream =
        audioPlayer.onAudioPositionChanged.listen((duration) {
      songPosition = duration;
    });
  }

  void listenIfCompleted() {
    _audioPlayerOnCompleteStream = audioPlayer.onPlayerCompletion.listen((a) {
      if (currentPlaylist != null) {
        playNextSong();
      } else {
        initSong(
          currentSong,
          currentPlaylist,
          playlistMode,
        );
        playSong();
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

        playSong();
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

        playSong();
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

      playSong();
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
