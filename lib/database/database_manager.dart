import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/custom_classes/custom_colors.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/widgets/sort_modal_buttom_sheet.dart';

class FirebaseDatabaseManager {
  static final String _usersDir = "users";
  static final String _playlistsDir = "playlists";
  static final String _songsDir = "songs";
  static final String _publicPlaylistsDir = "publicPlaylists";
  static String _userPushId;
  static bool _firstCallChildAdded = true;
  static StreamSubscription<Event> onChildChanged;
  static StreamSubscription<Event> onChildAdded;
  static StreamSubscription<Event> onChildRemoved;

  static void saveUser() {
    var pushId = FirebaseDatabase.instance.reference().child(_usersDir).push();
    pushId.set(
      GlobalVariables.currentUser.toJson(),
    );
    _userPushId = pushId.key;
  }

  static Future<User> syncUser(String currentUserId) async {
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

  static String addPlaylist(Playlist playlist) {
    var pushId = FirebaseDatabase.instance
        .reference()
        .child('$_usersDir/$_userPushId/$_playlistsDir')
        .push();
    playlist.setPushId = pushId.key;
    pushId.set(playlist.toJson());
    return pushId.key;
  }

  static void removePlaylist(Playlist playlist) {
    FirebaseDatabase.instance
        .reference()
        .child('$_usersDir/$_userPushId/$_playlistsDir/${playlist.pushId}')
        .remove();
    if (playlist.isPublic) {
      removeFromPublicPlaylist(playlist, true);
    }
  }

  static void renamePlaylist(Playlist playlist, String newName) {
    FirebaseDatabase.instance
        .reference()
        .child('$_usersDir/$_userPushId/$_playlistsDir/${playlist.pushId}')
        .update({"name": newName});
    if (playlist.isPublic) {
      FirebaseDatabase.instance
          .reference()
          .child(_publicPlaylistsDir)
          .child(playlist.publicPlaylistPushId)
          .update({"name": newName});
    }
  }

  static void changePlaylistPrivacy(Playlist playlist) {
    FirebaseDatabase.instance
        .reference()
        .child('$_usersDir/$_userPushId/$_playlistsDir/${playlist.pushId}')
        .update({"isPublic": playlist.isPublic});
  }

  static Song addSongToPlaylist(Playlist playlist, Song song) {
    var pushId = FirebaseDatabase.instance
        .reference()
        .child('$_usersDir/$_userPushId/$_playlistsDir/${playlist.pushId}/$_songsDir')
        .push();
    song.setPushId = pushId.key;
    pushId.set(song.toJson());

    if (playlist.isPublic) {
      song = _addSongToPublicPlaylist(playlist, song);
    }

    return song;
  }

  static void removeSongFromPlaylist(Playlist playlist, Song song) {
    FirebaseDatabase.instance
        .reference()
        .child('$_usersDir/$_userPushId/$_playlistsDir/${playlist.pushId}/$_songsDir/${song.pushId}')
        .remove();
    if (playlist.isPublic) {
      _removeSongFromPublicPlaylist(playlist, song);
    }
  }

  static Future<void> buildPublicPlaylists() async {
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
            List<Song> sortedPlaylist = List();

            sortedPlaylist = tempPlaylist.songs;
            sortedPlaylist.sort((a, b) => a.title.compareTo(b.title));
            
            tempPlaylist.setSongs = sortedPlaylist;
            tempPlaylist.setSortedType = SortType.title;
            GlobalVariables.publicPlaylists.add(tempPlaylist);
          }
        },
      );
      _listenToPublicPlaylistsChange();
    }
  }

  static Future<Playlist> addPublicPlaylist(
      Playlist playlist, bool creatingNewPlaylist) async {
    Playlist temp = Playlist(playlist.name,
        creator: playlist.creator, isPublic: true);
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

  static Future<void> removeFromPublicPlaylist(
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

  static Song _addSongToPublicPlaylist(Playlist playlist, Song song) {
    var pushId = FirebaseDatabase.instance
        .reference()
        .child('$_publicPlaylistsDir/${playlist.publicPlaylistPushId}/$_songsDir')
        .push();
    song.setPushId = pushId.key;
    pushId.set(song.toJson());
    return song;
  }

  static void _removeSongFromPublicPlaylist(Playlist playlist, Song song) {
    Playlist publicPlaylist = GlobalVariables.publicPlaylists
        .where((temp) =>
            temp.name == playlist.name &&
            temp.creator == playlist.creator)
        .elementAt(0);
    Song publicPlaylistSong = publicPlaylist.songs
        .where((temp) => temp.songId == song.songId)
        .elementAt(0);
    FirebaseDatabase.instance
        .reference()
        .child('$_publicPlaylistsDir/${playlist.publicPlaylistPushId}/$_songsDir/${publicPlaylistSong.pushId}')
        .remove();
  }

  static Future<Playlist> _updatePublicPlaylist(String playlistPushId) async {
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

  static List<Playlist> _buildPlaylists(Map playlistMap) {
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

  static void _listenToPublicPlaylistsChange() {
    int index = 0;
    onChildChanged = FirebaseDatabase.instance
        .reference()
        .child(_publicPlaylistsDir)
        .onChildChanged
        .listen((playlistMap) {
      _updatePublicPlaylist(playlistMap.snapshot.key).then((playlist) {
        GlobalVariables.publicPlaylists.removeWhere((temp) =>
            temp.publicPlaylistPushId == playlist.publicPlaylistPushId);
        GlobalVariables.publicPlaylists.add(playlist);
      });
    });
    onChildRemoved = FirebaseDatabase.instance
        .reference()
        .child(_publicPlaylistsDir)
        .onChildRemoved
        .listen((playlistMap) {
      GlobalVariables.publicPlaylists.removeWhere(
          (temp) => temp.publicPlaylistPushId == playlistMap.snapshot.key);
    });
    onChildAdded = FirebaseDatabase.instance
        .reference()
        .child(_publicPlaylistsDir)
        .onChildAdded
        .listen((playlistMap) {
      if (!_firstCallChildAdded &&
          playlistMap.snapshot.key != "publicPlaylists") {
        _updatePublicPlaylist(playlistMap.snapshot.key).then((playlist) {
          GlobalVariables.publicPlaylists.add(playlist);
        });
      } else {
        if (index == GlobalVariables.publicPlaylists.length - 1) {
          _firstCallChildAdded = false;
        } else {
          index++;
        }
      }
    });
  }

  static Future<void> cancelStreams() async {
    _firstCallChildAdded = true;
    await onChildAdded.cancel();
    await onChildChanged.cancel();
    await onChildRemoved.cancel();
  }
}
