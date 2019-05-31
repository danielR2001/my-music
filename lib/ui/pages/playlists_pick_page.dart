import 'package:flutter/material.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/models/playlist.dart';

class PlaylistPickPage extends StatefulWidget {
  final Song song;
  PlaylistPickPage(this.song);
  @override
  _PlaylistPickPageState createState() => _PlaylistPickPageState(song);
}

class _PlaylistPickPageState extends State<PlaylistPickPage> {
  final Song song;
  _PlaylistPickPageState(this.song);
  String _playlistName;

  final formKey = GlobalKey<FormState>();

  final scafKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        key: scafKey,
        backgroundColor: Color(0xAA000000),
        body: SafeArea(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  child: Container(
                    alignment: Alignment.center,
                    height: 55,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text(
                      "New Playlist",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onTap: () {
                    showNewPlaylistDialog();
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                Expanded(
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(accentColor: Colors.transparent),
                    child: ListView.builder(
                      itemCount: currentUser.getMyPlaylists.length,
                      itemBuilder: (BuildContext context, int index) {
                        return userPlaylists(currentUser.getMyPlaylists[index]);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding userPlaylists(Playlist playlist) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: songImage(playlist.getSongs[0]),
              fit: BoxFit.fill,
            ),
          ),
        ),
        title: Text(
          playlist.getName,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        onTap: () {
          selectedPlaylist(playlist);
        },
      ),
    );
  }

  void selectedPlaylist(Playlist playlist) {
    bool songAlreadyExistsInPlaylist = false;
    playlist.getSongs.forEach((playlistSong) {
      if (playlistSong.getSongId == song.getSongId) {
        songAlreadyExistsInPlaylist = true;
      }
    });
    if (!songAlreadyExistsInPlaylist) {
      Song updatedsong = FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
      currentUser.addNewSongToPlaylist(playlist, updatedsong);
      Navigator.pop(context);
    } else {
      scafKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 5),
          content: Text(
            "This Song Is Already In Playlist Exists!",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  ImageProvider songImage(Song song) {
    if (song.getImageUrl.length > 0) {
      return NetworkImage(
        song.getImageUrl,
      );
    } else {
      return AssetImage('assets/images/default_song_pic.png');
    }
  }

  void createNewPlatlist() {
    bool nameExists = false;
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      currentUser.getMyPlaylists.forEach((playlist) {
        if (playlist.getName == _playlistName) {
          nameExists = true;
        }
      });
      if (!nameExists) {
        Playlist playlist = Playlist(_playlistName);
        playlist.addNewSong(song);
        currentUser.addNewPlaylist(playlist);
        FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
        audioPlayerManager.currentPlaylist = playlist;
        Navigator.of(context, rootNavigator: true).pop(true);
        Navigator.pop(context);
      } else {
        scafKey.currentState.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
              "Playlist With This Name Already Exists!",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    }
  }

  void showNewPlaylistDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "New playlist",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          backgroundColor: Colors.grey[850],
          children: <Widget>[
            Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Theme(
                      data: ThemeData(
                        hintColor: Colors.white,
                      ),
                      child: TextFormField(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          labelText: "Playlist name",
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                        validator: (value) => value.isEmpty
                            ? 'Playlist name can\'t be empty'
                            : null,
                        onSaved: (value) => _playlistName = value,
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 20,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Text(
                          "Create",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      createNewPlatlist();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
