import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myapp/core/database/local/local_database_manager.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/services/image_loader_service.dart';
import 'package:myapp/core/services/local_database_service.dart';
import 'package:myapp/core/services/tab_navigation_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';

class PlaylistModel extends BaseModel {
  final LocalDatabaseService _localDatabaseService =
      locator<LocalDatabaseService>();
  final AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();
  final ImageLoaderService _imageLoaderService = locator<ImageLoaderService>();
    final TabNavigationService _tabNavigationService =
      locator<TabNavigationService>();

  StreamSubscription<Map<String, int>> _onDownloadProgresses;

  StreamSubscription<Map<String, int>> _onDownloadTotals;

  StreamSubscription<Map<String, bool>> _onDownloadStops;

  StreamSubscription<Map<String, DownloadError>> _onDownloadErors;

  StreamSubscription<int> _playerIndexStream;

  Map<String, int> _progressesMap;
  Map<String, int> _totalsMap;
  Song _currentSong;
  Playlist _pagePlaylist;
  ImageProvider _imageProvider;
  bool _playing = false;

  ImageProvider get imageProvider => _imageProvider;

  Playlist get pagePlaylist => _pagePlaylist;

  GlobalKey<NavigatorState> get tabNavigatorKey =>
      _tabNavigationService.tabNavigatorKey;

  int progress(String songId) => _progressesMap[songId];

  int total(String songId) => _totalsMap[songId];

  String editSongTitle(String title) {
    if (title.length > 33) {
      int pos = title.lastIndexOf("", 33);
      if (pos < 25) {
        pos = 33;
      }
      title = title.substring(0, pos) + "...";
      return title;
    }

    return title;
  }

  String editSongArtist(String artist) {
    if (artist.length > 36) {
      int pos = artist.lastIndexOf("", 36);
      if (pos < 26) {
        pos = 36;
      }
      artist = artist.substring(0, pos) + "...";
      return artist;
    }

    return artist;
  }

  bool isSongDownloading(Song song) {
    return _localDatabaseService.isSongDownloading(song);
  }

  bool isSongPlaying(Song song) {
    return _currentSong.songId == song.songId;
  }

  bool isPagePlaylistIsPlaying() {
    if (_audioPlayerService.currentPlaylist == null) return false;
    return _pagePlaylist.pushId == _audioPlayerService.currentPlaylist.pushId;
  }

  Future<void> loadImage(Playlist playlist) async {
    if (playlist.songs.length != 0) {
      _imageProvider = await _imageLoaderService.loadImage(playlist.songs[0]);
    } else {
      _imageProvider = null;
    }
    notifyListeners();
  }

  Future<void> play(int index, PlaylistMode mode) async {
    if (!_playing) {
      await _audioPlayerService.initPlaylist(_pagePlaylist, mode, index, false);
      _playing = true;
    } else {
      await _audioPlayerService.seekIndex(index);
    }
  }

  void initStreams() {
    _playerIndexStream =
        _audioPlayerService.onPlayerIndexChangedStream().listen((index) {
      _currentSong = _audioPlayerService.currentPlaylist.songs.elementAt(index);
      notifyListeners();
    });
    _onDownloadProgresses =
        _localDatabaseService.onDownloadProgresses.listen((_progressMap) {
      _progressesMap = Map.from(_progressMap);
      notifyListeners();
    });
    _onDownloadTotals =
        _localDatabaseService.onDownloadTotals.listen((totalMap) {
      _totalsMap = Map.from(totalMap);
      notifyListeners();
    });
    _onDownloadStops =
        _localDatabaseService.onDownloadStops.listen((reasonMap) {
      // TODO
    });
    _onDownloadErors = _localDatabaseService.onDownloadErors.listen((errorMap) {
      // TODO
    });
  }

  Future<void> cancelDownLoad(Song song) async {
    await _localDatabaseService.cancelDownLoad(song);
  }

  Future<void> initModel(Playlist playlist) async {
    _pagePlaylist = playlist;
    _currentSong = await _audioPlayerService.getCurrentSong();
    initStreams();
    loadImage(playlist);
    notifyListeners();
  }

  Future<void> disposeModel() async {
    await _onDownloadProgresses.cancel();
    await _onDownloadTotals.cancel();
    await _onDownloadStops.cancel();
    await _onDownloadErors.cancel();
    await _playerIndexStream.cancel();
  }
}
