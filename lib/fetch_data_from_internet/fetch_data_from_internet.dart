import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/dom.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/song.dart';
import 'package:html/parser.dart' show parse;
import 'package:dio/dio.dart';

class FetchData {
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

  static Future<Map<String, List<Song>>> getSearchResults(
      String searchStr) async {
    var responseList;
    try {
      Response response = await Dio().get(
        searchUrl + searchStr,
      );
      print('Search For Results 1 search completed');

      var document = parse(response.data);
      var elements = document.getElementsByClassName("list-view");
      var html = elements[0].outerHtml;
      html = html.replaceAll('\n', '');
      responseList = html.split('<div class="play-button-container">');
      responseList.removeAt(0);
      Map<String, List<Song>> resultsMap = Map();
      resultsMap[searchStr] =
          _buildSearchResult(responseList, searchUrl + searchStr + "/");
      return resultsMap;
    } on DioError catch (e) {
      print(e);
      _makeToast(text: "No network connection");
      return null;
    } catch (e) {
      print(e);
      _makeToast(text: "Something went wrong");
      return null;
    }
  }

  static Future<String> getSongPlayUrl(Song song) async {
    var responseList;
    String songTitle = song.getTitle;
    songTitle = _editSearchParams(songTitle, true, true);
    if (songTitle.contains(" ")) {
      songTitle = songTitle.replaceAll(" ", "+");
    }
    var encoded = Uri.encodeFull(songTitle);
    String url = siteUrl + song.getSearchString + "+" + encoded;
    try {
      Response response = await Dio().get(url);
      print('song search completed');
      var document = parse(response.data);
      var elements = document.getElementsByClassName("list-view");
      var html = elements[0].outerHtml;
      html = html.replaceAll('\n', '');
      responseList = html.split('<div class="play-button-container">');
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
      _makeToast(text: "No network connection");
      return null;
    } catch (e) {
      print(e);
      _makeToast(text: "Something went wrong");
      return null;
    }
  }

  static Future<String> getSongImageUrl(Song song, bool secondTry) async {
    String imageUrl;
    String tempTitle = song.getTitle;
    tempTitle = _editSearchParams(tempTitle, true, true);
    String tempArtist = song.getArtist;
    tempArtist = _editSearchParams(tempArtist, secondTry, true);
    imageUrl = tempTitle + " " + tempArtist;
    var encoded = Uri.encodeFull(imageSearchUrl + imageUrl);
    try {
      Response response = await Dio().get(encoded);
      print('image search completed');

      List<dynamic> list = jsonDecode(response.data)['data'];
      if (list.length > 0) {
        return _getImageUrlFromResponse(list[0]);
      } else {
        if (!secondTry) {
          return getSongImageUrl(song, true);
        } else {
          return null;
        }
      }
    } on DioError catch (e) {
      print(e);
      _makeToast(text: "Bad network connection");
      return null;
    } catch (e) {
      print(e);
      _makeToast(text: "Something went wrong");
      return null;
    }
  }

  static Future<Artist> getArtistPageIdAndImageUrl(String artistName) async {
    String name = artistName;
    if (artistName.contains(" ")) {
      name = name.replaceAll(" ", "+");
    }
    try {
      Response response = await Dio().get(
        artistIdUrl + name,
      );
      print('Get Artist Info search completed');

      List<dynamic> list = response.data['artists'];
      if (list.length > 0) {
        return Artist(artistName,
            "https://ichef.bbci.co.uk/images/ic/160x160/" + list[0]["image_id"],
            id: list[0]["id"]);
      } else {
        return Artist(artistName,
            "https://ichef.bbci.co.uk/images/ic/160x160/p01bnb07.png",
            info: "");
      }
    } on DioError catch (e) {
      print(e);
      _makeToast(text: "No network connection");
      return null;
    } catch (e) {
      print(e);
      _makeToast(text: "Something went wrong");
      return null;
    }
  }

  static Future<Artist> getArtistInfoPage(Artist artist) async {
    try {
      Response response = await Dio().get(
        artistInfoSearchUrl + artist.getId,
      );
      print('Get Artist Info search completed');
      Document document = parse(response.data);
      return _buildArtist(document, artist);
    } on DioError catch (e) {
      print(e);
      _makeToast(text: "No network connection");
      return null;
    } catch (e) {
      print(e);
      _makeToast(text: "Something went wrong");
      return null;
    }
  }

