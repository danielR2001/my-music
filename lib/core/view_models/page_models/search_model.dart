import 'package:myapp/core/services/api_service.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';

class SearchModel extends BaseModel {
  final ApiService _apiService = locator<ApiService>();
    final AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();
  String _lastSearch;
  List<Song> _results;
  Playlist _searchResultsPlaylist;
  bool _loadingResults = false;
  bool _noResultsFound = false;

  String get lastSearch => _lastSearch;

  List<Song> get results => _results;

  bool get loadingResults => _loadingResults;

  bool get noResultsFound => _noResultsFound;

  Playlist get searchResultsPlaylist => _searchResultsPlaylist;

  set setResults(List<Song> list) => _results = list;

  Future<void> getSearchResults(String searchStr) async {
    _loadingResults = true;
    _noResultsFound = false;
    notifyListeners();
    List<Song> temp = await _apiService.getSearchResults(searchStr);
    if (temp != null) {
      _results = List.from(temp);
      _lastSearch = searchStr;
      _loadingResults = false;
      _searchResultsPlaylist = Playlist("Search Playlist");
      _searchResultsPlaylist.setSongs = _results;
      notifyListeners();
    }else{
      _noResultsFound = true;
    }
    notifyListeners();
  }

   Future<void> play(int index) async {
    await _audioPlayerService.initPlaylist(
        _searchResultsPlaylist, PlaylistMode.loop, index, false);
  }
}
