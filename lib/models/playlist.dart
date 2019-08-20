import 'package:myapp/core/enums/sort_type.dart';

import 'song.dart';

class Playlist {
  String _name;
  List<Song> _songs;
  SortType _sortType;
  String _pushId;
  bool _isPublic;
  String _creator;
  String _publicPlaylistPushId;

  Playlist(String name, {bool isPublic, String creator}) {
    _name = name;
    _isPublic = isPublic;
    _creator = creator;
    _songs = List<Song>();
  }

  Playlist.fromPlaylist(Playlist playlist) {
    _name = playlist.name;
    _isPublic = playlist.isPublic;
    _creator = playlist.creator;
    _songs = playlist.songs;
    _publicPlaylistPushId = playlist._publicPlaylistPushId;
    _pushId = playlist.pushId;
    _sortType = playlist.sortType;
  }

  Playlist.fromJson(Map values) {
    _name = values['name'];
    _creator = values['creator'];
    _isPublic = values['isPublic'];
    _songs = List<Song>();
  }

  toJson() {
    return {
      'name': _name,
      'isPublic': _isPublic,
      'creator': _creator,
    };
  }

  String get name => _name;

  List<Song> get songs => _songs;

  String get pushId => _pushId;

  bool get isPublic => _isPublic;

  SortType get sortType => _sortType;

  String get creator => _creator;

  String get publicPlaylistPushId => _publicPlaylistPushId;

  set setName(String value) => _name = value;

  set setSongs(List<Song> value) => _songs = value;

  set setPushId(String value) => _pushId = value;

  set setIsPublic(bool value) => _isPublic = value;

  set setSortedType(SortType value) => _sortType = value;

  set setCreator(String value) => _creator = value;

  set setPublicPlaylistPushId(String value) => _publicPlaylistPushId = value;

  void addNewSong(Song song) => _songs.add(song);

  void removeSong(Song song) => _songs.remove(song);
}
