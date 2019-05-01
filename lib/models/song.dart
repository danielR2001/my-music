class Song {
  String _songName;
  String _artist;
  String _songUrl;
  String _imageUrl;
  String _songDownloadUrl;
  String _songId;
  String _pushId;

  Song(String songName, String artist, String songUrl, String imageUrl,
      String songDownloadUrl, String songId, String pushId) {
    _songName = songName;
    _artist = artist;
    _songUrl = songUrl;
    _imageUrl = imageUrl;
    _songDownloadUrl = songDownloadUrl;
    _songId = songId;
    _pushId = pushId;
  }
  Song.fromSong(Song song) {
    _songName = song.getSongName;
    _artist = song.getArtist;
    _songUrl = song.getSongUrl;
    _imageUrl = song.getImageUrl;
    _songDownloadUrl = song._songDownloadUrl;
    _songId = song.getSongId;
    _pushId = song.getPushId;
  }

  String get getPushId => _pushId;

  String get getSongId => _songId;

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

  set setSongId(String value) => _songId = value;

  set setPushId(String value) => _pushId = value;

  toJson() {
    return {
      'songName': _songName,
      'artist': _artist,
      'songUrl': _songUrl,
      'imageUrl': _imageUrl,
      'songDownloadUrl': _songDownloadUrl,
      'songId': _songId,
      'pushId': _pushId,
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
        _songDownloadUrl +
        " songId: " +
        _songId +
        " pushId" +
        _pushId;
  }
}
