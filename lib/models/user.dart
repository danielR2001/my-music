import 'package:myapp/models/song.dart';
import 'playlist.dart';

class User {
  String _name;
  String _firebaseUid;
  List<Playlist> _myPlaylists;
  Playlist _downloadedSongsPlaylist;
  List<Playlist> _publicPlaylists;
  String _userPushId;
  bool _isOfflineMode;

  User(String name, String firebaseUId, {String userPushId}) {
    _name = name;
    _firebaseUid = firebaseUId;
    _myPlaylists = List<Playlist>();
    _downloadedSongsPlaylist = Playlist("Downloaded");
    _publicPlaylists = List<Playlist>();
    _userPushId = userPushId;
    _isOfflineMode = false;
  }

  User.initial()
      : _firebaseUid = '',
        _name = '',
        _myPlaylists = List<Playlist>(),
        _downloadedSongsPlaylist = Playlist("Downloaded"),
        _userPushId = '',
        _publicPlaylists = List<Playlist>(),_isOfflineMode = false;

  User.fromJson(Map values) {
    _name = values['userName'];
    _firebaseUid = values['firebaseUid'];
    _myPlaylists = List<Playlist>();
    _isOfflineMode = false;
  }

  User.fromUser(User user) {
    _name = user.name;
    _firebaseUid = user.firebaseUid;
    _myPlaylists = user.playlists;
    _downloadedSongsPlaylist = user.downloadedSongsPlaylist != null? user.downloadedSongsPlaylist: Playlist("Downloaded");
    _publicPlaylists = user.publicPlaylists;
    _userPushId = user.userPushId;
    _isOfflineMode = user.isOfflineMode;
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

  List<Playlist> get publicPlaylists => _publicPlaylists;

  String get userPushId => _userPushId;

  bool get isOfflineMode => _isOfflineMode;

  set setName(String value) => _name = value;

  set setFirebaseUId(String value) => _firebaseUid = value;

  set setMyPlaylists(List<Playlist> value) => _myPlaylists = value;

  set setDownloadedSongs(List<Song> songs) => _downloadedSongsPlaylist.setSongs = songs;

  set setUserPushId(String value) => _userPushId = value;

  set setIsOfflineMode(bool value) => _isOfflineMode = value;

  set setPublicPlaylists(List<Playlist> value) => _publicPlaylists = value;

  addSongToDownloadedPlaylist(Song value) =>
      _downloadedSongsPlaylist.songs.add(value);

  removeSongFromDownloadedPlaylist(Song value) => _downloadedSongsPlaylist.songs
      .removeWhere((song) => song.songId == value.songId);

  addPlaylistToPublicPlaylists(Playlist value) => _publicPlaylists.add(value);

  removePlaylistFromPublicPlaylists(Playlist value) =>
      _publicPlaylists.removeWhere((playlist) =>
          playlist.publicPlaylistPushId == value.publicPlaylistPushId);

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

  bool playlistExistsInPublicPlaylist(Playlist value) {
    bool exists = false;
    _publicPlaylists.forEach((playlist) {
      if (playlist.publicPlaylistPushId == value.publicPlaylistPushId) {
        exists = true;
      }
    });
    return exists;
  }

  String getSongPublicPushId(Playlist playlist, Song song) {
    var temp = _publicPlaylists.where(
        (value) => value.publicPlaylistPushId == playlist.publicPlaylistPushId);
  }

  void updatePlaylist(Playlist playlist) {
    _myPlaylists.forEach((myPlaylist) {
      if (myPlaylist.name == playlist.name) {
        myPlaylist = playlist;
      }
    });
  }
}
