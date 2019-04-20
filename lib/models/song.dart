class Song {
  String _songName;
  //Artist _artist
  String _artist;
  String _songUrl;
  String _imageUrl;

  Song(String songName, String artist, String urlEnding, String imageUrl) {
    _songName = songName;
    _artist = artist;
    _songUrl = urlEnding;
    _imageUrl = imageUrl;
  }

  String get imageUrl => _imageUrl;

  String get songUrl => _songUrl;

  String get songName => _songName;

  String get artist => _artist;

  set songName(String value) => _songName = value;

  set artist(String value) => _artist = value;

  set songUrl(String value) => _songUrl = value;

  set imageUrl(String value) => _imageUrl = value;

  @override
  String toString() {
    return "songUrl: " +
        _songUrl +
        " artist: " +
        _artist +
        " title: " +
        _songName +
        " imageUrl: " +
        _imageUrl;
  }
}
