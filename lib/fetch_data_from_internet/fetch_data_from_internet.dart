import 'dart:convert';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/communicate_with_native/remove_accent_chars.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/song.dart';
import 'package:html/parser.dart' show parse;

class FetchData {
  //static final String searchUrl = 'https://ru-music.com/search/';
  static final String searchUrl = 'https://music.xn--41a.ws/search/';
  static final String playUrl = 'https://music.xn--41a.ws';
  static final String imageSearchUrl =
      'https://free-mp3-download.net/search.php?s=';
  static final String artistIdUrl =
      'https://www.bbc.co.uk/music/search.json?q=';
  static final String artistInfoSearchUrl =
      'https://www.bbc.co.uk/music/artists/';
  static final String lyricsSearchUrl =
      'https://genius.com/api/search/multi?q=';

  static Future<List<Song>> getResultsSitePage1(String searchStr) async {
    searchStr = await _prepareStringToSearch(searchStr);
    searchStr = searchStr.replaceAll(" ", "-");
    var encoded = Uri.encodeFull(searchUrl + searchStr + "/");
    try {
      return http
          .get(
            encoded,
          )
          .catchError((eror) => print("error getResultsSitePage1"))
          .whenComplete(() => print('Search For Results 1 search completed'))
          .then((http.Response response) async {
        var document = parse(response.body);
        if (!document.outerHtml.contains("Ошибка 404 - страница не найдена")) {
          var elements = document.getElementsByClassName("playlist");
          var html = elements[0].outerHtml;
          html = html.replaceAll('\n', '');
          html = html.replaceFirst('<ul class="playlist">', '');
          var a = html.split("</li>");
          return _buildSearchResult(a, searchUrl + searchStr + "/");
        } else {
          return await getResultsSitePage2(searchStr);
        }
      });
    } catch (e) {
      return await getResultsSitePage2(searchStr);
    }
  }

  static Future<List<Song>> getResultsSitePage2(String searchStr) async {
    var encoded = Uri.encodeFull(searchUrl + searchStr + "/2");
    try {
      return http
          .get(
            encoded,
          )
          .catchError((eror) => print("error getResultsSitePage2"))
          .whenComplete(() => print('Search For Results 2 search completed'))
          .then((http.Response response) {
        var document = parse(response.body);
        if (!document.outerHtml.contains("Ошибка 404 - страница не найдена")) {
          var elements = document.getElementsByClassName("playlist");
          var html = elements[0].outerHtml;
          html = html.replaceAll('\n', '');
          html = html.replaceFirst('<ul class="playlist">', '');
          var a = html.split("</li>");
          return _buildSearchResult(a, searchUrl + searchStr + "/");
        }
        return null;
      });
    } catch (e) {
      return null;
    }
  }

