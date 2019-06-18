import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/models/user.dart';

class FirebaseDatabaseManager {
  static final String _usersDir = "users";
  static final String _playlistsDir = "playlists";
  static final String _songsDir = "songs";
  static final String _downloadedDir = "downloaded";
  static String _userPushId;

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
    List<Map> downloaded = new List();
    User tempUser;
    int i = 0;
    var snapshot =
        await FirebaseDatabase.instance.reference().child(_usersDir).once();
    Map<dynamic, dynamic> values = snapshot.value;
    values.forEach(
      (key, values) {
        keys.add(key);
        playlists.add(values["playlists"]);
        downloaded.add(values["downloaded"]);
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
            if (downloaded[i] != null) {
              tempUser.setDownloadedSongs =
                  _buildDownloadedPlaylist(downloaded[i]);
            }
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

  static Playlist addPlaylist(Playlist playlist) {
    var pushId = FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .child(_playlistsDir)
        .push();
    playlist.setPushId = pushId.key;
    pushId.set(playlist.toJson());
    return playlist;
  }

  static void removePlaylist(Playlist playlist) {
    FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .child(_playlistsDir)
        .child(playlist.getPushId)
        .remove();
  }

  static void renamePlaylist(Playlist playlist, String newName) {
    FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .child(_playlistsDir)
        .child(playlist.getPushId)
        .update({"name": newName});
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
        playlists.add(tempPlaylist);
      },
    );
    return playlists;
  }

  static Playlist addDownloadedPlaylist(Playlist playlist) {
    var pushId = FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .child(_downloadedDir)
        .push();
    playlist.setPushId = pushId.key;
    pushId.set(playlist.toJson());
    return playlist;
  }

  static Song addSongToDownloadedPlaylist(Song song) {
    var pushId = FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .child(_downloadedDir)
        .child(currentUser.getDownloadedSongsPlaylist.getPushId)
        .child(_songsDir)
        .push();
    song.setPushId = pushId.key;
    pushId.set(song.toJson());
    return song;
  }

  static void removeSongFromDownloadedPlaylist(Song song) {
    FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .child(_downloadedDir)
        .child(currentUser.getDownloadedSongsPlaylist.getPushId)
        .child(_songsDir)
        .child(song.getPushId)
        .remove();
  }

  static Playlist _buildDownloadedPlaylist(Map playlistMap) {
    Playlist playlist;
    Map valuesMap;
    Map tempMap;
    var keys = playlistMap.keys;
    valuesMap = playlistMap[keys.first];
    tempMap = valuesMap["songs"];
    playlist = Playlist(valuesMap["name"]);
    playlist.setPushId = keys.first;
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

        playlist.addNewSong(temp);
      });
    }
    return playlist;
  }

  static Future<void> changeUserSignInState(bool signedIn) async {
    await FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .update({"signedIn": signedIn});
  }

  static Future<List<Playlist>> buildPublicPlaylists() async {
    List<User> users = List();
    List<Map> playlists = List();
    List<Playlist> publicPlaylists = List();
    User tempUser;
    int i = 0;
    var snapshot =
        await FirebaseDatabase.instance.reference().child(_usersDir).once();
    Map<dynamic, dynamic> values = snapshot.value;
    values.forEach(
      (key, values) {
        playlists.add(values["playlists"]);
        User user =
            User(values["userName"], values["firebaseUId"], values['signedIn']);
        users.add(user);
      },
    );

    users.forEach(
      (user) {
        tempUser = user;
        if (playlists[i] != null) {
          tempUser.setMyPlaylists = _buildPlaylists(playlists[i]);
        }

        i++;
      },
    );
    users.forEach((user) {
      user.getPlaylists.forEach((playlist) {
        if (playlist.getIsPublic) {
          publicPlaylists.add(playlist);
        }
      });
    });
    return publicPlaylists;
  }
}
