class Song {
  String _title;
  String _artist;
  String _songId;
  String _searchString;
  String _imageUrl;
  String _pushId;
  int _dateAdded;

  Song(String songName, String artist, String songId, String searchString,
      String imageUrl, String pushId, {int dateAdded}) {
    _title = songName;
    _artist = artist;
    _songId = songId;
    _searchString = searchString;
    _imageUrl = imageUrl;
    _pushId = pushId;
    _dateAdded = dateAdded;
  }
  Song.fromSong(Song song) {
    _title = song.getTitle;
    _artist = song.getArtist;
    _songId = song.getSongId;
    _searchString = song.getSearchString;
    _imageUrl = song.getImageUrl;
    _pushId = song.getPushId;
    _dateAdded = song.getDateAdded;
  }

  String get getTitle => _title;

  String get getArtist => _artist;

  String get getSongId => _songId;

  String get getSearchString => _searchString;

  String get getImageUrl => _imageUrl;

  String get getPushId => _pushId;


  int get getDateAdded => _dateAdded;

  set setTitle(String value) => _title = value;

  set setArtist(String value) => _artist = value;

  set setSongId(String value) => _songId = value;

  set setSearchString(String value) => _searchString = value;

  set setImageUrl(String value) => _imageUrl = value;

  set setPushId(String value) => _pushId = value;

  set setDateAdded(int value) => _dateAdded = value;

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
}
