import 'dart:async';
import 'dart:math';
import 'package:flutter_exoplayer/audio_notification.dart';
import 'package:flutter_exoplayer/audioplayer.dart';
import 'package:myapp/core/player/audio_player_manager.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';

enum PlaylistMode {
  shuffle,
  loop,
}

class AudioPlayerService {
  final AudioPlayerManager audioPlayerManager = locator<AudioPlayerManager>();

  Playlist _currentPlaylist;
  Playlist _shuffledPlaylist;
  Playlist _loopPlaylist;

  PlayerState _playerState;
  PlaylistMode _playlistMode;

  Playlist get currentPlaylist => _currentPlaylist;

  Playlist get shuffledPlaylist => _shuffledPlaylist;

  Playlist get loopPlaylist => _loopPlaylist;

  PlayerState get playerState => _playerState;

  PlaylistMode get playlistMode => _playlistMode;

  set setPlaylistMode(PlaylistMode playlistMode) {
    _playlistMode = playlistMode;
    //! TODO changed of current playlist
  }

  set setCurrentPlaylist(Playlist playlist) => _currentPlaylist = playlist;

  set setShuffledPlaylist(Playlist playlist) => _shuffledPlaylist = playlist;

  set setLoopPlaylist(Playlist playlist) => _loopPlaylist = playlist;

  void initAudioPlayerService() {
    audioPlayerManager.initAudioPlayerManager();
    // audioPlayerManager.logEnabled = true;
  }

  Future<void> initPlaylist(
      Playlist playlist, PlaylistMode mode, int index, bool repeatMode) async {
    //! TODO handle init playlist url search!
    List<String> urls;
    List<AudioNotification> audioNotifications;
    await _playPlaylist(urls, audioNotifications, index, repeatMode);
  }

  Future<void> _playPlaylist(
      List<String> urls,
      List<AudioNotification> audioNotifications,
      int index,
      bool repeatMode) async {
    await audioPlayerManager.play(urls, audioNotifications, index, repeatMode);
  }

  Future<void> resume() async {
    await audioPlayerManager.resume();
  }

  Future<void> pause() async {
    await audioPlayerManager.pause();
  }

  Future<void> stopPlaylist() async {
    await audioPlayerManager.stop();
  }

  Future<void> releasePlaylist() async {
    _currentPlaylist = null;
    _loopPlaylist = null;
    _shuffledPlaylist = null;
    await audioPlayerManager.release();
  }

  Future<void> seekPosition(Duration duration) async {
    await audioPlayerManager.seekPosition(duration);
  }

  Future<void> seekIndex(int index) async {
    await audioPlayerManager.seekIndex(index);
  }
  Future<void> playPreviousSong() async {
    await audioPlayerManager.previous();
  }

  Future<void> playNextSong() async {
    await audioPlayerManager.next();
  }

  Future<Song> getCurrentSong() async {
    return _currentPlaylist.songs
        .elementAt(await audioPlayerManager.getCurrentIndex());
  }

  void setCurrentPlaylist(Playlist playlist) {
    if (loopPlaylist == null) {
      _loopPlaylist = playlist;
      audioPlayerManager.release();
    }
    if (playlistMode == PlaylistMode.loop) {
      _currentPlaylist = loopPlaylist;
    } else {
      if (shuffledPlaylist == null) {
        _createShuffledPlaylist();
      }
      _currentPlaylist = shuffledPlaylist;
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
    _shuffledPlaylist = Playlist(loopPlaylist.name);
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

  Stream<void> onPlayerCompletionStream() {
    return audioPlayerManager.onPlayerCompletionStream();
  }

  Stream<void> onPlayerStateChangeStream() {
    return audioPlayerManager.onPlayerStateChangeStream();
  }

  Stream<Duration> onPlayerPositionChangedStream() {
    return audioPlayerManager.onPlayerPositionChangedStream();
  }

  Stream<Duration> onPlayerDurationChangedStream() {
    return audioPlayerManager.onPlayerDurationChangedStream();
  }

  Stream<int> onPlayerIndexChangedStream() {
    return audioPlayerManager.onPlayerIndexChangedStream();
  }

  Future<void> dispose() async {
    await audioPlayerManager.dispose();
  }
}