  static Future<String> getSongPlayUrlPage1(Song song) async {
    var responseList;
    String searchStr = song.getSearchString;
    searchStr = await _prepareStringToSearch(searchStr);
    searchStr = searchStr.replaceAll(" ", "-");
    var encoded = Uri.encodeFull(searchUrl + searchStr);
    try {
      return http
          .get(encoded)
          .catchError((eror) => print("error getSongPlayUrlPage1"))
          .whenComplete(() => print('song search completed'))
          .then((http.Response response) {
        var document = parse(response.body);
        if (!document.outerHtml.contains("Ошибка 404 - страница не найдена")) {
          var elements = document.getElementsByClassName("playlist");
          if (elements.length > 0) {
            var html = elements[0].outerHtml;
            html = html.replaceAll('\n', '');
            html = html.replaceFirst('<ul class="playlist">', '');
            responseList = html.split("</li>");
            responseList.removeLast();
            String streamUrl = _buildStreamUrl(responseList, song);
            if (streamUrl != null) {
              return streamUrl;
            } else {
              return getSongPlayUrlPage2(searchStr, song);
            }
          } else {
            return null;
          }
        } else {
          return getSongPlayUrlPage2(searchStr, song);
        }
      });
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<String> getSongPlayUrlPage2(String searchStr, Song song) async {
    var responseList;
    var encoded = Uri.encodeFull(searchUrl + searchStr + "2");
    try {
      return http
          .get(
            encoded,
          )
          .catchError((eror) => print("error getSongPlayUrlPage2"))
          .whenComplete(() => print('song search completed'))
          .then((http.Response response) {
        var document = parse(response.body);
        if (!document.outerHtml.contains("Ошибка 404 - страница не найдена")) {
          var elements = document.getElementsByClassName("playlist");
          if (elements.length > 0) {
            var html = elements[0].outerHtml;
            html = html.replaceAll('\n', '');
            html = html.replaceFirst('<ul class="playlist">', '');
            responseList = html.split("</li>");
            responseList.removeLast();
            String streamUrl = _buildStreamUrl(responseList, song);
            if (streamUrl != null) {
              return streamUrl;
            } else {
              return null;
            }
          } else {
            return null;
          }
        } else {
          return null;
        }
      });
    } catch (e) {
      print(e);
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
      return http
          .get(encoded)
          .catchError((eror) => print("error getSongImageUrl"))
          .whenComplete(() => print('image search completed'))
          .then((http.Response response) {
        List<dynamic> list = jsonDecode(response.body)['data'];
        if (list.length > 0) {
          return _getImageUrlFromResponse(list[0]);
        } else {
          if (!secondTry) {
            return getSongImageUrl(song, true);
          } else {
            return '';
          }
        }
      });
    } catch (e) {
      print(e);
      return '';
    }
  }

  static Future<Artist> getArtistPageIdAndImageUrl(String artistName) async {
    String name = artistName;
    if (artistName.contains(" ")) {
      name = name.replaceAll(" ", "+");
    }
    try {
      return http
          .get(
            artistIdUrl + name,
          )
          .catchError((eror) => print("error getArtistPageIdAndImageUrl"))
          .whenComplete(() => print('Get Artist Info search completed'))
          .then((http.Response response) {
        List<dynamic> list = jsonDecode(response.body)['artists'];
        if (list.length > 0) {
          return Artist(
              artistName,
              "https://ichef.bbci.co.uk/images/ic/160x160/" +
                  list[0]["image_id"],
              id: list[0]["id"]);
        } else {
          return Artist(artistName,
              "https://ichef.bbci.co.uk/images/ic/160x160/p01bnb07.png",
              info: "");
        }
      });
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<Artist> getArtistInfoPage(Artist artist) async {
    return http
        .get(
          artistInfoSearchUrl + artist.getId,
        )
        .catchError((eror) => print("error getArtistInfoPage"))
        .whenComplete(() => print('Get Artist Info search completed'))
        .then((http.Response response) {
      Document document = parse(response.body);
      return _buildArtist(document, artist);
    });
  }

  static Future<String> getDownloadUrlPage1(Song song) async {
    String searchStr = song.getSearchString;
    searchStr = await _prepareStringToSearch(searchStr);
    searchStr = searchStr.replaceAll(" ", "-");
    try {
      return http
          .get(
            searchUrl + song.getSearchString + "/",
          )
          .catchError((eror) => print("error getDownloadUrlPage1"))
          .whenComplete(() => print('Search For Results 2 search completed'))
          .then((http.Response response) {
        var document = parse(response.body);
        if (!document.outerHtml.contains("Ошибка 404 - страница не найдена")) {
          var elements = document.getElementsByClassName("playlist");
          var html = elements[0].outerHtml;
          html = html.replaceAll('\n', '');
          html = html.replaceFirst('<ul class="playlist">', '');
          var a = html.split("</li>");
          a.removeLast();
          return _buildDownloadUrl(a, song);
        }
        return getDownloadUrlPage2(searchStr, song);
      });
    } catch (e) {
      return getDownloadUrlPage2(searchStr, song);
    }
  }

  static Future<String> getDownloadUrlPage2(String searchStr, Song song) async {
    try {
      return http
          .get(
            searchUrl + searchStr + "/2",
          )
          .catchError((eror) => print("error getDownloadUrlPage2"))
          .whenComplete(() => print('Search For Results 2 search completed'))
          .then((http.Response response) {
        var document = parse(response.body);
        if (!document.outerHtml.contains("Ошибка 404 - страница не найдена")) {
          var elements = document.getElementsByClassName("playlist");
          var html = elements[0].outerHtml;
          html = html.replaceAll('\n', '');
          html = html.replaceFirst('<ul class="playlist">', '');
          var a = html.split("</li>");
          a.removeLast();
          return _buildDownloadUrl(a, song);
        }
        return null;
      });
    } catch (e) {
      return null;
    }
  }

  static Future<String> getLyricsPageUrl(Song song) async {
    String searchStr = song.getSearchString;
    searchStr = await _prepareStringToSearch(searchStr);
    var encoded = Uri.encodeFull(lyricsSearchUrl + searchStr);
    var list;
    var sectionsMap;
    var sectionsList;
    var hitsList;
    var resultsList;
    try {
      return http
          .get(encoded)
          .catchError((eror) => print("error getLyricsPageUrl"))
          .whenComplete(() => print('song search completed'))
          .then((http.Response response) {
        list = jsonDecode(response.body)['response'];
        sectionsList = list['sections'];
        sectionsMap = sectionsList[1];
        hitsList = sectionsMap['hits'];
        if (hitsList != null) {
          resultsList = hitsList[0]['result'];
          return resultsList['url'];
        } else {
          return null;
        }
      });
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<String> getSongLyrics(String url) async {
    try {
      return http
          .get(url)
          .catchError((eror) => print("error getSongLyrics"))
          .whenComplete(() => print('song search completed'))
          .then((http.Response response) {
        Document document = parse(response.body);
        return _buildLyrics(document);
      });
    } catch (e) {
      print(e);
      return null;
    }
  }

  static String _buildDownloadUrl(List<String> list, Song song) {
    String songId;
    String strSong;
    String downloadUrl;
    if (list != null) {
      list.forEach((item) {
        songId = item.substring(
            item.lastIndexOf('data-id="') + 'data-id="'.length,
            item.lastIndexOf('" data-mp3='));
        if (songId == song.getSongId) {
          strSong = item;
        }
      });

      if (strSong != null) {
        downloadUrl = strSong.substring(
            strSong.indexOf('data-mp3="') + 'data-mp3="'.length,
            strSong.indexOf('" data-url_song='));
        downloadUrl = downloadUrl
            .replaceFirst("/public/play", "/public/download")
            .replaceAll("amp;", "");
        return downloadUrl;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static Artist _buildArtist(Document document, Artist artist) {
    String info;
    String imageUrl;
    List infoElement;
    List imageUrlElement;
    imageUrlElement = document.getElementsByClassName("artist-image");
    imageUrl = imageUrlElement[0].innerHtml;
    imageUrl = imageUrl.substring(
        imageUrl.indexOf('data-default-src="') + 'data-default-src="'.length,
        imageUrl.indexOf('"> <source srcset='));
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
    if (imageUrl ==
        "https://static.bbc.co.uk/music_clips/3.0.29/img/default_artist_images/pop1.jpg") {
      imageUrl = "https://ichef.bbci.co.uk/images/ic/160x160/p01bnb07.png";
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
            list[i].lastIndexOf('data-id="') + 'data-id="'.length,
            list[i].lastIndexOf('" data-mp3='));
        if (songId == song.getSongId) {
          strSong = list[i];
          break;
        }
      }

      if (strSong != null) {
        stream = playUrl +
            strSong
                .substring(strSong.indexOf('data-mp3="') + 'data-mp3="'.length,
                    strSong.indexOf('" data-url_song='))
                .replaceFirst("amp;", "");
      }
    }
    return stream;
  }

  static List<Song> _buildSearchResult(List<String> list, String searchString) {
    String imageUrl;
    String songTitle;
    String artist;
    String songId;
    String streamUrl;
    List<Song> songs = List();
    list.removeLast();
    list.forEach((item) {
      imageUrl = '';

      songTitle = item.substring(
          item.lastIndexOf('<em>') + '<em>'.length, item.lastIndexOf('</em>'));
      if (songTitle.contains('amp;')) {
        songTitle = songTitle.replaceAll('amp;', '');
      }

      artist = item.substring(
          item.lastIndexOf('<b>') + '<b>'.length, item.lastIndexOf('</b>'));
      if (artist.contains('amp;')) {
        artist = artist.replaceAll('amp;', '');
      }
      songId = item.substring(
          item.lastIndexOf('data-id="') + 'data-id="'.length,
          item.lastIndexOf('" data-mp3='));

      String tempTitle = songTitle;
      tempTitle = _editSearchParams(tempTitle, true, false);
      String tempArtist = artist;
      tempArtist = _editSearchParams(tempArtist, false, false);
      streamUrl = tempTitle + " " + tempArtist;
      if (!RegExp(r'^[א-ת\$!?&\()\[\] ]+$').hasMatch(streamUrl)) {
        songs.add(
            Song(songTitle, artist, songId, streamUrl + "/", imageUrl, ''));
      }
    });
    return songs;
  }

  static Future<String> _prepareStringToSearch(String searchStr) async {
    if (searchStr.contains("Ø")) {
      searchStr = searchStr.replaceAll("Ø", "o");
    }
    if (!RegExp(r'^[a-zA-Zא-תа-яА-Яё0-9\$!?&\()\[\]/,\-# ]+$')
        .hasMatch(searchStr)) {
      searchStr = await UnaccentString.unaccent(searchStr);
    }
    if (RegExp(r'^[a-zA-Zא-תа-яА-Яё0-9\$!?&\()\[\]/,\-#  ]+$')
        .hasMatch(searchStr)) {
      searchStr = searchStr.toLowerCase();
    }
    return searchStr;
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
}
