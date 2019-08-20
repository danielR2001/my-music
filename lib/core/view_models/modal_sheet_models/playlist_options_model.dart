import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/core/services/api_service.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/services/database_service.dart';
import 'package:myapp/core/services/local_database_service.dart';
import 'package:myapp/core/utils/toast.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';

class PlaylistOptionsModel extends BaseModel {
  final ToastManager _toastManager = locator<ToastManager>();
  final FirebaseDatabaseService _firebaseDatabaseService =
      locator<FirebaseDatabaseService>();
  final LocalDatabaseService _localDatabaseService =
      locator<LocalDatabaseService>();
  final AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();
  final ApiService _apiService = locator<ApiService>();

  StreamSubscription onPlayerIndexChangedStream;

  void initModel() {
    onPlayerIndexChangedStream =
        _audioPlayerService.onPlayerIndexChangedStream().listen((index) {
      notifyListeners();
    });
  }

  void disposeModel() {
    onPlayerIndexChangedStream.cancel();
  }

  Future<Playlist> changePlaylistName(Playlist playlist, String newName) async {
    await _firebaseDatabaseService.renamePlaylist(playlist, newName);
    playlist.setName = newName;
    if (_audioPlayerService.currentPlaylist != null) {
      if (_audioPlayerService.currentPlaylist.pushId == playlist.pushId) {
        _audioPlayerService.currentPlaylist.setName = newName;
      }
    }
    return playlist;
  }

  void downloadAll(List<Song> songs) {
    songs.forEach((song) async {
      bool exists = await _localDatabaseService.checkIfSongFileExists(song);
      if (!exists) {
        String downloadUrl = await _apiService.getSongPlayUrl(song);
        if (downloadUrl != null) {
          _localDatabaseService.downloadSong(downloadUrl, song);
        }
      }
    });
  }

  void unDownloadAll(Playlist playlist) {
    playlist.songs.forEach((song) async {
      bool exists = await _localDatabaseService.checkIfSongFileExists(song);
      if (exists) {
        await _localDatabaseService.deleteSongDirectory(song);
        Song currentSong = await _audioPlayerService.getCurrentSong();
        if (playlist.pushId == _audioPlayerService.currentPlaylist.pushId &&
            song.songId == currentSong.songId) {
          _audioPlayerService.releasePlaylist();
        }
      }
    });
  }

  void removePlaylist(Playlist playlist) {
    _firebaseDatabaseService.removePlaylist(playlist);
    if (_audioPlayerService.currentPlaylist != null) {
      if (_audioPlayerService.currentPlaylist.name ==
          _audioPlayerService.currentPlaylist.name) {
        _audioPlayerService.releasePlaylist();
      }
    }
  }

  Future<Playlist> changePlaylistPrivacy(Playlist playlist) async {
    if (playlist.isPublic) {
      playlist =
          await _firebaseDatabaseService.addPublicPlaylist(playlist, false);
    } else {
      _firebaseDatabaseService.removeFromPublicPlaylist(playlist, false);
    }
    return playlist;
  }

  List<Song> getCurrentDownloading() {
    return _localDatabaseService.currentDownloading;
  }

  void makeToast(String text,
      {Toast toastLength = Toast.LENGTH_SHORT,
      double fontSize = 16,
      Color backgroundColor = CustomColors.pinkColor,
      ToastGravity gravity = ToastGravity.BOTTOM}) {
    _toastManager.makeToast(
      text: text,
      toastLength: toastLength,
      fontSize: fontSize,
      backgroundColor: backgroundColor,
      gravity: gravity,
    );
  }
}
