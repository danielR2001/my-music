import 'package:flutter/material.dart';
import 'package:myapp/core/enums/page_state.dart';
import 'package:myapp/core/services/api_service.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/services/tab_navigation_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';

class SearchModel extends BaseModel {
  final ApiService _apiService = locator<ApiService>();
  final AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();
  final TabNavigationService _tabNavigationService =
      locator<TabNavigationService>();

  String _lastSearch;
  List<Song> _results = List();
  Playlist _searchResultsPlaylist;
  bool _noResultsFound = false;
  bool _mounted;

  String get lastSearch => _lastSearch;

  List<Song> get results => _results;

  bool get noResultsFound => _noResultsFound;

  Playlist get searchResultsPlaylist => _searchResultsPlaylist;

  bool get mounted => _mounted;

  GlobalKey<NavigatorState> get tabNavigatorKey =>
      _tabNavigationService.tabNavigatorKey;

  Future<void> getSearchResults(String searchStr) async {
    setState(PageState.Busy);
    _noResultsFound = false;
    notifyListeners();
    List<Song> temp = await _apiService.getSearchResults(searchStr);
    if (temp != null) {
      if (temp.length > 0) {
        if (temp.length > 10) {
          temp = temp.sublist(0, 10);
        }
        _results = List.from(temp);
        _searchResultsPlaylist = Playlist("Search Playlist");
        _searchResultsPlaylist.setSongs = _results;
        _lastSearch = searchStr;
        if (!_mounted) {
          notifyListeners();
          setState(PageState.Idle);
        }
      }
    } else {
      _noResultsFound = true;
      if (!_mounted) {
        notifyListeners();
        setState(PageState.Idle);
      }
    }
  }

  Future<void> initModel() async {
    _mounted = false;
    if (_lastSearch != null) {
      await getSearchResults(_lastSearch);
    }
  }

  void disposeModel() {
    _mounted = true;
  }

  Future<void> play(int index) async {
    await _audioPlayerService.initPlaylist(
        _searchResultsPlaylist, PlaylistMode.loop, index, false);
  }
}
