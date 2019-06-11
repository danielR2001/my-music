import 'dart:convert';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/communicate_with_native/remove_accent_chars.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/song.dart';
import 'package:html/parser.dart' show parse;
import 'package:unorm_dart/unorm_dart.dart' as unorm;

class FetchData {
  static final String searchUrl1 = 'https://ru-music.com/search/';
  static final String searchUrl2 = 'https://muz.xn--41a.wiki/search/';
  static final String imageSearchUrl =
      'https://free-mp3-download.net/search.php?s=';
  static final String artistIdUrl =
      'https://www.bbc.co.uk/music/search.json?q=';
  static final String artistInfoUrl = "https://www.bbc.co.uk/music/artists/";

  static Future<List<Song>> searchForResultsSite1(String searchStr) async {
    searchStr = searchStr.replaceAll(" ", "-");
    var encoded = Uri.encodeFull(searchUrl1 + searchStr + "/");
    try {
      return http
          .get(
            encoded,
          )
          .whenComplete(() => print('Search For Results 1 search completed'))
          .then((http.Response response) async {
        var document = parse(response.body);
        if (!document.outerHtml.contains("Ошибка 404 - страница не найдена")) {
          var elements = document.getElementsByClassName("playlist");
          var html = elements[0].outerHtml;
          html = html.replaceAll('\n', '');
          html = html.replaceFirst('<ul class="playlist">', '');
          var a = html.split("</li>");
          return buildSearchResult1(a, searchUrl1 + searchStr + "/");
        } else {
          return await searchForResultsSite2(searchStr);
        }
      });
    } catch (e) {
      return await searchForResultsSite2(searchStr);
    }
  }

  static Future<List<Song>> searchForResultsSite2(String searchStr) async {
    var encoded = Uri.encodeFull(searchUrl1 + searchStr + "/");
    try {
      return http
          .get(
            encoded,
          )
          .whenComplete(() => print('Search For Results 2 search completed'))
          .then((http.Response response) {
        var document = parse(response.body);
        if (!document.outerHtml.contains("Ошибка 404 - страница не найдена")) {
          var elements = document.getElementsByClassName("playlist");
          var html = elements[0].outerHtml;
          html = html.replaceAll('\n', '');
          html = html.replaceFirst('<ul class="playlist">', '');
          var a = html.split("</li>");
          return buildSearchResult2(a, searchUrl2 + searchStr + "/");
        }
        return null;
      });
    } catch (e) {
      return null;
    }
  }

