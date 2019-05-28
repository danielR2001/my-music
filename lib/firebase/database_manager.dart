import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/album.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/models/user.dart';

class FirebaseDatabaseManager {
  static final String _usersDir = "users";
  static final String _playlistsDir = "playlists";
  static String _userPushId;

  static void saveUser() {
    FirebaseDatabase.instance.reference().child(_usersDir).push().set(
          currentUser.toJson(),
        );
  }

  static Future<void> syncUser(String currentUserId) async {
    List<User> users = List();
    List<String> keys = List();
    List<Map> playlists = List();
    int i = 0;
    var snapshot =
        await FirebaseDatabase.instance.reference().child(_usersDir).once();
    Map<dynamic, dynamic> values = snapshot.value;
    values.forEach(
      (key, values) {
        keys.add(key);
        playlists.add(values["playlists"]);
        User user = User(values["userName"], values["firebaseUId"]);
        users.add(user);
      },
    );

    users.forEach(
      (user) {
        if (user.getFirebaseUId == currentUserId) {
          _userPushId = keys[i];
          currentUser = user;
          if (playlists[i] != null) {
            currentUser.setMyPlaylists = buildPlaylist(playlists[i]);
          }
          print("user synced successfuly");
          return;
        }
        i++;
      },
    );
  }

  static void addSongToPlaylist(Playlist playlist, Song song) {
    var pushId = FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .child(_playlistsDir)
        .child(playlist.getName)
        .push();
    Song temp = Song.fromSong(song);
    temp.setPushId = pushId.key;
    pushId.set(temp.toJson());
  }

  static void removeSongToPlaylist(Playlist playlist, Song song) {
    FirebaseDatabase.instance
        .reference()
        .child(_usersDir)
        .child(_userPushId)
        .child(_playlistsDir)
        .child(playlist.getName)
        .child(song.getPushId)
        .remove();
  }

  static List<Playlist> buildPlaylist(Map playlistMap) {
    List<Playlist> playlists = List();
    Playlist temp;
    playlistMap.forEach(
      (key, value) {
        temp = Playlist(key);
        value.forEach(
          (key, value) {
            List values = value.values.toList();
            temp.addNewSong(
              Song(
                values[4],
                values[2],
                values[5],
                values[1],
                values[3],
                values[0],
              ),
            );
          },
        );
        playlists.add(temp);
      },
    );
    return playlists;
  }

  // static Song buildSong(Map songMap) {
  //   List values = songMap.values.toList();
  //   return  Song(
  //     values[3],
  //     //buildArtist(values[1]),
  //     '',
  //     '',
  //     values[4],
  //     '',
  //    // buildAlbum(values[2]),
  //     values[0],
  //   );
  // }

  static Artist buildArtist(Map artistMap) {
    return Artist(artistMap['name'], artistMap['imageUrl']);
  }

  static Album buildAlbum(Map albumMap) {
    return Album(albumMap['title'], albumMap['imageUrl'], albumMap['id']);
  }
}
