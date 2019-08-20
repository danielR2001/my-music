import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/enums/sort_type.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/models/user.dart';

class FirebaseDatabaseManager {
  static final String _usersDir = "users";
  static final String _playlistsDir = "playlists";
  static final String _songsDir = "songs";
  static final String _publicPlaylistsDir = "publicPlaylists";
  static String _userPushId;

  Future<void> saveUser(User currentUser) async {
    var pushId = FirebaseDatabase.instance.reference().child(_usersDir).push();
    await pushId.set(
      currentUser.toJson(),
    );
    _userPushId = pushId.key;
  }

  Future<User> syncUser(String currentUserId) async {
    List<User> users = List();
    List<String> keys = List();
    List<Map> playlists = List();
    User tempUser;
    int i = 0;
    var snapshot =
        await FirebaseDatabase.instance.reference().child(_usersDir).once();
    Map<dynamic, dynamic> values = snapshot.value;
    values.forEach(
      (key, values) {
        keys.add(key);
        playlists.add(values["playlists"]);

        User user = User.fromJson(values);
        users.add(user);
      },
    );

    users.forEach(
      (user) {
        if (user.firebaseUid == currentUserId) {
          _userPushId = keys[i];
          tempUser = user;
          if (playlists[i] != null) {
            tempUser.setMyPlaylists = _buildPlaylists(playlists[i]);
          }
          print("user synced successfuly");
        }
        i++;
      },
    );
    return tempUser;
  }

  Future<String> addPlaylist(Playlist playlist) async {
    var pushId = FirebaseDatabase.instance
        .reference()
        .child('$_usersDir/$_userPushId/$_playlistsDir')
        .push();
    playlist.setPushId = pushId.key;
    await pushId.set(playlist.toJson());
    return pushId.key;
  }

  Future<void> removePlaylist(Playlist playlist) async {
    await FirebaseDatabase.instance
        .reference()
        .child('$_usersDir/$_userPushId/$_playlistsDir/${playlist.pushId}')
        .remove();
    if (playlist.isPublic) {
      await removeFromPublicPlaylist(playlist, true);
    }
  }

  Future<void> renamePlaylist(Playlist playlist, String newName) async {
    await FirebaseDatabase.instance
        .reference()
        .child('$_usersDir/$_userPushId/$_playlistsDir/${playlist.pushId}')
        .update({"name": newName});
    if (playlist.isPublic) {
      await FirebaseDatabase.instance
          .reference()
          .child(_publicPlaylistsDir)
          .child(playlist.publicPlaylistPushId)
          .update({"name": newName});
    }
  }

  Future<void> changePlaylistPrivacy(Playlist playlist) async {
    await FirebaseDatabase.instance
        .reference()
        .child('$_usersDir/$_userPushId/$_playlistsDir/${playlist.pushId}')
        .update({"isPublic": playlist.isPublic});
  }

  Future<Song> addSongToPlaylist(Playlist playlist, Song song) async {
    var pushId = FirebaseDatabase.instance
        .reference()
        .child(
            '$_usersDir/$_userPushId/$_playlistsDir/${playlist.pushId}/$_songsDir')
        .push();
    song.setPushId = pushId.key;
    await pushId.set(song.toJson());

    if (playlist.isPublic) {
      song = await _addSongToPublicPlaylist(playlist, song);
    }

    return song;
  }

  Future<void> removeSongFromPlaylist(Playlist playlist, Song song) async {
    await FirebaseDatabase.instance
        .reference()
        .child(
            '$_usersDir/$_userPushId/$_playlistsDir/${playlist.pushId}/$_songsDir/${song.pushId}')
        .remove();
    if (playlist.isPublic) {
      await _removeSongFromPublicPlaylist(playlist, song);
    }
  }

  Future<Playlist> buildPublicPlaylists() async {
    Playlist tempPlaylist;
    Map tempMap;
    var snapshot = await FirebaseDatabase.instance
        .reference()
        .child(_publicPlaylistsDir)
        .once();
    Map values = snapshot.value;
    if (values != null) {
      values.forEach(
        (key, values) {
          if (key != "publicPlaylists") {
            tempMap = values["songs"];
            tempPlaylist = Playlist.fromJson(values);
            tempPlaylist.setPublicPlaylistPushId = key;
            if (tempMap != null) {
              tempMap.forEach((key, value) {
                Song temp = Song.fromJson(value);
                tempPlaylist.addNewSong(temp);
              });
            }
            //List<Song> sortedPlaylist = List();

            //sortedPlaylist = tempPlaylist.songs;
            //sortedPlaylist.sort((a, b) => a.title.compareTo(b.title));
            // tempPlaylist.setSongs = sortedPlaylist;
            // tempPlaylist.setSortedType = SortType.title;
            // CustomColors.publicPlaylists.add(tempPlaylist);
          }
        },
      );
    }
    return tempPlaylist; // may return null
  }

