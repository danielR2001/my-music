import 'Song.dart';

class Playlist {
  String _name;
  List<Song> _songs;

  String get name => _name;
  List<Song> get songs => _songs;

  set name(String value) => _name = value;
  set addNewSong(Song song) => _songs.add(song);

  Playlist(String name) {
    this.name = name;
    _songs = new List<Song>();
  }
}
