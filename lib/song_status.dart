import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:myapp/modules/song.dart';

class SongStatus {
  bool isPlaying;
  AudioPlayer advancedPlayer;
  AudioCache audioCache;
  Duration songDuration;
  Duration songPosition;
  Song currentSong;

  SongStatus() {
    isPlaying = false;
    advancedPlayer = new AudioPlayer();
    audioCache = audioCache = new AudioCache(fixedPlayer: advancedPlayer);
    songDuration = new Duration();
    songPosition = new Duration();
  }
  void playSong() {
    isPlaying = true;
    print(currentSong.songUrl);
    audioCache.play(currentSong.songUrl);
  }

  void resumeSong() {
    isPlaying = true;
    advancedPlayer.resume();
  }

  void pauseSong() {
    isPlaying = false;
    advancedPlayer.pause();
  }

  void closeSong() {
    advancedPlayer.stop();
    currentSong = null;
  }

  void seekTime(Duration duration) {
    advancedPlayer.seek(duration);
  }
}
