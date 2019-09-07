import 'dart:async';
import 'package:myapp/core/database/local/local_database_manager.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/core/enums/page_state.dart';
import 'package:myapp/core/services/api_service.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/services/local_database_service.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';

class ArtistModel extends BaseModel {
  final AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();
  final LocalDatabaseService _localDatabaseService =
      locator<LocalDatabaseService>();
  final ApiService _apiService = locator<ApiService>();

    final String smallArtistImageUrl =
      "https://ichef.bbci.co.uk/images/ic/160x160/p01bnb07.png";
  final String bigArtistImageUrl =
      "https://www.collegeatlas.org/wp-content/uploads/2014/06/Top-Party-Schools-main-image.jpg";

  StreamSubscription<Map<String, int>> _onDownloadProgresses;

  StreamSubscription<Map<String, int>> _onDownloadTotals;

  StreamSubscription<Map<String, bool>> _onDownloadStops;

  StreamSubscription<Map<String, DownloadError>> _onDownloadErors;

  StreamSubscription<int> _playerIndexStream;

  Map<String, int> _progressesMap;
  Map<String, int> _totalsMap;
  Artist _artist;
  Playlist _pagePlaylist;
  Song _currentSong;
  bool _mounted;

  Playlist get pagePlaylist => _pagePlaylist;

  Artist get artist => _artist;

  set setArtist(Artist artist) => _artist = artist;

  int progress(String songId) => _progressesMap[songId];

  int total(String songId) => _totalsMap[songId];

  Future<void> loadArtistPlaylist() async {
    setState(PageState.Busy);
    List<Song> songs = List();
    List<Song> results = await _apiService.getSearchResults(_artist.name);
    if (results != null) {
      results.forEach((song) {
        if (song.artist.toLowerCase().contains(_artist.name.toLowerCase()) ||
            song.title.toLowerCase().contains(_artist.name.toLowerCase())) {
          songs.add(song);
        }
      });
      Playlist temp = Playlist(_artist.name + " Top Hits");
      temp.setSongs = songs;
      _pagePlaylist = temp;
    }
    if (!_mounted) {
      notifyListeners();
      setState(PageState.Idle);
    }
  }

  bool isPagePlaylistIsPlaying() {
    return _pagePlaylist.pushId == _audioPlayerService.currentPlaylist.pushId;
  }

  bool isSongPlaying(Song song) {
    return _currentSong.songId == song.songId;
  }

  Future<void> play(int index) async {
    await _audioPlayerService.initPlaylist(
        _pagePlaylist, PlaylistMode.loop, index, false);
  }

  void initStreams() {
    _playerIndexStream =
        _audioPlayerService.onPlayerIndexChangedStream().listen((index) {
      _currentSong = _audioPlayerService.currentPlaylist.songs.elementAt(index);
    });
    _onDownloadProgresses =
        _localDatabaseService.onDownloadProgresses.listen((_progressMap) {
      _progressesMap = Map.from(_progressMap);
      notifyListeners();
    });
    _onDownloadTotals =
        _localDatabaseService.onDownloadTotals.listen((totalMap) {
      _totalsMap = Map.from(totalMap);
      notifyListeners();
    });
    _onDownloadStops =
        _localDatabaseService.onDownloadStops.listen((reasonMap) {
      // TODO
    });
    _onDownloadErors = _localDatabaseService.onDownloadErors.listen((errorMap) {
      // TODO
    });
  }

  bool isSongDownloading(Song song) {
    return _localDatabaseService.isSongDownloading(song);
  }

  Future<void> cancelDownLoad(Song song) async {
    await _localDatabaseService.cancelDownLoad(song);
  }

  Future<void> initModel(Artist artist) async {
    _currentSong = await _audioPlayerService.getCurrentSong();
    _mounted = false;
    _artist = artist;
    loadArtistPlaylist();
    initStreams();
    notifyListeners();
  }

  Future<void> disposeModel() async {
    _mounted = true;
    await _onDownloadProgresses.cancel();
    await _onDownloadTotals.cancel();
    await _onDownloadStops.cancel();
    await _onDownloadErors.cancel();
    await _playerIndexStream.cancel();
  }
}