  Future<Playlist> addPublicPlaylist(
      Playlist playlist, bool creatingNewPlaylist) async {
    Playlist temp =
        Playlist(playlist.name, creator: playlist.creator, isPublic: true);
    temp.setPushId = playlist.pushId;

    temp.setSongs = List();
    var pushId =
        FirebaseDatabase.instance.reference().child(_publicPlaylistsDir).push();
    playlist.setPublicPlaylistPushId = pushId.key;
    temp.setPublicPlaylistPushId = pushId.key;
    FirebaseDatabase.instance
        .reference()
        .child('$_usersDir/$_userPushId/$_playlistsDir/${playlist.pushId}')
        .update({"publicPlaylistPushId": pushId.key});
    await pushId.set(playlist.toJson());
    if (!creatingNewPlaylist) {
      playlist.songs.forEach((song) {
        _addSongToPublicPlaylist(playlist, song);
        temp.addNewSong(song);
      });
    }

    return temp;
  }

  Future<void> removeFromPublicPlaylist(
      Playlist playlist, bool completeDelete) async {
    FirebaseDatabase.instance
        .reference()
        .child('$_publicPlaylistsDir/${playlist.publicPlaylistPushId}')
        .remove();
    if (!completeDelete) {
      FirebaseDatabase.instance
          .reference()
          .child('$_usersDir/$_userPushId/$_playlistsDir/${playlist.pushId}')
          .update({"publicPlaylistPushId": ""});
    }
  }

  Future<Song> _addSongToPublicPlaylist(Playlist playlist, Song song) async {
    var pushId = FirebaseDatabase.instance
        .reference()
        .child(
            '$_publicPlaylistsDir/${playlist.publicPlaylistPushId}/$_songsDir')
        .push();
    song.setPushId = pushId.key;
    await pushId.set(song.toJson());
    return song;
  }

  Future<void> _removeSongFromPublicPlaylist(Playlist playlist, Song song) async {
    await FirebaseDatabase.instance.reference()
        .child(
            '$_publicPlaylistsDir/${playlist.publicPlaylistPushId}/$_songsDir/${song.pushId}')
        .remove();
  }

  Future<Playlist> _updatePublicPlaylist(String playlistPushId) async {
    Playlist playlist;
    Map tempMap;
    var snapshot = await FirebaseDatabase.instance
        .reference()
        .child('$_publicPlaylistsDir/$playlistPushId')
        .once();
    Map<dynamic, dynamic> values = snapshot.value;
    playlist = Playlist.fromJson(values);
    playlist.setPublicPlaylistPushId = snapshot.key;
    tempMap = values["songs"];
    if (tempMap != null) {
      tempMap.forEach((key, value) {
        playlist.addNewSong(Song.fromJson(value));
      });
    }
    List<Song> sortedPlaylist = List();

    sortedPlaylist = playlist.songs;
    sortedPlaylist.sort((a, b) => a.title.compareTo(b.title));

    playlist.setSongs = sortedPlaylist;
    playlist.setSortedType = SortType.title;
    return playlist;
  }

  List<Playlist> _buildPlaylists(Map playlistMap) {
    List<Playlist> playlists = List();
    Playlist tempPlaylist;
    Map tempMap;
    playlistMap.forEach(
      (key, value) {
        tempMap = value["songs"];
        tempPlaylist = Playlist.fromJson(value);
        tempPlaylist.setPushId = key;
        tempPlaylist.setPublicPlaylistPushId = value['publicPlaylistPushId'];
        if (tempMap != null) {
          tempMap.forEach((key, value) {
            tempPlaylist.addNewSong(Song.fromJson(value));
          });
        }
        List<Song> sortedPlaylist = List();

        sortedPlaylist = tempPlaylist.songs;
        sortedPlaylist.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));

        tempPlaylist.setSongs = sortedPlaylist;
        tempPlaylist.setSortedType = SortType.recentlyAdded;
        playlists.add(tempPlaylist);
      },
    );
    return playlists;
  }

  Stream<Event> onChildChanged() {
    return FirebaseDatabase.instance
        .reference()
        .child(_publicPlaylistsDir)
        .onChildChanged;
  }

  Stream<Event> onChildRemoved() {
    return FirebaseDatabase.instance
        .reference()
        .child(_publicPlaylistsDir)
        .onChildRemoved;
  }

    Stream<Event> onChildAdded() {
    return FirebaseDatabase.instance
        .reference()
        .child(_publicPlaylistsDir)
        .onChildAdded;
  }
}
