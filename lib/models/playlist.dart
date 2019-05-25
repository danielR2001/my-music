import 'song.dart';

class Playlist {
  String _name;
  List<Song> _songs;

  String get getName => _name;
  List<Song> get getSongs => _songs;

  set setName(String value) => _name = value;

  set setSongs(List<Song> value) => _songs = value;
  
  addNewSong(Song song) => _songs.add(song);

  Playlist(String name) {
    _name = name;
    _songs = new List<Song>();
  }
}
