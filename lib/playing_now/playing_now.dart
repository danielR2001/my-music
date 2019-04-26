import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';

class PlayingNow {
  bool isPlaying;
  AudioPlayer advancedPlayer;
  AudioCache audioCache;
  Duration songDuration;
  Duration songPosition;
  Song currentSong;
  Playlist currentPlaylist;

  SongStatus() {
    isPlaying = false;
    advancedPlayer = new AudioPlayer();
    audioCache = audioCache = new AudioCache(fixedPlayer: advancedPlayer);
    songDuration = new Duration();
    songPosition = new Duration();
  }

  void playSong(Song song) {
    closeSong();
    isPlaying = true;
    currentSong = song;
    advancedPlayer.play(currentSong.getSongUrl);
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
