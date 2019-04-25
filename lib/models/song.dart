class Song {
  String _songName;
  String _artist;
  String _songUrl;
  String _imageUrl;
  String _songDownloadUrl;

  Song(String songName, String artist, String songUrl, String imageUrl,
      String songDownloadUrl) {
    _songName = songName;
    _artist = artist;
    _songUrl = songUrl;
    _imageUrl = imageUrl;
    _songDownloadUrl = songDownloadUrl;
  }

  String get getSongDownloadUrl => _songDownloadUrl;

  String get getImageUrl => _imageUrl;

  String get getSongUrl => _songUrl;

  String get getSongName => _songName;

  String get getArtist => _artist;

  set serSongDownloadUrl(String value) => _songDownloadUrl = value;

  set setSongName(String value) => _songName = value;

  set setArtist(String value) => _artist = value;

  set setSongUrl(String value) => _songUrl = value;

  set setISmageUrl(String value) => _imageUrl = value;

  toJson() {
    return {
      'songName': _songName,
      'artist': _artist,
      'songUrl': _songUrl,
      'imageUrl': _imageUrl,
      'songDownloadUrl': _songDownloadUrl
    };
  }

  @override
  String toString() {
    return " title: " +
        _songName +
        " artist: " +
        _artist +
        " imageUrl: " +
        _imageUrl +
        " songUrl: " +
        _songUrl +
        " songDownloadUrl: " +
        _songDownloadUrl;
  }
}
