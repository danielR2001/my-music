import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_exoplayer/audioplayer.dart';
import 'package:myapp/core/services/api_service.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/services/connectivity_service.dart';
import 'package:myapp/core/services/image_loader_service.dart';
import 'package:myapp/core/services/local_database_service.dart';
import 'package:myapp/core/services/native_communication_service.dart';
import 'package:myapp/core/services/tab_navigation_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';

class MusicPlayerModel extends BaseModel {
  final AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();
  final LocalDatabaseService _localDatabaseService =
      locator<LocalDatabaseService>();
  final ConnectivityService _connectivityService =
      locator<ConnectivityService>();
  final NativeCommunicationService _nativeCommunicationService =
      locator<NativeCommunicationService>();
  final ImageLoaderService _imageLoaderService = locator<ImageLoaderService>();
  final ApiService _apiService = locator<ApiService>();
  final TabNavigationService _tabNavigationService =
      locator<TabNavigationService>();

  StreamSubscription<PlayerState> _onPlayerState;
  StreamSubscription<Duration> _onPlayerPosition;
  StreamSubscription<Duration> _onPlayerDuration;
  StreamSubscription<int> _onPlayerIndex;

  PlayerState _playerState;
  Duration _position = Duration(milliseconds: 0);
  Duration _duration = Duration(milliseconds: 0);
  Song _currentSong;
  ImageProvider _imageProvider;
  Color _backgroundColor = CustomColors.darkGreyColor;
  bool _mounted;

  ImageProvider get imageProvider => _imageProvider;

  PlayerState get playerState => _playerState;

  Duration get position => _position;

  Duration get duration => _duration;

  Color get backgroundColor => _backgroundColor;

  String get durationText {
    String durationTxt = _duration?.toString()?.split('.')?.first ?? '';
    if (durationTxt.startsWith("0:")) {
      durationTxt = durationTxt.substring(2, 7);
    }
    return durationTxt;
  }

  String get positionText {
    String _positionTxt = _position?.toString()?.split('.')?.first ?? '';
    if (_positionTxt.startsWith("0:")) {
      _positionTxt = _positionTxt.substring(2, 7);
    }
    return _positionTxt;
  }

  Playlist get currentPlaylist => _audioPlayerService.currentPlaylist;

  Song get currentSong => _currentSong;

  PlaylistMode get playlistMode => _audioPlayerService.playlistMode;

  GlobalKey<NavigatorState> get tabNavigatorKey =>
      _tabNavigationService.tabNavigatorKey;

  Future<void> setCurrentSong() async {
    _currentSong = await _audioPlayerService.getCurrentSong();
    notifyListeners();
  }

  Future<void> initModel() async {
    _mounted = false;
    await setCurrentSong();
    _position = await _audioPlayerService.position;
    _duration = await _audioPlayerService.duration;
    _playerState = _audioPlayerService.playerState;
    _generateBackgroundColor();
    _loadImage();
    _loadLyrics();
    initPlayerStreams();
  }

  Future<void> disposeModel() async {
    _mounted = true;
    await _onPlayerState.cancel();
    await _onPlayerPosition.cancel();
    await _onPlayerDuration.cancel();
    await _onPlayerIndex.cancel();
  }

  void initPlayerStreams() {
    _onPlayerState =
        _audioPlayerService.onPlayerStateChangeStream().listen((state) {
      _playerState = state;
      if (_playerState == PlayerState.COMPLETED) {
        _position = Duration(seconds: 0);
      }
      notifyListeners();
    });
    _onPlayerPosition =
        _audioPlayerService.onPlayerPositionChangedStream().listen((pos) {
      _position = pos;
      notifyListeners();
    });
    _onPlayerDuration =
        _audioPlayerService.onPlayerDurationChangedStream().listen((dur) {
      _duration = dur;
      notifyListeners();
    });
    _onPlayerIndex =
        _audioPlayerService.onPlayerIndexChangedStream().listen((index) {
      _currentSong = currentPlaylist.songs[index];
      _generateBackgroundColor();
      _loadImage();
      _loadLyrics();
      notifyListeners();
    });
  }

  Future<void> _loadImage() async {
    _imageProvider = await _imageLoaderService.loadImage(_currentSong);
    if (!_mounted) {
      notifyListeners();
    }
  }

  Future<void> seekPlayerPosition(double value) async {
    await _audioPlayerService
        .seekPosition(Duration(milliseconds: value.toInt()));
  }

  Future<void> playPreviousSong() async {
    await _audioPlayerService.playPreviousSong();
  }

  Future<void> playNextSong() async {
    await _audioPlayerService.playNextSong();
  }

  Future<void> resume() async {
    await _audioPlayerService.resume();
  }

  Future<void> pause() async {
    await _audioPlayerService.pause();
  }

  Future<void> _loadLyrics() async {
    _currentSong.setLyrics = await _apiService.getSongLyrics(_currentSong);
    if (!_mounted) {
      notifyListeners();
    }
  }

  void setCurrentPlaylist() {
    _audioPlayerService.setPlaylistMode(
        _audioPlayerService.playlistMode == PlaylistMode.loop
            ? PlaylistMode.shuffle
            : PlaylistMode.loop);
  }

  Future<void> _generateBackgroundColor() async {
    if (_currentSong.imageUrl != "") {
      String dominantColor;
      bool exists =
          await _localDatabaseService.checkIfSongFileExists(currentSong);
      if (exists) {
        dominantColor = await _nativeCommunicationService.getDominantColor(
            imagePath:
                "${_localDatabaseService.fullSongDownloadDir.path}/${currentSong.songId}/${currentSong.songId}.png",
            isLocal: true);
      } else {
        if (_connectivityService.isNetworkAvailable) {
          dominantColor = await _nativeCommunicationService.getDominantColor(
              imagePath: currentSong.imageUrl, isLocal: false);
        }
      }

      if (dominantColor != null) {
        dominantColor = dominantColor.replaceAll("#", "");
        dominantColor = "0xff" + dominantColor;
        _backgroundColor = Color(int.parse(dominantColor));
      } else {
        _backgroundColor = CustomColors.pinkColor;
      }
    } else {
      _backgroundColor = CustomColors.pinkColor;
    }
    if (!_mounted) {
      notifyListeners();
    }
  }
}
