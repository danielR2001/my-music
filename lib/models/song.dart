import 'package:myapp/models/album.dart';
import 'package:myapp/models/artist.dart';

class Song {
  String _title;
  Artist _artist;
  String _songId;
  Album _album;
  String _pushId;

  Song(String songName, Artist artist, String songId, Album album,
      String pushId) {
    _title = songName;
    _artist = artist;
    _songId = songId;
    _album = album;
    _pushId = pushId;
  }
  Song.fromSong(Song song) {
    _title = song.getTitle;
    _artist = song.getArtist;
    _songId = song.getSongId;
    _album = song.getAlbum;
    _pushId = song.getPushId;
  }

  String get getTitle => _title;

  Artist get getArtist => _artist;

  String get getSongId => _songId;

  Album get getAlbum => _album;

  String get getPushId => _pushId;

  set setTitle(String value) => _title = value;

  set setArtist(Artist value) => _artist = value;

  set setSongId(String value) => _songId = value;

  set setAlbum(Album value) => _album = value;

  set setPushId(String value) => _pushId = value;

  toJson() {
    return {
      'title': _title,
      'artist': _artist.toJson(),
      'songId': _songId,
      'album': _album.toJson(),
      'pushId': _pushId,
    };
  }

  @override
  String toString() {
    return " title: " +
        _title +
        " artist: " +
        _artist.getName +
        " songId: " +
        _songId +
        " pushId" +
        _pushId;
  }
}
