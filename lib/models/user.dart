import 'playlist.dart';

class User {
  String _name;
  String _imageUrl;
  String _firebaseUId;
  List<Playlist> _myPlaylists;

  User(String name, String firebaseUId) {
    _name = name;
    _firebaseUId = firebaseUId;
    _myPlaylists = List<Playlist>();
  }

  String get getName => _name;

  String get getFirebaseUId => _firebaseUId;

  String get getImageUrl => _imageUrl;

  List<Playlist> get getMyPlaylists => _myPlaylists;

  set setName(String value) => _name = value;

  set setImageUrl(String value) => _imageUrl = value;

  addNewPlaylist(Playlist playlist) => _myPlaylists.add(playlist);

  removePlaylist(Playlist playlist) => _myPlaylists.remove(playlist);

  set setFirebaseUId(String value) => _firebaseUId = value;

  set setMyPlaylists(List<Playlist> value) => _myPlaylists = value;

  toJson() {
    return {
      'userName': _name,
      'imageUrl': _imageUrl,
      'firebaseUId': _firebaseUId,
    };
  }

  @override
  String toString() {
    return _name + "," + _firebaseUId;
  }

  void updatePlaylist(Playlist playlist) {
    _myPlaylists.forEach((myPlaylist) {
      if (myPlaylist.getName == playlist.getName) {
        myPlaylist = playlist;
      }
    });
  }
}
