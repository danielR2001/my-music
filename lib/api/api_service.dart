import 'dart:convert';
import 'package:html/dom.dart' as html;
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/song.dart';
import 'package:html/parser.dart' show parse;
import 'package:dio/dio.dart';
import 'package:myapp/managers/toast_manager.dart';

class ApiService {
  static final String searchUrl = 'https://mp3-tut.com/search?query=';
  static final String siteUrl = 'https://mp3-tut.com';
  static final String playUrl = 'https://music.xn--41a.ws';
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

  bool searchCompleted = true;
  CancelToken songSearchCancelToken = CancelToken(); //TODO add cancel search

  Future<List<Song>> getSearchResults(String searchStr) async {
    if (!searchCompleted) {
      songSearchCancelToken.cancel("cancelled");
      songSearchCancelToken = CancelToken();
    }
    searchCompleted = false;
    var responseList;
    try {
      Response response = await Dio().get(
        searchUrl + searchStr,
        cancelToken: songSearchCancelToken,
      );
      print('Search For Results completed');
      searchCompleted = true;
      var elements = parse(response.data)?.getElementsByClassName("list-view");
      var html = elements[0].outerHtml;
      html = html.replaceAll('\n', '');
      responseList = html.split('<div class="play-button-container">');
      responseList.removeAt(0);
      return _buildSearchResult(responseList, searchUrl + searchStr + "/");
    } on DioError catch (e) {
      if (e.message == "cancelled") {
        return List();
      }
      searchCompleted = true;
      return null;
    } catch (e) {
      print(e);
      GlobalVariables.toastManager
          .makeToast(text: ToastManager.somethingWentWrong);
      searchCompleted = true;
      return null;
    }
  }

  Future<String> getSongPlayUrl(Song song) async {
    var responseList;
    String songTitle = song.title;
    songTitle = _editSearchParams(songTitle, true, true);
    if (songTitle.contains(" ")) {
      songTitle = songTitle.replaceAll(" ", "+");
    }
    var encoded = Uri.encodeFull(songTitle);
    String url = siteUrl + song.searchString + "+" + encoded;
    try {
      Response response = await Dio().get(url);
      print('song search completed');
      html.Document document = parse(response.data);
      var elements = document.getElementsByClassName("list-view");
      var html1 = elements[0].outerHtml;
      html1 = html1.replaceAll('\n', '');
      responseList = html1.split('<div class="play-button-container">');
      responseList.removeAt(0);
      String streamUrl = _buildStreamUrl(responseList, song);
      if (streamUrl != null) {
        if (streamUrl.contains("amp;")) {
          streamUrl = streamUrl.replaceAll("amp;", "");
        }
      }
      return streamUrl;
    } on DioError catch (e) {
      print(e);
      GlobalVariables.toastManager
          .makeToast(text: ToastManager.noNetworkConnection);
      return null;
    } catch (e) {
      print(e);
      GlobalVariables.toastManager
          .makeToast(text: ToastManager.somethingWentWrong);
      return null;
    }
  }

  Future<String> getSongImageUrl(Song song, bool secondTry) async {
    String imageUrl;
    String tempTitle = song.title;
    tempTitle = _editSearchParams(tempTitle, true, true);
    String tempArtist = song.artist;
    tempArtist = _editSearchParams(tempArtist, secondTry, true);
    imageUrl = tempTitle + " " + tempArtist;
    var encoded = Uri.encodeFull(imageSearchUrl + imageUrl);
    try {
      Response response = await Dio().get(encoded);
      print('image search completed');

      List<dynamic> list = jsonDecode(response.data)['data'];
      if (list.length > 0) {
        return _getImageUrlFromResponse(list);
      } else {
        if (!secondTry) {
          return getSongImageUrl(song, true);
        } else {
          return null;
        }
      }
    } on DioError catch (e) {
      print(e);
      GlobalVariables.toastManager
          .makeToast(text: ToastManager.badNetworkConnection);
      return null;
    } catch (e) {
      print(e);
      GlobalVariables.toastManager
          .makeToast(text: ToastManager.somethingWentWrong);
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
      GlobalVariables.toastManager
          .makeToast(text: ToastManager.noNetworkConnection);
      return null;
    } catch (e) {
      print(e);
      GlobalVariables.toastManager
          .makeToast(text: ToastManager.somethingWentWrong);
      return null;
    }
  }

  Future<String> getLyricsPageUrl(Song song) async {
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
      GlobalVariables.toastManager
          .makeToast(text: ToastManager.noNetworkConnection);
      return null;
    } catch (e) {
      print(e);
      GlobalVariables.toastManager
          .makeToast(text: ToastManager.somethingWentWrong);
      return null;
    }
  }

  Future<String> getSongLyrics(String url) async {
    try {
      Response response = await Dio().get(url);
      print('lyrics search completed');
      html.Document document = parse(response.data);
      return _buildLyrics(document);
    } on DioError catch (e) {
      print(e);
      GlobalVariables.toastManager
          .makeToast(text: ToastManager.noNetworkConnection);
      return null;
    } catch (e) {
      print(e);
      GlobalVariables.toastManager
          .makeToast(text: ToastManager.somethingWentWrong);
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

  String _buildStreamUrl(List<String> list, Song song) {
    String songId;
    String strSong;
    String stream;
    if (list != null) {
      for (int i = 0; i < list.length; i++) {
        songId = list[i].substring(
            list[i].indexOf('https://mp3-tut.com/musictutplay?id=') +
                'https://mp3-tut.com/musictutplay?id='.length,
            list[i].indexOf('&amp;hash='));
        if (songId == song.songId) {
          strSong = list[i];
          break;
        }
      }

      if (strSong != null) {
        stream = strSong.substring(
            strSong.indexOf('data-audiofile="') + 'data-audiofile="'.length,
            strSong.indexOf('data-title='));
      }
    }
    return stream;
  }

  List<Song> _buildSearchResult(List<String> list, String searchString) {
    String imageUrl;
    String songTitle;
    String artist;
    String songId;
    String searchString;
    List<Song> songs = List();
    if (list.length > 0) {
      list.forEach((item) {
        if (item.contains("amp;")) {
          item = item.replaceAll("amp;", "");
        }
        imageUrl = '';

        searchString = item.substring(
            item.indexOf('<div class="title"><a href=') +
                '<div class="title"><a href='.length,
            item.indexOf('</a></div'));
        searchString = searchString.replaceRange(
            searchString.indexOf(">"), searchString.length, "");
        searchString = searchString.replaceAll('"', "");
        if (searchString.contains("+%26amp%3B")) {
          searchString = searchString.replaceAll("+%26amp%3B", "");
        }

        artist = item.substring(
            item.indexOf('<div class="title"><a href=') +
                '<div class="title"><a href='.length,
            item.indexOf('</a></div'));
        item = item.replaceFirst('<div class="title">', "");
        artist = artist.substring(artist.indexOf('>') + 1, artist.length);

        songTitle = item.substring(
            item.indexOf('<div class="title">') + '<div class="title">'.length,
            item.indexOf('</div>    </div>'));

        songId = item.substring(
            item.indexOf('https://mp3-tut.com/musictutplay?id=') +
                'https://mp3-tut.com/musictutplay?id='.length,
            item.indexOf('&hash='));

        songs.add(Song(songTitle, artist, songId, searchString, imageUrl, ''));
      });
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
}
