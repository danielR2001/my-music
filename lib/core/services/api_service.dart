import 'package:myapp/core/api/api_manager.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/song.dart';

class ApiService {
  final ApiManager _apiManager = locator<ApiManager>();

  //all functions may return null = ERROR
  Future<List<Song>> getSearchResults(String searchStr) async {
    return await _apiManager.getSearchResults(searchStr);
  }

  Future<Artist> getArtistImageUrl(String artistName) async {
    return await _apiManager.getArtistImageUrl(artistName);
  }

  Future<String> getLyricsPageUrl(Song song) async {
    return await _apiManager.getLyricsPageUrl(song);
  }

  Future<String> getSongLyrics(String url) async {
    return await _apiManager.getSongLyrics(url);
  }
}
