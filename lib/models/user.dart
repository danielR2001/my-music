import 'package:myapp/models/song.dart';

import 'playlist.dart';

class User {
  String _name;
  String _imageUrl;
  String _firebaseUId;
  List<Playlist> _myPlaylists;

  User(
      String name,
      //String imageUrl,
      String firebaseUId) {
    _name = name;
    //_imageUrl = imageUrl;
    _firebaseUId = firebaseUId;
    _myPlaylists = List<Playlist>();
  }

  String get getName => _name;
  String get getFirebaseUId => _firebaseUId;
  String get getImageUrl => _imageUrl;
  List<Playlist> get getMyPlaylists => _myPlaylists;

  set setName(String value) => _name = value;
  set setImageUrl(String value) => _imageUrl = value;
  addNewPlaylist(Playlist playlist) => _myPlaylists.add(playlist);
  addNewSongToPlaylist(Playlist playlist, Song song) {
    _myPlaylists.forEach((userPlaylist) {
      if (playlist.getName == userPlaylist.getName) {
        userPlaylist.addNewSong(song);
        return;
      }
    });
  }

  void removeSongFromPlaylist(Playlist playlist, Song song) {
    bool removePlaylist = false;
    Playlist temp;
    _myPlaylists.forEach(
      (mPlaylist) {
        if (mPlaylist.getName == playlist.getName) {
          if (playlist.getSongs.length > 1) {
            mPlaylist.getSongs.remove(song);
          } else {
            removePlaylist = true;
            temp = mPlaylist;
            //_myPlaylists.remove(mPlaylist);
          }
        }
      },
    );
    if (removePlaylist) {
      _myPlaylists.remove(temp);
    }
  }

  set setFirebaseUId(String value) => _firebaseUId = value;
  set setMyPlaylists(List<Playlist> value) => _myPlaylists = value;

  toJson() {
    return {
      'userName': _name,
      'imageUrl': _imageUrl,
      'firebaseUId': _firebaseUId,
    };
  }

  @override
  String toString() {
    return _name + "," + _firebaseUId;
  }
}
