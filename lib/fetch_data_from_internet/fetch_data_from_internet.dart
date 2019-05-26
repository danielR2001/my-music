import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/album.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/song.dart';
import 'package:html/parser.dart' show parse;

class FetchData {
  static String songID = '138545995'; //ADELE HELLO
  static final String urlDownload =
      'https://free-mp3-download.net/dl.php?i=$songID&c=72272&f=mp3';
  static final String searchCallback =
      'https://free-mp3-download.net/search.php?s='; // + SEARCH STRING

  static final String urlSearch = 'https://ru-music.com/search/';

  static Future<List<Song>> fetchPost(String searchStr) async {
    List<Song> postResponses;
    return http
        .get(
          urlSearch + searchStr+"/",
        )
        .whenComplete(() => print('search completed'))
        .then((http.Response response) {
          var document = parse(response.body);
          var elements = document.getElementsByClassName("playlist");
          //var element1 = elements[0].
          if(elements.length>0){
          var html = elements[0].outerHtml;
          html = html.replaceAll('\n', '');
          var a = html.split("</li>");
          postResponses = buildSearchResult(a);
          }
      return postResponses;
    });
  }

  static List<Song> buildSearchResult(List<String> list){
    int startPos;
    int endPos;
    String imageUrl;
    String stream;
    String songTitle;
    String artist;
    String songId;
    List<Song> songs = new List();
    list.removeLast();
    list.forEach((item){
      startPos = item.indexOf('data-img="')+ 'data-img="'.length;
      endPos = item.indexOf('" data-audio_hash');
      imageUrl =  item.substring(startPos,endPos);
      if(imageUrl =='https://vk.com/images/audio_row_placeholder.png'){
        imageUrl = '';
      }

      startPos = item.indexOf('data-mp3="')+ 'data-img="'.length;
      endPos = item.indexOf('" data-url_song');
      stream =  'https://ru-music.com'+item.substring(startPos,endPos).replaceFirst("amp;", "");

      startPos = item.lastIndexOf('<em>')+ '<em>'.length;
      endPos = item.lastIndexOf('</em>');
      songTitle =  item.substring(startPos,endPos);
      if(songTitle.contains('amp;')){
        songTitle = songTitle.replaceAll('amp;', '');
      }

      startPos = item.lastIndexOf('<b>')+ '<b>'.length;
      endPos = item.lastIndexOf('</b>');
      artist =  item.substring(startPos,endPos);
      if(artist.contains('amp;')){
        artist = artist.replaceAll('amp;', '');
      }

      startPos = item.lastIndexOf('data-id="')+ 'data-id="'.length;
      endPos = item.lastIndexOf('" data-img=');
      songId =  item.substring(startPos,endPos);

      songs.add(new Song(songTitle,artist,songId,stream,imageUrl,''));
    });
    return songs;
  }

  static Future<String> getRealSongUrl(Song song)async{
    return http
        .get(song.getStreamUrl).then((http.Response response){
          return response.headers['location'];
        });
  }
}
