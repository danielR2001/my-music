class Song {
  String _songName;
  String _artist;
  String _songUrl;

  String get songName => _songName;
  String get artist => _artist;
  String get songUrl => _songUrl;
  Song(String songName, String artist) {
    _songName = songName;
    _artist = artist;
  }
}
