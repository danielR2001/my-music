import 'Song.dart';

class Playlist {
  String name;
  List<Song> songs;

  Playlist(String name) {
    this.name = name;
    songs = new List<Song>();
  }
  String getName() {
    return name;
  }

  List<Song> getSongs() {
    return songs;
  }

  void addSong(Song song) {
    songs.add(song);
  }
}
