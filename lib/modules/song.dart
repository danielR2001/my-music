class Song {
  String _songName;
  //Artist _artist
  String _artist;
  String _songUrl;

  Song(
    String songName,
    String artist,
    String songUrl,
    //Artist artist
  ) {
    _songName = songName;
    _artist = artist;
    _songUrl = songUrl;
    //_artist = artist;
  }

  String get songName => _songName;

  String get artist => _artist;

  String get songUrl => _songUrl;

  //Artist get artist => _artist;

  set songName(String value) => _songName = value;

  set artist(String value) => _artist = value;

  set songUrl(String value) => _songUrl = value;

  //set artist(String value) => _artist = value;
}
