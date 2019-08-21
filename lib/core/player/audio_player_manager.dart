import 'dart:async';
import 'package:flutter_exoplayer/audio_notification.dart';
import 'package:flutter_exoplayer/audioplayer.dart';

class AudioPlayerManager {
  AudioPlayer _audioPlayer;

  void initAudioPlayerManager() {
    _audioPlayer = AudioPlayer();
    // _audioPlayer.logEnabled = true;
  }

  Future<void> play(
      List<String> urls,
      List<AudioNotification> audioNotifications,
      int index,
      bool repeatMode) async {
    await _audioPlayer.playAll(urls,
        index: index,
        playerMode: PlayerMode.FOREGROUND,
        repeatMode: repeatMode,
        audioNotifications: audioNotifications);
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> release() async {
    await _audioPlayer.release();
  }

  Future<void> seekPosition(Duration duration) async {
    await _audioPlayer.seekPosition(duration);
  }

  Future<void> seekIndex(int index) async {
    await _audioPlayer.seekIndex(index);
  }

  Future<void> previous() async {
    await _audioPlayer.previous();
  }

  Future<void> next() async {
    await _audioPlayer.next();
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
