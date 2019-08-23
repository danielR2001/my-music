import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_exoplayer/audioplayer.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/services/connectivity_service.dart';
import 'package:myapp/core/services/image_loader_service.dart';
import 'package:myapp/core/services/local_database_service.dart';
import 'package:myapp/core/services/native_communication_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';

class MusicPlayerModel extends BaseModel {
  final AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();
  final LocalDatabaseService _localDatabaseService =
      locator<LocalDatabaseService>();
  final ConnectivityService _connectivityService =
      locator<ConnectivityService>();
  final NativeCommunicationService _nativeCommunicationService =
      locator<NativeCommunicationService>();
  final ImageLoaderService _imageLoaderService = locator<ImageLoaderService>();

  StreamSubscription<PlayerState> _onPlayerState;
  StreamSubscription<Duration> _onPlayerPosition;
  StreamSubscription<Duration> _onPlayerDuration;
  StreamSubscription<int> _onPlayerIndex;

  PlayerState _playerState;
  Duration _position;
  Duration _duration;
  Song _currentSong;
  ImageProvider _imageProvider;

  ImageProvider get imageProvider => _imageProvider;

  PlayerState get playerState => _playerState;

  Duration get position => _position;

  Duration get duration => _duration;

  String get durationText => _duration?.toString()?.split('.')?.first ?? '';

  String get positionText => _position?.toString()?.split('.')?.first ?? '';

  Playlist get currentPlaylist => _audioPlayerService.currentPlaylist;

  Song get currentSong => _currentSong;

  PlaylistMode get playlistMode => _audioPlayerService.playlistMode;

  Future<void> setCurrentSong() async {
    _currentSong = await _audioPlayerService.getCurrentSong();
    await _loadImage(_currentSong);
    notifyListeners();
  }

  void initPlayerStreamSubsciptions() {
    _onPlayerState =
        _audioPlayerService.onPlayerStateChangeStream().listen((state) {
      _playerState = state;
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
      _loadImage(_currentSong);
      notifyListeners();
    });
  }

  void disposePlayerStreamSubsciptions() {
    _onPlayerState.cancel();
    _onPlayerPosition.cancel();
    _onPlayerDuration..cancel();
    _onPlayerIndex.cancel();
  }

  Future<void> _loadImage(Song song) async {
    _imageProvider = await _imageLoaderService.loadImage(song);
    notifyListeners();
  }

  Future<void> seekPlayerPosition(double value) async {
    await _audioPlayerService
        .seekPosition(Duration(milliseconds: value.toInt()));
    //_position = Duration(milliseconds: value.toInt());
    //notifyListeners();
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

  void setCurrentPlaylist() {
    _audioPlayerService.setPlaylistMode(
        _audioPlayerService.playlistMode == PlaylistMode.loop
            ? PlaylistMode.shuffle
            : PlaylistMode.loop);
  }
//! TODO load image!
  // void checkForIntenetConnetionForNetworkImage() {
  //   generateBackgroundColors();
  //   if (CustomColors.audioPlayerManager.currentSong.imageUrl != "") {
  //     CustomColors.manageLocalSongs
  //         .checkIfImageFileExists(CustomColors.audioPlayerManager.currentSong)
  //         .then((exists) {
  //       if (exists) {
  //         File file = File(
  //             "${CustomColors.manageLocalSongs._fullSongDownloadDir.path}/${CustomColors.audioPlayerManager.currentSong.songId}/${CustomColors.audioPlayerManager.currentSong.songId}.png");
  //         if (mounted) {
  //           setState(() {
  //             imageProvider = FileImage(file);
  //           });
  //         }
  //       } else {
  //         if (CustomColors.isNetworkAvailable) {
  //           if (mounted) {
  //             setState(() {
  //               imageProvider = NetworkImage(
  //                 CustomColors.audioPlayerManager.currentSong.imageUrl,
  //               );
  //             });
  //           }
  //         }
  //       }
  //     });
  //   }
  // }

  Future<Color> generateBackgroundColor() async {
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
        return Color(int.parse(dominantColor));
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}
