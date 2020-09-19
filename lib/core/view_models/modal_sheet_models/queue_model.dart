import 'package:myapp/core/view_models/page_models/base_model.dart';

import '../../../locater.dart';
import '../../../models/playlist.dart';
import '../../../models/song.dart';
import '../../services/audio_player_service.dart';

class QueueModel extends BaseModel {
  final AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();
  Song currentSong;
  Playlist currentPlaylist;

  void onReorder(int to, int from) {
    if (to > from) {
      to--;
    }
    Song temp = Song.fromSong(currentPlaylist.songs[to]);

    currentPlaylist.songs[to] =
        currentPlaylist.songs[from];
    currentPlaylist.songs[from] = temp;

    _audioPlayerService.currentPlaylist.setSongs = currentPlaylist.songs;
    notifyListeners();
  }

  void getCurrentPlaylist() {
    currentPlaylist =_audioPlayerService.currentPlaylist;
    notifyListeners();
  }

  Future getCurrentSong() async {
    currentSong = await _audioPlayerService.getCurrentSong();
    notifyListeners();
  }

  void removeSongFromPlaylist(Song song) {
    _audioPlayerService.currentPlaylist.removeSong(song);
    currentPlaylist = _audioPlayerService.currentPlaylist;
    notifyListeners();
  }

  Future<void> seekIndex(int index) async {
    await _audioPlayerService.seekIndex(index);
    await getCurrentSong();
  }
}
