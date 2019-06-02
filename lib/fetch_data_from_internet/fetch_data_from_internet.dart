import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myapp/models/song.dart';
import 'package:html/parser.dart' show parse;

class FetchData {
  static final String searchUrl = 'https://ru-music.com/search/';
  static final String imageSearchUrl =
      'https://free-mp3-download.net/search.php?s=';

  static Future<List<Song>> searchForResults(String searchStr) async {
    return http
        .get(
          searchUrl + searchStr + "/",
        )
        .whenComplete(() => print('search completed'))
        .then((http.Response response) {
      var document = parse(response.body);
      var elements = document.getElementsByClassName("playlist");
      if (elements.length > 0) {
        var html = elements[0].outerHtml;
        html = html.replaceAll('\n', '');
        html = html.replaceFirst('<ul class="playlist">', '');
        var a = html.split("</li>");
        return buildSearchResult(a, searchUrl);
      }
      return null;
    });
  }

  static Future<String> getSongPlayUrl(Song song) async {
    var responseList;
    return http
        .get(
          song.getSearchString,
        )
        .whenComplete(() => print('search completed'))
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
      return buildSong(responseList,song);
    });
  }

  static String editSearchParams(String str, bool isTitle) {
    str = str.replaceAll(" ", "%20");
    str = str.replaceAll("&", "%26");
    if (str.contains("feat")) {
      int pos = str.indexOf("feat");
      str = str.substring(0, pos);
    }
    if (str.contains(",") && isTitle) {
      int pos = str.indexOf(",");
      str = str.substring(0, pos);
    }
    if (str.contains("'")) {
      int pos = str.indexOf("'");
      str = str.substring(0, pos);
    }

    return str;
  }

  static Future<String> getSongImageUrl(Song song) async {
    String title = song.getTitle;
    String artist = song.getArtist;
    title = editSearchParams(title, false);
    artist = editSearchParams(artist, true);
    String searchParams = title + "%20" + artist;
    return http
        .get(imageSearchUrl + searchParams)
        .whenComplete(() => print('image search completed'))
        .then((http.Response response) {
      List<dynamic> list = jsonDecode(response.body)['data'];
      if (list.length > 0) {
        return getImageUrlFromResponse(list[0]);
      } else {
        return '';
      }
    });
  }

  static String buildSong(List<String> list,Song song) {
    int startPos;
    int endPos;
    String songId;
    String strSong;
    String stream;
    list.forEach((item){
      startPos = item.lastIndexOf('data-id="') + 'data-id="'.length;
      endPos = item.lastIndexOf('" data-img=');
      songId = item.substring(startPos, endPos);
      if(songId == song.getSongId){
        strSong = item;
      }
    });
    if(strSong!=null){
    startPos = strSong.indexOf('data-mp3="') + 'data-mp3="'.length;
    endPos = strSong.indexOf('" data-url_song=');
    stream = 'https://ru-music.com' +
        strSong.substring(startPos, endPos).replaceFirst("amp;", "");
    }
    return stream;
  }

  static List<Song> buildSearchResult(List<String> list, String searchString) {
    int startPos;
    int endPos;
    String imageUrl;
    String songTitle;
    String artist;
    String songId;
    String streamUrl;
    List<Song> songs = List();
    list.removeLast();
    list.forEach((item) {
      imageUrl = '';

      startPos = item.lastIndexOf('<em>') + '<em>'.length;
      endPos = item.lastIndexOf('</em>');
      songTitle = item.substring(startPos, endPos);
      if (songTitle.contains('amp;')) {
        songTitle = songTitle.replaceAll('amp;', '');
      }

      startPos = item.lastIndexOf('<b>') + '<b>'.length;
      endPos = item.lastIndexOf('</b>');
      artist = item.substring(startPos, endPos);
      if (artist.contains('amp;')) {
        artist = artist.replaceAll('amp;', '');
      }

      startPos = item.lastIndexOf('data-id="') + 'data-id="'.length;
      endPos = item.lastIndexOf('" data-img=');
      songId = item.substring(startPos, endPos);

      streamUrl =
          songTitle.replaceAll(" ", "-") + "-" + artist.replaceAll(" ", "-");
          streamUrl = streamUrl.replaceAll(",", "");
          streamUrl = streamUrl.replaceAll("&", "-");
      songs.add(Song(songTitle, artist, songId,
          searchString + streamUrl + "/", imageUrl, ''));
    });
    return songs;
  }

  static String getImageUrlFromResponse(Map songValues) {
    Map album = songValues['album'];
    return album['cover_big'];
  }
}
