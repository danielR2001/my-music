import 'package:myapp/ui/widgets/sort_options_modal_buttom_sheet.dart';

import 'song.dart';

class Playlist {
  String _name;
  List<Song> _songs;
  List<Song> _sortedSongs;
  SortType _sortedType;
  String _pushId;
  bool _isPublic;
  String _creator;
  String _publicPlaylistPushId;

  String get getName => _name;

  List<Song> get getSongs => _songs;

  String get getPushId => _pushId;

  bool get getIsPublic => _isPublic;

  SortType get getSortedType => _sortedType;

  List<Song> get getSortedSongs => _sortedSongs;
  
  String get getCreator => _creator;

  String get getPublicPlaylistPushId => _publicPlaylistPushId;

  set setName(String value) => _name = value;

  set setSongs(List<Song> value) => _songs = value;

  set setPushId(String value) => _pushId = value;

  set setIsPublic(bool value) => _isPublic = value;

  set setSortedType(SortType value) => _sortedType = value;

  set setSortedSongs(List<Song> value) => _sortedSongs = value;

  set setCreator(String value) => _creator = value;

  set setPublicPlaylistPushId(String value) => _publicPlaylistPushId = value;

  addNewSong(Song song) => _songs.add(song);

  removeSong(Song song) => _songs.remove(song);

  Playlist(String name,{bool isPublic,String creator}) {
    _name = name;
    _isPublic = isPublic;
    _songs = List<Song>();
    _creator = creator;
  }

  toJson() {
    return {
      'name': _name,
      'isPublic': _isPublic,
      'creator' : _creator,
    };
  }
}
