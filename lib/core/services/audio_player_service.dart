import 'dart:async';
import 'dart:math';
import 'package:flutter_exoplayer/audio_notification.dart';
import 'package:flutter_exoplayer/audioplayer.dart';
import 'package:myapp/core/player/audio_player_manager.dart';
import 'package:myapp/core/services/api_service.dart';
import 'package:myapp/core/services/local_database_service.dart';
import 'package:myapp/core/services/toast_service.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';

enum PlaylistMode {
  shuffle,
  loop,
}

class AudioPlayerService {
  final AudioPlayerManager _audioPlayerManager = locator<AudioPlayerManager>();
  final LocalDatabaseService _localDatabaseService =
      locator<LocalDatabaseService>();
  final ToastService _toastService = locator<ToastService>();

  Playlist _currentPlaylist;
  Playlist _shuffledPlaylist;
  Playlist _loopPlaylist;

  PlaylistMode _playlistMode;

  Playlist get currentPlaylist => _currentPlaylist;

  Playlist get shuffledPlaylist => _shuffledPlaylist;

  Playlist get loopPlaylist => _loopPlaylist;

  PlayerState get playerState => _audioPlayerManager.playerState;

  Future<Duration> get position async => await _audioPlayerManager.position;

  Future<Duration> get duration async => await _audioPlayerManager.duration;

  PlaylistMode get playlistMode =>
      _playlistMode; //! TODO add repeat mode change!

  set setLoopPlaylist(Playlist playlist) => _loopPlaylist = playlist;

  void setPlaylistMode(PlaylistMode playlistMode) {
    _playlistMode = playlistMode;

    if (_playlistMode == PlaylistMode.loop) {
      _currentPlaylist = Playlist.fromPlaylist(_loopPlaylist);
    } else if (_playlistMode == PlaylistMode.shuffle) {
      _shuffledPlaylist = _createShuffledPlaylist();
      _currentPlaylist = Playlist.fromPlaylist(shuffledPlaylist);
    }
  }

  set setCurrentPlaylist(Playlist playlist) {
    _loopPlaylist = Playlist.fromPlaylist(playlist);
    setPlaylistMode(_playlistMode);
  }

  void initAudioPlayerService() {
    _audioPlayerManager.initAudioPlayerManager();
    // audioPlayerManager.logEnabled = true;
  }

  Future<void> initPlaylist(
      Playlist playlist, PlaylistMode mode, int index, bool repeatMode) async {
    List<String> urls = List();
    List<AudioNotification> audioNotifications = List();

    releasePlaylist();
    for (Song song in playlist.songs) {
      bool isLocal = await _localDatabaseService.checkIfSongFileExists(song);
      String imageUrl;
      if (song.imageUrl != null) {
        imageUrl = song.imageUrl;
      } else {
        imageUrl = _localDatabaseService.getDefaultImageUrl();
      }
      audioNotifications.add(AudioNotification(
          smallIconFileName: "app_logo_no_background",
          title: song.title,
          subTitle: song.artist,
          largeIconUrl: imageUrl,
          isLocal: isLocal));
    }
    _loopPlaylist = Playlist.fromPlaylist(playlist);
    setPlaylistMode(mode);
    currentPlaylist.songs.forEach((song) {
      urls.add(song.playUrl);
    });
    await _playPlaylist(urls, audioNotifications, index, repeatMode);
  }

  Future<void> _playPlaylist(
      List<String> urls,
      List<AudioNotification> audioNotifications,
      int index,
      bool repeatMode) async {
    Result result = await _audioPlayerManager.play(
        urls, audioNotifications, index, repeatMode);
    _toastService.makeToast(
        text: "playPlaylist" + (result == Result.ERROR
            ? "ERROR"
            : result == Result.FAIL ? "FAIL" : "SUCCESS"));
  }

  Future<void> resume() async {
    Result result = await _audioPlayerManager.resume();
    _toastService.makeToast(
        text: "resume" + (result == Result.ERROR
            ? "ERROR"
            : result == Result.FAIL ? "FAIL" : "SUCCESS"));
  }

  Future<void> pause() async {
    Result result = await _audioPlayerManager.pause();
    _toastService.makeToast(
        text: "pause" + (result == Result.ERROR
            ? "ERROR"
            : result == Result.FAIL ? "FAIL" : "SUCCESS"));
  }

  Future<void> stopPlaylist() async {
    Result result = await _audioPlayerManager.stop();
    _toastService.makeToast(
        text: "stopPlaylist" + (result == Result.ERROR
            ? "ERROR"
            : result == Result.FAIL ? "FAIL" : "SUCCESS"));
  }

  Future<void> releasePlaylist() async {
    Result result = await _audioPlayerManager.release();
    _toastService.makeToast(
        text: "releasePlaylist" + (result == Result.ERROR
            ? "ERROR"
            : result == Result.FAIL ? "FAIL" : "SUCCESS"));
  }

  Future<void> seekPosition(Duration duration) async {
    Result result = await _audioPlayerManager.seekPosition(duration);
    _toastService.makeToast(
        text: "seekPosition" + (result == Result.ERROR
            ? "ERROR"
            : result == Result.FAIL ? "FAIL" : "SUCCESS"));
  }

  Future<void> seekIndex(int index) async {
    Result result = await _audioPlayerManager.seekIndex(index);
    _toastService.makeToast(
        text: "seekIndex" + (result == Result.ERROR
            ? "ERROR"
            : result == Result.FAIL ? "FAIL" : "SUCCESS"));
  }

  Future<void> playPreviousSong() async {
    Result result = await _audioPlayerManager.previous();
    _toastService.makeToast(
        text: "playPreviousSong" + (result == Result.ERROR
            ? "ERROR"
            : result == Result.FAIL ? "FAIL" : "SUCCESS"));
  }

  Future<void> playNextSong() async {
    Result result = await _audioPlayerManager.next();
    _toastService.makeToast(
        text: "playNextSong" + (result == Result.ERROR
            ? "ERROR"
            : result == Result.FAIL ? "FAIL" : "SUCCESS"));
  }

  Future<Song> getCurrentSong() async {
    if (_currentPlaylist == null) return null;
    return _currentPlaylist.songs
        .elementAt(await _audioPlayerManager.getCurrentIndex());
  }

  Playlist _createShuffledPlaylist() {
    Playlist playlist;
    List<Song> shuffledlist = List();
    List<int> randomPosList = _createRandomPosList();
    int pos = 0;
    while (shuffledlist.length != loopPlaylist.songs.length) {
      shuffledlist.add(loopPlaylist.songs[randomPosList[pos]]);
      pos++;
    }
    playlist = Playlist(loopPlaylist.name);
    playlist.setSongs = shuffledlist;
    return playlist;
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
    return _audioPlayerManager.onPlayerCompletionStream();
  }

  Stream<PlayerState> onPlayerStateChangeStream() {
    return _audioPlayerManager.onPlayerStateChangeStream();
  }

  Stream<Duration> onPlayerPositionChangedStream() {
    return _audioPlayerManager.onPlayerPositionChangedStream();
  }

  Stream<Duration> onPlayerDurationChangedStream() {
    return _audioPlayerManager.onPlayerDurationChangedStream();
  }

  Stream<int> onPlayerIndexChangedStream() {
    return _audioPlayerManager.onPlayerIndexChangedStream();
  }

  Future<void> dispose() async {
    await _audioPlayerManager.dispose();
  }
}
