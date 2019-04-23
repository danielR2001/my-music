import 'playlist.dart';

class User {
  String _name;
  String _imageUrl;
  String _firebaseUId;
  List<Playlist> _myPlaylists;

  User(
      String name,
      //String imageUrl,
      String firebaseUId) {
    _name = name;
    //_imageUrl = imageUrl;
    _firebaseUId = firebaseUId;
    _myPlaylists = new List();
  }

  String get getName => _name;
  String get getImageUrl => _imageUrl;
  List<Playlist> get getMyPlaylists => _myPlaylists;

  set setName(String value) => _name = value;
  set setImageUrl(String value) => _imageUrl = value;
  set addNewPlaylist(Playlist playList) => _myPlaylists.add(playList);
}
