import 'package:myapp/core/view_models/page_models/base_model.dart';

import '../../../locater.dart';
import '../../../models/playlist.dart';
import '../../../models/song.dart';
import '../../services/audio_player_service.dart';

class QueueModel extends BaseModel {
  final AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();

  void onReorder(int to, int from) {
    if (to > from) {
      to--;
    }
    Song temp = Song.fromSong(_audioPlayerService.currentPlaylist.songs[to]);

    _audioPlayerService.currentPlaylist.songs[to] =
        _audioPlayerService.currentPlaylist.songs[from];
    _audioPlayerService.currentPlaylist.songs[from] = temp;
    notifyListeners();
  }

  Playlist getCurrentPlaylist() {
    return _audioPlayerService.currentPlaylist;
  }

  Future<Song> getCurrentSong() async {
    return await _audioPlayerService.getCurrentSong();
  }

  void removeSongFromPlaylist(Song song) {
    _audioPlayerService.currentPlaylist.removeSong(song);
  }

  Future<void> seekIndex(int index) async {
    await _audioPlayerService.seekIndex(index);
  }
}
