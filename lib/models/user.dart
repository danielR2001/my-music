import 'package:myapp/models/song.dart';
import 'playlist.dart';

class User {
  String _name;
  String _firebaseUid;
  List<Playlist> _myPlaylists;
  Playlist _downloadedSongsPlaylist;
  String _userPushId;

  User(String name, String firebaseUId, {String userPushId}) {
    _name = name;
    _firebaseUid = firebaseUId;
    _myPlaylists = List<Playlist>();
    _downloadedSongsPlaylist = Playlist("Downloaded");
    _userPushId = userPushId;
  }

  User.fromJson(Map values) {
    _name = values['userName'];
    _firebaseUid = values['firebaseUid'];
    _myPlaylists = List<Playlist>();
    _downloadedSongsPlaylist = Playlist("Downloaded");
  }

  toJson() {
    return {
      'userName': _name,
      'firebaseUid': _firebaseUid,
    };
  }

  String get name => _name;

  String get firebaseUid => _firebaseUid;

  List<Playlist> get playlists => _myPlaylists;

  Playlist get downloadedSongsPlaylist => _downloadedSongsPlaylist;

  String get userPushId => _userPushId;

  set setName(String value) => _name = value;

  set setFirebaseUId(String value) => _firebaseUid = value;

  set setMyPlaylists(List<Playlist> value) => _myPlaylists = value;

  set setDownloadedSongs(Playlist value) => _downloadedSongsPlaylist = value;

  set setUserPushId(String value) => _userPushId = value;

  addSongToDownloadedPlaylist(Song value) =>
      _downloadedSongsPlaylist.songs.add(value);

  removeSongFromDownloadedPlaylist(Song value) => _downloadedSongsPlaylist.songs
      .removeWhere((song) => song.songId == value.songId);

  addNewPlaylist(Playlist playlist) => _myPlaylists.add(playlist);

  removePlaylist(Playlist playlist) => _myPlaylists.remove(playlist);

  bool songExistsInDownloadedPlaylist(Song song) {
    bool exists = false;
    _downloadedSongsPlaylist.songs.forEach((downloadedSong) {
      if (downloadedSong.songId == song.songId) {
        exists = true;
      }
    });
    return exists;
  }

  void updatePlaylist(Playlist playlist) {
    _myPlaylists.forEach((myPlaylist) {
      if (myPlaylist.name == playlist.name) {
        myPlaylist = playlist;
      }
    });
  }
}
