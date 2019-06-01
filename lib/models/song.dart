class Song {
  String _title;
  String _artist;
  String _songId;
  int _searchPos;
  String _searchString;
  String _imageUrl;
  String _pushId;

  Song(String songName, 
      String artist, 
      String songId,
      int searchPos, 
      String searchString,
      String imageUrl,
      String pushId,
      ) {
    _title = songName;
    _artist = artist;
    _songId = songId;
    _searchPos = searchPos;
    _searchString = searchString;
    _imageUrl = imageUrl;
    _pushId = pushId;
  }
  Song.fromSong(Song song) {
    _title = song.getTitle;
    _artist = song.getArtist;
    _songId = song.getSongId;
    _searchPos = song.getSearchPos;
    _searchString = song.getSearchString;
    _imageUrl = song.getImageUrl;
    _pushId = song.getPushId;
  }

  String get getTitle => _title;

  String get getArtist => _artist;

  String get getSongId => _songId;

  int get getSearchPos => _searchPos;

  String get getSearchString => _searchString;

  String get getImageUrl => _imageUrl;

  String get getPushId => _pushId;



  set setTitle(String value) => _title = value;

  set setArtist(String value) => _artist = value;

  set setSongId(String value) => _songId = value;

  set setSearchPos(int value) => _searchPos = value;

  set setSearchString(String value) => _searchString = value;

  set setImageUrl(String value) => _imageUrl = value;

  set setPushId(String value) => _pushId = value;

  toJson() {
    return {
      'title': _title,
      'artist': _artist,
      'songId': _songId,
      'searchPos': _searchPos,
      'searchString': _searchString,
      'imageUrl': _imageUrl,
      'pushId': _pushId,
    };
  }
}