  static Future<String> getLyricsPageUrl(Song song) async {
    String title = _editSearchParams(song.getTitle, true, true);
    String artist = _editSearchParams(song.getArtist, false, false);
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
      _makeToast(text: "No network connection");
      return null;
    } catch (e) {
      print(e);
      _makeToast(text: "Something went wrong");
      return null;
    }
  }

  static Future<String> getSongLyrics(String url) async {
    try {
      Response response = await Dio().get(url);
      print('lyrics search completed');
      Document document = parse(response.data);
      return _buildLyrics(document);
    } on DioError catch (e) {
      print(e);
      _makeToast(text: "No network connection");
      return null;
    } catch (e) {
      print(e);
      _makeToast(text: "Something went wrong");
      return null;
    }
  }

  static Artist _buildArtist(Document document, Artist artist) {
    String info;
    String imageUrl;
    List infoElement;
    List imageUrlElement;
    if (artist.getImageUrl !=
        "https://ichef.bbci.co.uk/images/ic/160x160/p01bnb07.png") {
      imageUrlElement = document.getElementsByClassName("artist-image");
      imageUrl = imageUrlElement[0].innerHtml;
      imageUrl = imageUrl.substring(
          imageUrl.indexOf('data-default-src="') + 'data-default-src="'.length,
          imageUrl.indexOf('"> <source srcset='));
    } else {
      imageUrl = "https://ichef.bbci.co.uk/images/ic/160x160/p01bnb07.png";
    }
    infoElement = document.getElementsByClassName("msc-artist-biography-text");
    if (infoElement.length > 0) {
      info = infoElement[0].innerHtml;
      info = info.substring(3, info.length - 4);
      info = info.replaceAll("</p><p>", "\n\n");
      info = info.replaceAll("amp;", "");
      info = info.replaceAll("Â&nbsp;â", " -");
      info = info.replaceAll(RegExp("[^\\x00-\\x7F]"), "");
      info = info.replaceAll(";", "");
    } else {
      info = "";
    }
    artist.setInfo = info;
    artist.setImageUrl = imageUrl;
    return artist;
  }

  static String _getImageUrlFromResponse(Map songValues) {
    Map album = songValues['album'];
    return album['cover_big'];
  }

  static String _editSearchParams(String str, bool isTitle, bool isImageUrl) {
    if (isImageUrl) {
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
    if (str.contains(".")) {
      str = str.replaceAll(" .", " ");
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
    if (str.contains("   ")) {
      str = str.replaceAll("   ", " ");
    }
    if (str.contains("  ")) {
      str = str.replaceAll("  ", " ");
    }
    str = str.trimRight();
    return str;
  }

  static String _buildStreamUrl(List<String> list, Song song) {
    String songId;
    String strSong;
    String stream;
    if (list != null) {
      for (int i = 0; i < list.length; i++) {
        songId = list[i].substring(
            list[i].indexOf('https://mp3-tut.com/musictutplay?id=') +
                'https://mp3-tut.com/musictutplay?id='.length,
            list[i].indexOf('&amp;hash='));
        if (songId == song.getSongId) {
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

  static List<Song> _buildSearchResult(List<String> list, String searchString) {
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

  static String _buildLyrics(Document document) {
    List songBody;
    String lyrics;
    songBody = document.getElementsByClassName("song_body-lyrics");
    lyrics = songBody[0].innerHtml;
    lyrics = lyrics.substring(
        lyrics.indexOf("<!--sse-->") + "<!--sse-->".length,
        lyrics.indexOf("<!--/sse-->"));
    lyrics = lyrics.replaceAll("<br>", "\n");
    lyrics = lyrics.replaceAll("<p>", "");
    lyrics = lyrics.replaceAll("</p>", "");
    lyrics = lyrics.trimLeft();
    lyrics = lyrics.trimRight();
    while (lyrics.contains("<a href=")) {
      lyrics = lyrics.replaceAll(
          lyrics.substring(
              lyrics.indexOf('<a href='),
              lyrics.indexOf('pending-editorial-actions-count="') +
                  'pending-editorial-actions-count="'.length +
                  3),
          "");
    }
    lyrics = lyrics.replaceAll("</a>", "");
    if (lyrics.contains("&nbsp;")) {
      lyrics = lyrics.replaceAll("&nbsp;", "");
    }
    if (lyrics.contains("amp;")) {
      lyrics = lyrics.replaceAll("amp;", "");
    }
    if (lyrics.contains("<i>")) {
      lyrics = lyrics.replaceAll("<i>", "");
      lyrics = lyrics.replaceAll("</i>", "");
    }
    if (lyrics.contains(">")) {
      lyrics = lyrics.replaceAll(">", "");
    }
    return lyrics;
  }

  static void _makeToast({String text}) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIos: 1,
      fontSize: 16.0,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: GlobalVariables.pinkColor,
      textColor: Colors.white,
    );
  }
}