  static Future<String> getSongPlayUrlDefault(Song song) async {
    String title = song.getTitle;
    String artist = song.getArtist;
    title = await _editSearchParams(title, true, true);
    artist = await _editSearchParams(artist, false, true);
    String searchParams = title + "%-" + artist;
    var responseList;
    //var encoded = Uri.encodeFull(searchUrl1 + song.getSearchString);
    return http
        .get(searchUrl1 + searchParams)
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
          return _buildStreamUrl(responseList, song, true);
        } else {
          return null;
        }
      } else {
        return getSongPlayUrlSecondAttempt(song);
      }
    });
  }

  static Future<String> getSongPlayUrlSecondAttempt(Song song) async {
    var responseList;
    return http
        .get(
          searchUrl2 + song.getSearchString,
        )
        .whenComplete(() => print('song search completed'))
        .then((http.Response response) {
      var document = parse(response.body);
      var elements = document.getElementsByClassName("playlist");
      if (elements.length > 0) {
        var html = elements[0].outerHtml;
        html = html.replaceAll('\n', '');
        html = html.replaceFirst('<ul class="playlist">', '');
        responseList = html.split("</li>");
        responseList.removeLast();
      }
      return _buildStreamUrl(responseList, song, false);
    });
  }

  static Future<String> _editSearchParams(
      String str, bool isTitle, bool isSongUrlEdit) async {
    str = str.trimRight();
    if (!RegExp(r'^[a-zA-Zא-תа-я\$!?&\()\[\] ]+$').hasMatch(str)) {
      str = await UnaccentString.unaccent(str);
    }
    if (str.contains("feat")) {
      int pos = str.indexOf("feat");
      str = str.substring(0, pos);
    }
    if (str.contains(",")) {
      int pos = str.indexOf(",");
      str = str.substring(0, pos);
    }
    if (str.contains("'")) {
      int pos = str.indexOf("'");
      str = str.substring(0, pos);
    }
    if (!RegExp(r'^[a-zA-Z\$!?&\()\[\] ]+$').hasMatch(str)) {
      if (str.contains("(")) {
        str = str.substring(str.indexOf("(") + 1, str.indexOf(")"));
      } else {
        //remove english letters
      }
    } else {
      if (str.contains("(")) {
        str = str.substring(0, str.indexOf("("));
      }
    }
    if (str.contains("[")) {
      str = str.substring(0, str.indexOf("["));
    }
    if (isTitle && !isSongUrlEdit) {
      str = str.replaceAll("&", "%26");
    } else {
      if (str.contains("&")) {
        int pos = str.indexOf("&");
        str = str.substring(0, pos);
      }
    }
    if (!isSongUrlEdit) {
      str = str.replaceAll(" ", "%20");
    }

    return str;
  }

  static Future<String> getSongImageUrl(Song song) async {
    String title = song.getTitle;
    String artist = song.getArtist;
    title = await _editSearchParams(title, true, false);
    artist = await _editSearchParams(artist, false, false);
    String searchParams = title + "%20" + artist;
    return http
        .get(imageSearchUrl + searchParams)
        .whenComplete(() => print('image search completed'))
        .then((http.Response response) {
      List<dynamic> list = jsonDecode(response.body)['data'];
      if (list.length > 0) {
        return _getImageUrlFromResponse(list[0]);
      } else {
        return '';
      }
    });
  }

  static String _buildStreamUrl(List<String> list, Song song, bool isDefault) {
    String songId;
    String strSong;
    String stream;
    if (isDefault) {
      if (list != null) {
        list.forEach((item) {
          songId = item.substring(
              item.lastIndexOf('data-id="') + 'data-id="'.length,
              item.lastIndexOf('" data-img='));
          if (songId == song.getSongId) {
            strSong = item;
          }
        });

        if (strSong != null) {
          stream = 'https://ru-music.com' +
              strSong
                  .substring(
                      strSong.indexOf('data-mp3="') + 'data-mp3="'.length,
                      strSong.indexOf('" data-url_song='))
                  .replaceFirst("amp;", "");
        }
      }
    } else {
      list.forEach((item) {
        songId = item.substring(
            item.lastIndexOf('data-id="') + 'data-id="'.length,
            item.lastIndexOf('" data-mp3='));
        if (songId == song.getSongId) {
          strSong = item;
        }
      });

      if (strSong != null) {
        stream = 'https://muz.xn--41a.wiki' +
            strSong
                .substring(strSong.indexOf('data-mp3="') + 'data-mp3="'.length,
                    strSong.indexOf('" data-url_song='))
                .replaceFirst("amp;", "");
      }
    }
    return stream;
  }

  static List<Song> buildSearchResult1(List<String> list, String searchString) {
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
      songTitle = songTitle.substring(
          songTitle.indexOf(">") + 1, songTitle.lastIndexOf("<"));

      artist = item.substring(
          item.lastIndexOf('<b>') + '<b>'.length, item.lastIndexOf('</b>'));
      if (artist.contains('amp;')) {
        artist = artist.replaceAll('amp;', '');
      }
      if (artist.lastIndexOf("<") > artist.indexOf(">") + 1) {
        artist =
            artist.substring(artist.indexOf(">") + 1, artist.lastIndexOf("<"));

        songId = item.substring(
            item.lastIndexOf('data-id="') + 'data-id="'.length,
            item.lastIndexOf('" data-img='));

        streamUrl =
            songTitle.replaceAll(" ", "-") + "-" + artist.replaceAll(" ", "-");
        streamUrl = streamUrl.replaceAll(",", "");
        streamUrl = streamUrl.replaceAll("&", "-");
        if (streamUrl.allMatches(".*[a-z].*") == null) {
          streamUrl = searchString;
        }
        // else if(streamUrl.contains("â")
        // ||streamUrl.contains("ä")
        // ||streamUrl.contains("à")
        // ||streamUrl.contains("å")
        // ||streamUrl.contains("Á")
        // ||streamUrl.contains("Â")
        // ||streamUrl.contains("Ã")
        // ||streamUrl.contains("À")){
        //   //replace the special char with "a"
        //  }
        //TODO locate special chars
        songs.add(
            Song(songTitle, artist, songId, streamUrl + "/", imageUrl, ''));
      }
    });
    return songs;
  }

  static List<Song> buildSearchResult2(List<String> list, String searchString) {
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

      streamUrl =
          songTitle.replaceAll(" ", "-") + "-" + artist.replaceAll(" ", "-");
      streamUrl = streamUrl.replaceAll(",", "");
      streamUrl = streamUrl.replaceAll("&", "-");
      if (streamUrl.allMatches(".*[a-z].*") == null) {
        streamUrl = searchString;
      }
      // else if(streamUrl.contains("â")||streamUrl.contains("ä")||streamUrl.contains("à")||streamUrl.contains("å")||streamUrl.contains("Á")||streamUrl.contains("Â")||streamUrl.contains("Ã")||streamUrl.contains("À")||streamUrl.contains("")||streamUrl.contains("")||streamUrl.contains("")){
      //   streamUrl.
      // } TODO locate special chars
      songs.add(Song(songTitle, artist, songId, streamUrl + "/", imageUrl, ''));
    });
    return songs;
  }

  static String _getImageUrlFromResponse(Map songValues) {
    Map album = songValues['album'];
    return album['cover_big'];
  }

  static Future<Artist> getArtistPageIdAndImageUrl(String artistName) async {
    String name = artistName;
    if (artistName.contains(" ")) {
      name = name.replaceAll(" ", "+");
    }
    return http
        .get(
          artistIdUrl + name,
        )
        .whenComplete(() => print('Get Artist Info search completed'))
        .then((http.Response response) {
      List<dynamic> list = jsonDecode(response.body)['artists'];
      if (list.length > 0) {
        return Artist(artistName,
            "https://ichef.bbci.co.uk/images/ic/160x160/" + list[0]["image_id"],
            id: list[0]["id"]);
      } else {
        return Artist(artistName,
            "https://ichef.bbci.co.uk/images/ic/160x160/p01bnb07.png",
            info: "");
      }
    });
  }

  static Future<Artist> getArtistInfoPage(Artist artist) async {
    return http
        .get(
          artistInfoUrl + artist.getId,
        )
        .whenComplete(() => print('Get Artist Info search completed'))
        .then((http.Response response) {
      Document document = parse(response.body);
      return _buildArtist(document, artist);
    });
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

  static Future<String> getDownloadUrl(Song song) async {
    try {
      return http
          .get(
            searchUrl2 + song.getSearchString + "/",
          )
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
}
