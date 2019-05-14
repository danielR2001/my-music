import 'package:myapp/models/song.dart';

class Album {
  String _title;
  String _imageUrl;
  String _id;
  List<Song> songs;

  Album(String title, String imageUrl, String id) {
    _title = title;
    _imageUrl = imageUrl;
    _id = id;
  }

  String get getTitle => _title;

  String get getImageUrl => _imageUrl;

  String get getId => _id;

  set setTitle(String value) => _title = value;

  set setImageUrl(String value) => _imageUrl = value;

  set setId(String value) => _id = value;
}
