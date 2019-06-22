import 'package:myapp/models/song.dart';
import 'playlist.dart';

class User {
  String _name;
  String _firebaseUId;
  List<Playlist> _myPlaylists;
  Playlist _downloadedSongsPlaylist;
  bool _signedIn;
  String _userPushId;

  User(String name, String firebaseUId,bool signedIn,{String userPushId}) {
    _name = name;
    _firebaseUId = firebaseUId;
    _myPlaylists = List<Playlist>();
    _downloadedSongsPlaylist = Playlist("Downloaded");
    _signedIn = signedIn;
    _userPushId = userPushId;
  }
  
  String get getName => _name;

  String get getFirebaseUId => _firebaseUId;

  List<Playlist> get getPlaylists => _myPlaylists;

  Playlist get getDownloadedSongsPlaylist => _downloadedSongsPlaylist;

  bool get getSignedIn => _signedIn;

  String get getUserPushId => _userPushId;

  set setName(String value) => _name = value;

  addNewPlaylist(Playlist playlist) => _myPlaylists.add(playlist);

  removePlaylist(Playlist playlist) => _myPlaylists.remove(playlist);

  set setFirebaseUId(String value) => _firebaseUId = value;

  set setMyPlaylists(List<Playlist> value) => _myPlaylists = value;

  set setDownloadedSongs(Playlist value) => _downloadedSongsPlaylist = value;

  set setSignedIn(bool value) => _signedIn = value;

  set setUserPushId(String value) => _userPushId = value;

  addSongToDownloadedPlaylist(Song value) =>
      _downloadedSongsPlaylist.getSongs.add(value);

  removeSongToDownloadedPlaylist(Song value) =>
      _downloadedSongsPlaylist.getSongs.remove(value);

  bool songExistsInDownloadedPlaylist(Song song) {
    bool exists = false;
    _downloadedSongsPlaylist.getSongs.forEach((downloadedSong) {
      if (downloadedSong.getSongId == song.getSongId) {
        exists = true;
      }
    });
    return exists;
  }

  toJson() {
    return {
      'userName': _name,
      'firebaseUId': _firebaseUId,
      'signedIn': _signedIn,
    };
  }

  @override
  String toString() {
    return _name + "," + _firebaseUId;
  }

  void updatePlaylist(Playlist playlist) {
    _myPlaylists.forEach((myPlaylist) {
      if (myPlaylist.getName == playlist.getName) {
        myPlaylist = playlist;
      }
    });
  }
}
