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

  final formKey = new GlobalKey<FormState>();

  final scafKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scafKey,
      backgroundColor: Color(0xFA000000),
      appBar: AppBar(
        backgroundColor: Color(0xFA000000),
      ),
      body: Container(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: new Text(
                        "New playlist",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                      backgroundColor: Colors.grey[850],
                      children: <Widget>[
                        new Form(
                          key: formKey,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Theme(
                                  data: new ThemeData(
                                    hintColor: Colors.white,
                                  ),
                                  child: new TextFormField(
                                    style: new TextStyle(
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
                                  child: new Container(
                                    alignment: Alignment.center,
                                    height: 50.0,
                                    decoration: new BoxDecoration(
                                      color: Colors.pink,
                                      borderRadius:
                                          new BorderRadius.circular(40.0),
                                    ),
                                    child: new Text(
                                      "Create",
                                      style: new TextStyle(
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
              },
              child: new Container(
                alignment: Alignment.center,
                height: 55,
                width: 140,
                decoration: new BoxDecoration(
                  color: Colors.pink,
                  borderRadius: new BorderRadius.circular(40.0),
                ),
                child: new Text(
                  "New Playlist",
                  style: new TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: Theme(
                data:
                    Theme.of(context).copyWith(accentColor: Colors.transparent),
                child: new ListView.builder(
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
    );
  }

  Padding userPlaylists(Playlist playlist) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0, top: 20),
      child: new ListTile(
          leading: new Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: songImage(playlist.getSongs[0]),
                fit: BoxFit.contain,
              ),
              border: Border.all(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
          ),
          title: new Text(
            playlist.getName,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onTap: () {
            bool songAlreadyExistsInPlaylist = false;
            playlist.getSongs.forEach((playlistSong) {
              if (playlistSong.getSongId == song.getSongId) {
                songAlreadyExistsInPlaylist = true;
              }
            });
            if (!songAlreadyExistsInPlaylist) {
              FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
              currentUser.addNewSongToPlaylist(playlist, song);
              Navigator.pop(context);
            } else {
              scafKey.currentState.showSnackBar(
                new SnackBar(
                  duration: new Duration(seconds: 5),
                  content: new Text(
                    "This Song Is Already In Playlist Exists!",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }
          }),
    );
  }

  ImageProvider songImage(Song song) {
    if (song.getImageUrl.length > 0) {
      return new NetworkImage(
        song.getImageUrl,
      );
    } else {
      return new AssetImage('assets/images/default_song_pic.png');
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
        Playlist playlist = new Playlist(_playlistName);
        playlist.addNewSong(song);
        currentUser.addNewPlaylist(playlist);
        FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
        playingNow.currentPlaylist = playlist;
        Navigator.of(context, rootNavigator: true).pop(true);
        Navigator.pop(context);
      } else {
        scafKey.currentState.showSnackBar(
          new SnackBar(
            duration: new Duration(seconds: 5),
            content: new Text(
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
}
