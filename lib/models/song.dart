class Song {
  String _title;
  String _artist;
  String _songId;
  String _streamUrl;
  String _imageUrl;
  String _pushId;

  Song(String songName, 
      String artist, 
      String songId,
      String streamUrl, 
      String imageUrl,
      String pushId,
      ) {
    _title = songName;
    _artist = artist;
    _songId = songId;
    _streamUrl = streamUrl;
    _imageUrl = imageUrl;
    _pushId = pushId;
  }
  Song.fromSong(Song song) {
    _title = song.getTitle;
    _artist = song.getArtist;
    _songId = song.getSongId;
    _streamUrl = song.getStreamUrl;
    _imageUrl = song.getImageUrl;
    _pushId = song.getPushId;
  }

  String get getTitle => _title;

  String get getArtist => _artist;

  String get getSongId => _songId;

  String get getStreamUrl => _streamUrl;

  String get getImageUrl => _imageUrl;

  String get getPushId => _pushId;



  set setTitle(String value) => _title = value;

  set setArtist(String value) => _artist = value;

  set setSongId(String value) => _songId = value;

  set setStreamUrl(String value) => _streamUrl = value;

  set setImageUrl(String value) => _imageUrl = value;

  set setPushId(String value) => _pushId = value;

  toJson() {
    return {
      'title': _title,
      'artist': _artist,
      'songId': _songId,
      'streamUrl': _streamUrl,
      'imageUrl': _imageUrl,
      'pushId': _pushId,
    };
  }
}
