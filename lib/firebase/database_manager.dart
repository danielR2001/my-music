import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/models/user.dart';

class FirebaseDatabaseManager {
  static final String _usersDirectory = "users/";
  static String _userPushId;
  static String _userPlaylistId;

  static void saveUser() {
    FirebaseDatabase.instance.reference().child(_usersDirectory).push().set(
          currentUser.toJson(),
        );
  }

  static Future<void> syncUser(String currentUserId) async {
    List<User> users = new List();
    List<String> keys = new List();
    List<Map> playlists = new List();
    int i = 0;
    var db = FirebaseDatabase.instance.reference().child("users");
    db.once().then(
      (DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach(
          (key, values) {
            keys.add(key);
            playlists.add(values["playlists"]);
            User user = new User(values["userName"], values["firebaseUId"]);
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
                print(currentUser.getMyPlaylists[0].getSongs.toString());
              }
              print("user synced successfuly");
              return;
            }
            i++;
          },
        );
      },
    );
  }

  static void addNewPlaylist(Playlist playlist) {
    var dir = FirebaseDatabase.instance
        .reference()
        .child(_usersDirectory)
        .child(_userPushId)
        .child("playlists")
        .child(playlist.getName)
        .push();

    dir.set(playlist.getSongs[0].toJson());
  }

  static void addSongToPlaylist(Playlist playlist, Song song) {
    FirebaseDatabase.instance
        .reference()
        .child(_usersDirectory)
        .child(_userPushId)
        .child("playlists")
        .child(playlist.getName)
        .push()
        .set(song.toJson());
  }

  static List<Playlist> buildPlaylist(Map playlistMap) {
    List<Playlist> playlists = new List();
    Playlist temp;
    playlistMap.forEach(
      (key, value) {
        temp = new Playlist(key);
        value.forEach(
          (key, value) {
            List values = value.values.toList();
            temp.addNewSong(
              new Song(
                values[0],
                values[1],
                values[4],
                values[2],
                values[3],
              ),
            );
          },
        );
        playlists.add(temp);
      },
    );
    return playlists;
  }
}
