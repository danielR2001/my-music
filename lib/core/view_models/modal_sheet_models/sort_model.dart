import 'package:myapp/core/enums/sort_type.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';

import '../../../models/playlist.dart';
import '../../../models/song.dart';

class SortModel extends BaseModel {
  Playlist _pagePlaylist;

  get pagePlaylist => _pagePlaylist;

  set setPagePlaylist(Playlist playlist) => _pagePlaylist = playlist;

  void sortPlaylist(SortType sortType) {
    _pagePlaylist.setSongs = _sortList(sortType, _pagePlaylist);
    _pagePlaylist.setSortedType = sortType;
    notifyListeners();
  }

  List<Song> _sortList(SortType sortType, Playlist playlist) { //! TODO actually sorting! 
    List<Song> sortedPlaylist = playlist.songs;
    if (sortType == SortType.recentlyAdded) {
      sortedPlaylist.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
    } else if (sortType == SortType.title) {
      sortedPlaylist.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortType == SortType.artist) {
      sortedPlaylist.sort((a, b) => a.artist.compareTo(b.artist));
    }
    return sortedPlaylist;
  }
}
