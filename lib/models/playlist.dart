import 'package:myapp/ui/widgets/sort_modal_buttom_sheet.dart';

import 'song.dart';

class Playlist {
  String _name;
  List<Song> _songs;
  SortType _sortedType;
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

  SortType get sortType => _sortedType;

  String get creator => _creator;

  String get publicPlaylistPushId => _publicPlaylistPushId;

  set setName(String value) => _name = value;

  set setSongs(List<Song> value) => _songs = value;

  set setPushId(String value) => _pushId = value;

  set setIsPublic(bool value) => _isPublic = value;

  set setSortedType(SortType value) => _sortedType = value;

  set setCreator(String value) => _creator = value;

  set setPublicPlaylistPushId(String value) => _publicPlaylistPushId = value;

  addNewSong(Song song) => _songs.add(song);

  removeSong(Song song) => _songs.remove(song);
}
