import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/widgets/sort_options_modal_buttom_sheet.dart';

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
      currentUser.toJson(),
    );
    _userPushId = pushId.key;
  }

  static Future<User> syncUser(
      String currentUserId, bool alreadySignedIn) async {
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

        User user =
            User(values["userName"], values["firebaseUId"], values['signedIn']);
        users.add(user);
      },
    );

    users.forEach(
      (user) {
        if (user.getFirebaseUId == currentUserId) {
          if (!user.getSignedIn || alreadySignedIn) {
            _userPushId = keys[i];
            tempUser = user;
            if (playlists[i] != null) {
              tempUser.setMyPlaylists = _buildPlaylists(playlists[i]);
            }
            print("user synced successfuly");
          } else {
            tempUser = User("", "", false);
          }
        }
        i++;
      },
    );
    return tempUser;
  }

  static String addPlaylist(Playlist playlist) {
    var pushId = FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .child(_playlistsDir)
        .push();
    playlist.setPushId = pushId.key;
    pushId.set(playlist.toJson());
    return pushId.key;
  }

  static void removePlaylist(Playlist playlist) {
    FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .child(_playlistsDir)
        .child(playlist.getPushId)
        .remove();
    if (playlist.getIsPublic) {
      removeFromPublicPlaylist(playlist, true);
    }
  }

  static void renamePlaylist(Playlist playlist, String newName) {
    FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .child(_playlistsDir)
        .child(playlist.getPushId)
        .update({"name": newName});
    if (playlist.getIsPublic) {
      FirebaseDatabase.instance
          .reference()
          .child(_publicPlaylistsDir)
          .child(playlist.getPublicPlaylistPushId)
          .update({"name": newName});
    }
  }

  static void changePlaylistPrivacy(Playlist playlist) {
    FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .child(_playlistsDir)
        .child(playlist.getPushId)
        .update({"isPublic": playlist.getIsPublic});
  }

  static Song addSongToPlaylist(Playlist playlist, Song song) {
    var pushId = FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .child(_playlistsDir)
        .child(playlist.getPushId)
        .child(_songsDir)
        .push();
    song.setPushId = pushId.key;
    pushId.set(song.toJson());

    if (playlist.getIsPublic) {
      song = _addSongToPublicPlaylist(playlist, song);
    }

    return song;
  }

  static void removeSongFromPlaylist(Playlist playlist, Song song) {
    FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .child(_playlistsDir)
        .child(playlist.getPushId)
        .child(_songsDir)
        .child(song.getPushId)
        .remove();
    if (playlist.getIsPublic) {
      _removeSongFromPublicPlaylist(playlist, song);
    }
  }

  static Future<void> changeUserSignInState(bool signedIn) async {
    await FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .update({"signedIn": signedIn});
  }

  static Future<void> buildPublicPlaylists() async {
    Playlist tempPlaylist;
    Map tempMap;
    var snapshot = await FirebaseDatabase.instance
        .reference()
        .child(_publicPlaylistsDir)
        .once();
    Map<dynamic, dynamic> values = snapshot.value;
    if (values != null) {
      values.forEach(
        (key, values) {
          if (key != "publicPlaylists") {
            tempMap = values["songs"];
            tempPlaylist = Playlist(values['name'],
                creator: values['creator'], isPublic: values['isPublic']);
            tempPlaylist.setPublicPlaylistPushId = key;
            if (tempMap != null) {
              tempMap.forEach((key, value) {
                Song temp = Song(
                  value['title'],
                  value['artist'],
                  value['songId'],
                  value['searchString'],
                  value['imageUrl'],
                  value['pushId'],
                  dateAdded: value['dateAdded'],
                );
                tempPlaylist.addNewSong(temp);
              });
            }
            publicPlaylists.add(tempPlaylist);
          }
        },
      );
      _listenToPublicPlaylistsChange();
    }
  }

  static Future<Playlist> addPublicPlaylist(
      Playlist playlist, bool creatingNewPlaylist) async {
    Playlist temp = Playlist(playlist.getName,
        creator: playlist.getCreator, isPublic: true);
    temp.setPushId = playlist.getPushId;

    temp.setSongs = List();
    var pushId =
        FirebaseDatabase.instance.reference().child(_publicPlaylistsDir).push();
    playlist.setPublicPlaylistPushId = pushId.key;
    temp.setPublicPlaylistPushId = pushId.key;
    FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .child(_playlistsDir)
        .child(playlist.getPushId)
        .update({"publicPlaylistPushId": pushId.key});
    await pushId.set(playlist.toJson());
    if (!creatingNewPlaylist) {
      playlist.getSongs.forEach((song) {
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
        .child(_publicPlaylistsDir)
        .child(playlist.getPublicPlaylistPushId)
        .remove();
    if (!completeDelete) {
      FirebaseDatabase.instance
          .reference()
          .child(_usersDir)
          .child(_userPushId)
          .child(_playlistsDir)
          .child(playlist.getPushId)
          .update({"publicPlaylistPushId": ""});
    }
  }

  static Song _addSongToPublicPlaylist(Playlist playlist, Song song) {
    var pushId = FirebaseDatabase.instance
        .reference()
        .child(_publicPlaylistsDir)
        .child(playlist.getPublicPlaylistPushId)
        .child(_songsDir)
        .push();
    song.setPushId = pushId.key;
    pushId.set(song.toJson());
    return song;
  }

  static void _removeSongFromPublicPlaylist(Playlist playlist, Song song) {
    Playlist publicPlaylist = publicPlaylists
        .where((temp) =>
            temp.getName == playlist.getName &&
            temp.getCreator == playlist.getCreator)
        .elementAt(0);
    Song publicPlaylistSong = publicPlaylist.getSongs
        .where((temp) => temp.getSongId == song.getSongId)
        .elementAt(0);
    FirebaseDatabase.instance
        .reference()
        .child(_publicPlaylistsDir)
        .child(playlist.getPublicPlaylistPushId)
        .child(_songsDir)
        .child(publicPlaylistSong.getPushId)
        .remove();
  }

  static Future<Playlist> _updatePublicPlaylist(String playlistPushId) async {
    Playlist playlist;
    Map tempMap;
    var snapshot = await FirebaseDatabase.instance
        .reference()
        .child(_publicPlaylistsDir)
        .child(playlistPushId)
        .once();
    Map<dynamic, dynamic> values = snapshot.value;
    playlist = Playlist(values["name"],
        isPublic: values["isPublic"], creator: values["creator"]);
    playlist.setPublicPlaylistPushId = snapshot.key;
    tempMap = values["songs"];
    if (tempMap != null) {
      tempMap.forEach((key, value) {
        playlist.addNewSong(Song(
          value['title'],
          value['artist'],
          value['songId'],
          value['searchString'],
          value['imageUrl'],
          value['pushId'],
          dateAdded: value['dateAdded'],
        ));
      });
    }
    return playlist;
  }

  static List<Playlist> _buildPlaylists(Map playlistMap) {
    List<Playlist> playlists = List();
    Playlist tempPlaylist;
    Map tempMap;
    playlistMap.forEach(
      (key, value) {
        tempMap = value["songs"];
        tempPlaylist = Playlist(value["name"],
            creator: value['creator'], isPublic: value["isPublic"]);
        tempPlaylist.setPushId = key;
        tempPlaylist.setPublicPlaylistPushId = value['publicPlaylistPushId'];
        if (tempMap != null) {
          tempMap.forEach((key, value) {
            tempPlaylist.addNewSong(Song(
              value['title'],
              value['artist'],
              value['songId'],
              value['searchString'],
              value['imageUrl'],
              value['pushId'],
              dateAdded: value['dateAdded'],
            ));
          });
        }
        List<Song> sortedPlaylist = List();
        List<int> datesList = List();
        for (int i = 0; i < tempPlaylist.getSongs.length; i++) {
          datesList.add(tempPlaylist.getSongs[i].getDateAdded);
        }
        datesList.sort();
        datesList.forEach((date) {
          for (int i = 0; i < tempPlaylist.getSongs.length; i++) {
            if (tempPlaylist.getSongs[i].getDateAdded == date) {
              sortedPlaylist.add(tempPlaylist.getSongs[i]);
              break;
            }
          }
        });
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
        publicPlaylists.removeWhere((temp) =>
            temp.getPublicPlaylistPushId == playlist.getPublicPlaylistPushId);
        publicPlaylists.add(playlist);
      });
    });
    onChildRemoved = FirebaseDatabase.instance
        .reference()
        .child(_publicPlaylistsDir)
        .onChildRemoved
        .listen((playlistMap) {
      publicPlaylists.removeWhere(
          (temp) => temp.getPublicPlaylistPushId == playlistMap.snapshot.key);
    });
    onChildAdded = FirebaseDatabase.instance
        .reference()
        .child(_publicPlaylistsDir)
        .onChildAdded
        .listen((playlistMap) {
      if (!_firstCallChildAdded &&
          playlistMap.snapshot.key != "publicPlaylists") {
        _updatePublicPlaylist(playlistMap.snapshot.key).then((playlist) {
          publicPlaylists.add(playlist);
        });
      } else {
        if (index == publicPlaylists.length - 1) {
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
