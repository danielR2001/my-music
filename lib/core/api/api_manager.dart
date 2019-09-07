import 'dart:convert';
import 'package:html/dom.dart' as html;
import 'package:html_unescape/html_unescape.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/song.dart';
import 'package:html/parser.dart' show parse;
import 'package:dio/dio.dart';

class ApiManager {
  static final String searchUrl = 'https://mp3-tut.com/search?query=';
  static final String siteUrl = 'https://mp3-tut.com';
  static final String playUrl = 'https://download.mp3-tut.com/';
  static final String imageSearchUrl =
      'https://free-mp3-download.net/search.php?s=';
  static final String artistIdUrl =
      'https://www.bbc.co.uk/music/search.json?q=';
  static final String artistInfoSearchUrl =
      'https://www.bbc.co.uk/music/artists/';
  static final String lyricsSearchUrl =
      'https://genius.com/api/search/multi?q=';
  static final String artistImageUrl =
      "https://ichef.bbci.co.uk/images/ic/960x540/";

  bool _searchCompleted = true;
  CancelToken _songSearchCancelToken = CancelToken();

  Future<List<Song>> getSearchResults(String searchStr) async {
    if (!_searchCompleted) {
      _songSearchCancelToken.cancel("cancelled");
      _songSearchCancelToken = CancelToken();
    }
    _searchCompleted = false;
    var responseList;
    try {
      Response response = await Dio().get(
        searchUrl + searchStr,
        cancelToken: _songSearchCancelToken,
      );
      print('Search For Results completed');
      _searchCompleted = true;
      var elements = parse(response.data)?.getElementsByClassName("list-view");
      var html = elements[0].innerHtml;
      html = html.replaceAll('\n', '');
      responseList = html.split('<div class="play-button-container">');
      responseList.removeAt(0);
      return await _buildSearchResult(
          responseList, searchUrl + searchStr + "/");
    } on DioError catch (e) {
      if (e.message == "cancelled") {
        return List();
      }
      _searchCompleted = true;
      return null;
    } catch (e) {
      print(e);
      _searchCompleted = true;
      return null;
    }
  }

