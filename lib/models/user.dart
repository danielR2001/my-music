import 'playlist.dart';

class User {
  String _name;
  String _imageUrl;
  List<Playlist> _myPlaylists;

  Artist(
    String name,
    //String imageUrl,
  ) {
    _name = name;
    //_imageUrl = imageUrl;
  }

  String get name => _name;
  String get imageUrl => _imageUrl;
  List<Playlist> get myPlaylists => _myPlaylists;

  set name(String value) => _name = value;
  set imageUrl(String value) => _imageUrl = value;
  set addNewPlaylist(Playlist playList) => _myPlaylists.add(playList);
}
