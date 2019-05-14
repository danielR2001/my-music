import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/album.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/song.dart';

class FetchData {
  static String songID = '138545995'; //ADELE HELLO
  static final String urlDownload =
      'https://free-mp3-download.net/dl.php?i=$songID&c=72272&f=mp3';
  static final String searchCallback =
      'https://free-mp3-download.net/search.php?s='; // + SEARCH STRING
  static final String playUrl = "https://playx.fun/stream/";
  static final String downloadUrl = "https://playx.fun/";
  static var map = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'J',
    'K',
    'M',
    'N',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'j',
    'k',
    'm',
    'n',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'x',
    'y',
    'z',
    '1',
    '2',
    '3'
  ];

  static Future<List<Song>> fetchPost(String searchStr) async {
    List<Song> postResponses;
    return http
        .get(
          searchCallback + searchStr,
        )
        .whenComplete(() => print('search completed'))
        .then((http.Response response) {
      List<dynamic> list = jsonDecode(response.body)['data'];
      if (list != null) {
        postResponses = fillList(list, searchStr);
      }
      return postResponses;
    });
  }

  static List<Song> fillList(List<dynamic> list, String searchStr) {
    List<Song> tempList = new List();
    Song temp;
    list.forEach((item) {
      temp = new Song(
        item['title'],
        constractArtist(item['artist']),
        item['id'].toString(),
        constractAlbum(item['album']),
        "",
      );
      tempList.add(temp);
    });
    return tempList;
  }

  static Artist constractArtist(Map artistMap) {
    Artist artist;
    artist = new Artist(
      artistMap['name'],
      artistMap['picture_big'],
    );
    return artist;
  }

  static Album constractAlbum(Map albumMap) {
    Album album;
    album = new Album(
      albumMap['title'],
      albumMap['cover_big'],
      albumMap['id'].toString(),
    );
    return album;
  }
}
