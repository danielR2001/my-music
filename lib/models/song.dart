class Song {
  String _title;
  String _artist;
  String _songId;
  String _searchString;
  String _imageUrl;
  String _pushId;
  int _dateAdded;
  String _lyrics;

  Song(String title, String artist, String songId, String searchString,
      String imageUrl, String pushId,
      {int dateAdded}) {
    _title = title;
    _artist = artist;
    _songId = songId;
    _searchString = searchString;
    _imageUrl = imageUrl;
    _pushId = pushId;
    _dateAdded = dateAdded;
  }

  Song.fromSong(Song song) {
    _title = song.title;
    _artist = song.artist;
    _songId = song.songId;
    _searchString = song.searchString;
    _imageUrl = song.imageUrl;
    _pushId = song.pushId;
    _dateAdded = song.dateAdded;
  }

  Song.fromJson(Map values) {
    _title = values['title'];
    _artist = values['artist'];
    _songId = values['songId'];
    _searchString = values['searchString'];
    _imageUrl = values['imageUrl'];
    _pushId = values['pushId'];
    _dateAdded = values['dateAdded'];
  }

  toJson() {
    return {
      'title': _title,
      'artist': _artist,
      'songId': _songId,
      'searchString': _searchString,
      'imageUrl': _imageUrl,
      'pushId': _pushId,
      'dateAdded': _dateAdded,
    };
  }

  String get title => _title;

  String get artist => _artist;

  String get songId => _songId;

  String get searchString => _searchString;

  String get imageUrl => _imageUrl;

  String get pushId => _pushId;

  int get dateAdded => _dateAdded;

  String get lyrics => _lyrics;

  set setTitle(String value) => _title = value;

  set setArtist(String value) => _artist = value;

  set setSongId(String value) => _songId = value;

  set setSearchString(String value) => _searchString = value;

  set setImageUrl(String value) => _imageUrl = value;

  set setPushId(String value) => _pushId = value;

  set setDateAdded(int value) => _dateAdded = value;

  set setLyrics(String value) => _lyrics = value;
}
