class Song {
  String _songName;
  String _artist;
  String _songUrl;

  Song(
    String songName,
    String artist,
    //String songUrl,
  ) {
    _songName = songName;
    _artist = artist;
    //_songUrl = songUrl;
  }

  String get songName => _songName;

  String get artist => _artist;

  String get songUrl => _songUrl;

  set songName(String value) => _songName = value;

  set artist(String value) => _artist = value;

  set songUrl(String value) => _songUrl = value;
}
