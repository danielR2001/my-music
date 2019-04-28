import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/song.dart';

class FetchData {
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
        .post('https://my-free-mp3s.com/api/search.php?callback',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {"q": searchStr})
        .whenComplete(() => print('search completed'))
        .then((http.Response response) {
          List<dynamic> list = jsonDecode(
              response.body.substring(1, response.body.length - 2))['response'];
          if (list != null) {
            list?.removeAt(0);
            postResponses = fillList(list, searchStr);
          }
          return postResponses;
        });
  }

  static List<Song> fillList(List<dynamic> list, String searchStr) {
    List<Song> tempList = new List();
    Song temp;
    String tempTitle;
    list.forEach((item) {
      searchStr = searchStr.toLowerCase();
      tempTitle = item['title'];
      tempTitle = tempTitle.toLowerCase();
      if (tempTitle.contains(searchStr)) {
        temp = new Song(
          item['title'],
          item['artist'],
          playUrl +
              encode(item['owner_id']) +
              ":" +
              encode(
                item['id'],
              ),
          getImageUrl(
            item['album'],
          ),
          downloadUrl +
              encode(item['owner_id']) +
              ":" +
              encode(
                item['id'],
              ),
          item['id'].toString(),
        );
        tempList.add(temp);
      }
    });
    return tempList;
  }

  static String encode(int input) {
    int length = map.length;
    var encoded = "";
    if (input == 0) return map[0];
    if (input < 0) {
      input *= -1;
      encoded += "-";
    }
    while (input > 0) {
      var val = input % length;
      input = input ~/ length;
      encoded += map[val];
    }
    return encoded;
  }

  static String getImageUrl(Map<String, dynamic> value) {
    if (value != null) {
      if (value.length > 4) {
        var temp;
        temp = value;
        temp = temp.values;
        temp = temp.toList();
        temp?.removeRange(0, 4);
        temp = temp[0].values.toList();
        temp = temp[5];
        return temp;
      } else {
        return "";
      }
    } else {
      return "";
    }
  }
}
