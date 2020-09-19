import 'dart:async';
import 'package:flutter_exoplayer/audio_notification.dart';
import 'package:flutter_exoplayer/audioplayer.dart';

class AudioPlayerManager {
  AudioPlayer _audioPlayer;

  void initAudioPlayerManager() {
    _audioPlayer = AudioPlayer();
    // _audioPlayer.logEnabled = true;
  }

  Future<Result> play(
      List<String> urls,
      List<AudioNotification> audioNotifications,
      int index,
      bool repeatMode) async {
    return await _audioPlayer.playAll(urls,
        index: index,
        playerMode: PlayerMode.FOREGROUND,
        repeatMode: repeatMode,
        respectAudioFocus: true,
        audioNotifications: audioNotifications);
  }

  PlayerState get playerState => _audioPlayer.playerState;

  Future<Duration> get position async => await _audioPlayer.getCurrentPosition();

  Future<Duration> get duration async => await _audioPlayer.getDuration();

  Future<Result> resume() async {
    return await _audioPlayer.resume();
  }

  Future<Result> pause() async {
    return await _audioPlayer.pause();
  }

  Future<Result> stop() async {
    return await _audioPlayer.stop();
  }

  Future<Result> release() async {
    return await _audioPlayer.release();
  }

  Future<Result> seekPosition(Duration duration) async {
    return await _audioPlayer.seekPosition(duration);
  }

  Future<Result> seekIndex(int index) async {
    return await _audioPlayer.seekIndex(index);
  }

  Future<Result> previous() async {
    return await _audioPlayer.previous();
  }

  Future<Result> next() async {
    return await _audioPlayer.next();
  }

  Future<int> getCurrentIndex() async {
    return await _audioPlayer.getCurrentPlayingAudioIndex();
  }

  Stream<void> onPlayerCompletionStream() {
    return _audioPlayer.onPlayerCompletion;
  }

  Stream<PlayerState> onPlayerStateChangeStream() {
    return _audioPlayer.onPlayerStateChanged;
  }

  Stream<Duration> onPlayerPositionChangedStream() {
    return _audioPlayer.onAudioPositionChanged;
  }

  Stream<Duration> onPlayerDurationChangedStream() {
    return _audioPlayer.onDurationChanged;
  }

  Stream<int> onPlayerIndexChangedStream() {
    return _audioPlayer.onCurrentAudioIndexChanged;
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