  Future<String> _getSongImageUrl(String title, String artist,
      {bool secondTry = false}) async {
    String imageUrl;
    String tempTitle = title;
    tempTitle = _editSearchParams(tempTitle, true, true);
    String tempArtist = artist;
    tempArtist = _editSearchParams(tempArtist, secondTry, true);
    imageUrl = tempTitle + " " + tempArtist;
    var encoded = Uri.encodeFull(imageSearchUrl + imageUrl);
    try {
      Response response =
          await Dio().get(encoded, cancelToken: _songSearchCancelToken);
      print('image search completed: $imageUrl');

      List<dynamic> list = jsonDecode(response.data)['data'];
      if (list.length > 0) {
        return _getImageUrlFromResponse(list);
      } else {
        if (!secondTry) {
          return _getSongImageUrl(title, artist, secondTry: true);
        } else {
          return null;
        }
      }
    } on DioError catch (e) {
      print(e);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Artist> getArtistImageUrl(String artistName) async {
    String name = artistName;
    if (artistName.contains(" ")) {
      name = name.replaceAll(" ", "+");
    }
    try {
      Response response = await Dio().get(
        artistIdUrl + name,
      );
      print('get Artist ImageUrl search completed');

      List<dynamic> list = response.data['artists'];
      if (list.length > 0) {
        return Artist(artistName, artistImageUrl + list[0]["image_id"]);
      } else {
        return Artist(artistName, artistImageUrl + "p01bnb07.png");
      }
    } on DioError catch (e) {
      print(e);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> _getLyricsPageUrl(Song song) async {
    String title = _editSearchParams(song.title, true, true);
    String artist = _editSearchParams(song.artist, false, false);
    String searchStr = title + " " + artist;
    var encoded = Uri.encodeFull(lyricsSearchUrl + searchStr);
    var list;
    var sectionsMap;
    var sectionsList;
    var hitsList;
    var resultsList;
    try {
      Response response = await Dio().get(encoded);
      print('lyrics page search completed');

      list = response.data['response'];
      sectionsList = list['sections'];
      sectionsMap = sectionsList[1];
      hitsList = sectionsMap['hits'];
      if (hitsList.length > 0) {
        resultsList = hitsList[0]['result'];
        return resultsList['url'];
      } else {
        return null;
      }
    } on DioError catch (e) {
      print(e);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> getSongLyrics(Song song) async {
    String url = await _getLyricsPageUrl(song);
    try {
      Response response = await Dio().get(url);
      print('lyrics search completed');
      html.Document document = parse(response.data);
      return _buildLyrics(document);
    } on DioError catch (e) {
      print(e);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  String _getImageUrlFromResponse(List<dynamic> songValues) {
    int index = 0;
    while (songValues[index]['title'].contains("8-Bit") ||
        songValues[index]['title'].contains("16-Bit")) {
      index++;
    }
    Map album = songValues[index]['album'];
    return album['cover_big'];
  }

  //! FIX ME
  String _editSearchParams(String str, bool isTitle, bool isHebrewCheck) {
    if (isHebrewCheck) {
      if (!RegExp(r"^[a-zA-Zа-яА-Яё0-9\$!?&\()\[\]'/$\. ]+$").hasMatch(str) &&
          isTitle) {
        if (str.contains("(")) {
          str = str.substring(str.indexOf("(") + 1, str.indexOf(")"));
        }
      } else {
        if (str.contains("(")) {
          str = str.substring(0, str.indexOf("("));
        }
      }
    } else {
      if (str.contains("(")) {
        str = str.substring(0, str.indexOf("("));
      }
    }
    if (str.contains("[")) {
      str = str.substring(0, str.indexOf("["));
    }
    if (str.contains("'")) {
      str = str.replaceAll("'", " ");
    }
    if (isTitle) {
      if (str.contains("feat.")) {
        int pos = str.indexOf("feat.");
        str = str.substring(0, pos);
      }
      if (str.contains("ft.")) {
        int pos = str.indexOf("ft.");
        str = str.substring(0, pos);
      }
      if (str.contains("vs.")) {
        int pos = str.indexOf("vs.");
        str = str.substring(0, pos);
      }
      if (str.contains("vs")) {
        int pos = str.indexOf("vs");
        str = str.substring(0, pos);
      }
      if (str.contains(",")) {
        int pos = str.indexOf(",");
        str = str.substring(0, pos);
      }
      if (str.contains("&")) {
        int pos = str.indexOf("&");
        str = str.substring(0, pos);
      }
    } else {
      if (str.contains("feat.")) {
        str = str.replaceAll("feat.", "");
      }
      if (str.contains("ft.")) {
        str = str.replaceAll("ft.", "");
      }
      if (str.contains("vs.")) {
        str = str.replaceAll("vs.", "");
      }
      if (str.contains("vs")) {
        str = str.replaceAll("vs", "");
      }
      if (str.contains(",")) {
        str = str.replaceAll(",", "");
      }
      if (str.contains("&")) {
        str = str.replaceAll("&", "");
      }
    }
    if (str.contains("   ")) {
      str = str.replaceAll("   ", " ");
    }
    if (str.contains("  ")) {
      str = str.replaceAll("  ", " ");
    }
    if (str.contains(".")) {
      str = str.replaceAll(".", " ");
    }
    if (str.contains("?")) {
      str = str.replaceAll("?", "");
    }
    if (str.contains("!")) {
      str = str.replaceAll("!", "");
    }
    if (str.contains("-")) {
      str = str.replaceAll("-", " ");
    }
    str = str.trimRight();
    return str;
  }

  Future<List<Song>> _buildSearchResult(
      List<String> list, String searchString) async {
    List<Future<Song>> futures = List();
    List<Song> songs = List();
    if (list.length > 0) {
      if (list.length > 10) {
        list = list.sublist(0, 10);
      }
      for (String item in list) {
        futures.add(_buildSong(item));
      }
      songs = await Future.wait(futures, eagerError: true);
      return songs;
    } else {
      return null;
    }
  }

  String _buildLyrics(html.Document document) {
    List<html.Element> songBody;
    String lyrics;
    songBody = document.getElementsByClassName("song_body-lyrics");
    lyrics = songBody[0].text;
    lyrics = lyrics.replaceAll("More on Genius", "");
    lyrics = lyrics.substring(
        lyrics.lastIndexOf("Lyrics") + "Lyrics".length, lyrics.length);
    lyrics = lyrics.replaceAll("]", "]\n");
    lyrics = lyrics.trimRight();
    lyrics = lyrics.trimLeft();
    return lyrics;
  }

  Future<Song> _buildSong(String item) async {
    String imageUrl;
    String songTitle;
    String artist;
    String songId;
    String searchString;
    String playUrl;
    HtmlUnescape unescape = HtmlUnescape();

    searchString = item.substring(
        item.indexOf('data-audiofile="') + 'data-audiofile="'.length,
        item.indexOf('data-title='));
    searchString = searchString.replaceFirst("amp;", "");
    playUrl = await _getSongPlayUrl(searchString);

    artist = item.substring(
        item.indexOf('<div class="title"><a href=') +
            '<div class="title"><a href='.length,
        item.indexOf('</a></div'));
    item = item.replaceFirst('<div class="title">', "");
    artist = artist.substring(artist.indexOf('>') + 1, artist.length);
    artist = unescape.convert(artist);

    songTitle = item.substring(
        item.indexOf('<div class="title">') + '<div class="title">'.length,
        item.indexOf('</div>    </div>'));
    songTitle = unescape.convert(songTitle);

    songId = item.substring(
        item.indexOf('https://mp3-tut.com/musictutplay?id=') +
            'https://mp3-tut.com/musictutplay?id='.length,
        item.indexOf('&amp;hash='));
    imageUrl = await _getSongImageUrl(songTitle, artist);
    //imageUrl = "";
    return Song(songTitle, artist, songId, playUrl, imageUrl, '');
  }

  Future<String> _getSongPlayUrl(String url) async {
    Response response =
        await Dio().head(url, cancelToken: _songSearchCancelToken);
    print('song play Url search completed: $url');
    if (response.redirects.length == 2) {
      return playUrl + response.redirects[1].location.path;
    } else {
      return playUrl + response.redirects[0].location.path;
    }
  }
}
