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
        return buildSearchResult(a, searchUrl + searchStr + "/");
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
      return buildSong(responseList, song);
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

  static String buildSong(List<String> list, Song song) {
    int startPos;
    int endPos;
    String songId;
    String strSong;
    String stream;
    list.forEach((item) {
      startPos = item.lastIndexOf('data-id="') + 'data-id="'.length;
      endPos = item.lastIndexOf('" data-img=');
      songId = item.substring(startPos, endPos);
      if (songId == song.getSongId) {
        strSong = item;
      }
    });
    if (strSong != null) {
      startPos = strSong.indexOf('data-mp3="') + 'data-mp3="'.length;
      endPos = strSong.indexOf('" data-url_song=');
      stream = 'https://ru-music.com' +
          strSong.substring(startPos, endPos).replaceFirst("amp;", "");
    }
    return stream;
  }

  static List<Song> buildSearchResult(List<String> list, String searchString) {
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
      artist =
          artist.substring(artist.indexOf(">") + 1, artist.lastIndexOf("<"));

      songId = item.substring(
          item.lastIndexOf('data-id="') + 'data-id="'.length,
          item.lastIndexOf('" data-img='));

      streamUrl =
          songTitle.replaceAll(" ", "-") + "-" + artist.replaceAll(" ", "-");
      streamUrl = streamUrl.replaceAll(",", "");
      streamUrl = streamUrl.replaceAll("&", "-");
      if(streamUrl.allMatches(".*[a-z].*")==null){
        streamUrl = searchString;
      }
      // else if(streamUrl.contains("â")||streamUrl.contains("ä")||streamUrl.contains("à")||streamUrl.contains("å")||streamUrl.contains("Á")||streamUrl.contains("Â")||streamUrl.contains("Ã")||streamUrl.contains("À")||streamUrl.contains("")||streamUrl.contains("")||streamUrl.contains("")){
      //   streamUrl.
      // } TODO locate special chars
      songs.add(Song(songTitle, artist, songId, searchUrl + streamUrl + "/",
          imageUrl, ''));
    });
    return songs;
  }

  static String getImageUrlFromResponse(Map songValues) {
    Map album = songValues['album'];
    return album['cover_big'];
  }
}
