import 'song.dart';

class Playlist {
  String _name;
  List<Song> _songs;
  String _pushId;
  bool _isPublic;

  String get getName => _name;

  List<Song> get getSongs => _songs;

  String get getPushId => _pushId;

  bool get getIsPublic => _isPublic;

  set setName(String value) => _name = value;

  set setSongs(List<Song> value) => _songs = value;

  set setPushId(String value) => _pushId = value;

  set setIsPublic(bool value) => _isPublic = value;

  addNewSong(Song song) => _songs.add(song);

  removeSong(Song song) => _songs.remove(song);

  Playlist(String name,{bool isPublic}) {
    _name = name;
    _isPublic = isPublic;
    _songs = List<Song>();
  }

  toJson() {
    return {
      'name': _name,
      'isPublic': _isPublic,
    };
  }
}
