import 'dart:async';

import 'package:flutter_exoplayer/audioplayer.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/models/song.dart';

class HomeModel extends BaseModel {
  final AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();
  StreamSubscription<int> _playerIndexStream;
  StreamSubscription<PlayerState> _playerStateStream;

  Song _currentSong;
  PlayerState _playerState;
  int _index;

  Song get currentSong => _currentSong;

  int get index => _index;

  PlayerState get playerState => _playerState;

  void initStreams() {
    _playerIndexStream =
        _audioPlayerService.onPlayerIndexChangedStream().listen((index) {
      _currentSong = _audioPlayerService.currentPlaylist.songs.elementAt(index);
      _index = index;
      notifyListeners();
    });
    _playerStateStream =
        _audioPlayerService.onPlayerStateChangeStream().listen((state) {
      _playerState = state;
      notifyListeners();
    });
  }

  Future<void> disposeStreams() async {
    await _playerIndexStream.cancel();
    await _playerStateStream.cancel();
  }

  Future<void> restartSong() async{
    await _audioPlayerService.initPlaylist(_audioPlayerService.currentPlaylist, _audioPlayerService.playlistMode, index, false); 
  }

  Future<void> resume() async {
    await _audioPlayerService.resume();
  }

  Future<void> pause() async {
    await _audioPlayerService.pause();
  }
}
