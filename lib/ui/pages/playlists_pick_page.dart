import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/models/playlist.dart';

class PlaylistPickPage extends StatefulWidget {
  final song;
  final List<Song> songs;
  PlaylistPickPage({this.song, this.songs});
  @override
  _PlaylistPickPageState createState() => _PlaylistPickPageState();
}

class _PlaylistPickPageState extends State<PlaylistPickPage> {
  String _playlistName;
  bool _isPublic;
  final formKey = GlobalKey<FormState>();
  final scafKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        key: scafKey,
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xDE000000),
          ),
          child: SafeArea(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Expanded(
                          child: Text(
                            "Add to playlist",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          width: 50,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    child: Container(
                      alignment: Alignment.center,
                      height: 55,
                      width: 180,
                      decoration: BoxDecoration(
                        color: GlobalVariables.pinkColor,
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Text(
                        "New Playlist",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      drawNewPlaylistDialog();
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
                        itemCount: currentUser.getPlaylists != null
                            ? currentUser.getPlaylists.length
                            : 0,
                        itemBuilder: (BuildContext context, int index) {
                          return userPlaylists(currentUser.getPlaylists[index]);
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
      ),
    );
  }

  Padding userPlaylists(Playlist playlist) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: playlist.getSongs.length > 0
            ? playlist.getSongs[0].getImageUrl.length > 0
                ? drawSongImage(playlist.getSongs[0])
                : drawDefaultSongImage()
            : drawDefaultSongImage(),
        title: Text(
          playlist.getName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          if (widget.song != null) {
            showLoadingBar(context);
            addSongToPlaylist(playlist, widget.song, false).then((added) {
              if (added) {
                Navigator.of(context, rootNavigator: true).pop('dialog');
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: true).pop('dialog');
                _makeToast(text: "Added to ${playlist.getName}");
              }
            });
          } else {
            addAllSongToPlaylist(playlist);
            Navigator.pop(context);
            Navigator.of(context, rootNavigator: true).pop('dialog');
            _makeToast(text: "Added to ${playlist.getName}");
          }
        },
      ),
    );
  }

  Future<bool> addSongToPlaylist(
      Playlist playlist, Song song, bool addingAllSongs) async {
    bool songAlreadyExistsInPlaylist = false;
    Song updatedsong;
    playlist.getSongs.forEach((playlistSong) {
      if (playlistSong.getSongId == song.getSongId) {
        songAlreadyExistsInPlaylist = true;
      }
    });
    if (!songAlreadyExistsInPlaylist) {
      if (song.getImageUrl.length == 0) {
        String imageUrl = await FetchData.getSongImageUrl(song, false);
        song.setImageUrl = imageUrl;
      }
      if (audioPlayerManager.currentPlaylist != null
          ? playlist.getName == audioPlayerManager.currentPlaylist.getName
          : false) {
        if (audioPlayerManager.playlistMode == PlaylistMode.shuffle) {
          updatedsong = song;
          updatedsong.setDateAdded = DateTime.now().millisecondsSinceEpoch;
          updatedsong =
              FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
          playlist.addNewSong(updatedsong);
          currentUser.updatePlaylist(playlist);
          audioPlayerManager.loopPlaylist = playlist;
          audioPlayerManager.setCurrentPlaylist();
        } else {
          updatedsong = song;
          updatedsong.setDateAdded = DateTime.now().millisecondsSinceEpoch;
          updatedsong =
              FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
          playlist.addNewSong(updatedsong);
          currentUser.updatePlaylist(playlist);
          audioPlayerManager.loopPlaylist = playlist;
        }
      } else {
        updatedsong = song;
        updatedsong.setDateAdded = DateTime.now().millisecondsSinceEpoch;
        updatedsong = FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
        playlist.addNewSong(updatedsong);
        currentUser.updatePlaylist(playlist);
      }
      return true;
    } else {
      if (!addingAllSongs) {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        scafKey.currentState.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text(
              "This song Is Already In Playlist Exists!",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      }
      return false;
    }
  }

  Future<void> createNewPlatlist() async {
    bool nameExists = false;
    final form = formKey.currentState;
    Song updatedsong;
    if (form.validate()) {
      form.save();
      if (_playlistName != "Search Playlist") {
        currentUser.getPlaylists.forEach((playlist) {
          if (playlist.getName == _playlistName) {
            nameExists = true;
          }
        });
        if (!nameExists) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          showLoadingBar(context);
          Playlist playlist = Playlist(_playlistName,
              creator: currentUser.getName, isPublic: _isPublic);
          playlist.setPushId = FirebaseDatabaseManager.addPlaylist(playlist);
          if (playlist.getIsPublic) {
            playlist =
                await FirebaseDatabaseManager.addPublicPlaylist(playlist, true);
          }
          if (widget.song != null) {
            if (widget.song.getImageUrl.length == 0) {
              String imageUrl =
                  await FetchData.getSongImageUrl(widget.song, false);
              widget.song.setImageUrl = imageUrl;
            }
            updatedsong = widget.song;
            updatedsong.setDateAdded = DateTime.now().millisecondsSinceEpoch;
            updatedsong = FirebaseDatabaseManager.addSongToPlaylist(
                playlist, widget.song);
            playlist.addNewSong(updatedsong);
            currentUser.addNewPlaylist(playlist);
          } else {
            widget.songs.forEach((song) {
              if (song.getImageUrl.length == 0) {
                FetchData.getSongImageUrl(song, false).then((imageUrl) {
                  song.setImageUrl = imageUrl;
                  updatedsong =
                      FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
                  playlist.addNewSong(updatedsong);
                });
              } else {
                updatedsong =
                    FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
                playlist.addNewSong(updatedsong);
              }
            });
            currentUser.addNewPlaylist(playlist);
          }
          Navigator.of(context, rootNavigator: true).pop('dialog');
          Navigator.pop(context);
        } else {
          Navigator.of(context, rootNavigator: true).pop('dialog');
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
      } else {
        scafKey.currentState.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
              "Can't name playlist Search Playlist!",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    }
  }

  void drawNewPlaylistDialog() {
    _isPublic = false;
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
                            fontSize: 16,
                          ),
                        ),
                        validator: (value) => value.isEmpty
                            ? 'Playlist name can\'t be empty'
                            : null,
                        onSaved: (value) => _playlistName = value,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Text(
                          "Set as public:",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )),
                        Switch(
                          value: _isPublic,
                          activeColor: GlobalVariables.pinkColor,
                          dragStartBehavior: DragStartBehavior.down,
                          onChanged: (value) {
                            setState(() {
                              _isPublic = value;
                            });
                          },
                        ),
                      ],
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
                          color: GlobalVariables.pinkColor,
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Text(
                          "Create",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

  void showLoadingBar(BuildContext context1) {
    showDialog(
      context: context1,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(0.0),
          backgroundColor: Colors.transparent,
          children: <Widget>[
            Container(
              width: 60.0,
              height: 60.0,
              alignment: AlignmentDirectional.center,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Center(
                    child: new SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: new CircularProgressIndicator(
                        value: null,
                        strokeWidth: 3.0,
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            GlobalVariables.pinkColor),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Widget drawSongImage(Song song) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: GlobalVariables.lightGreyColor,
        shape: BoxShape.rectangle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[850],
            blurRadius: 0.3,
            spreadRadius: 0.2,
          ),
        ],
        image: DecorationImage(
          fit: BoxFit.fill,
          image: NetworkImage(
            song.getImageUrl,
          ),
        ),
      ),
    );
  }

  Widget drawDefaultSongImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlobalVariables.lightGreyColor,
            GlobalVariables.darkGreyColor,
          ],
          begin: FractionalOffset.bottomLeft,
          stops: [0.3, 0.8],
          end: FractionalOffset.topRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[850],
            blurRadius: 1.0,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Icon(
        Icons.music_note,
        color: GlobalVariables.pinkColor,
        size: 40,
      ),
    );
  }

  Future<void> addAllSongToPlaylist(Playlist playlist) async {
    widget.songs.forEach((song) {
      addSongToPlaylist(playlist, song, true);
    });
  }

  void _makeToast({String text}) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIos: 3,
      fontSize: 18.0,
      gravity: ToastGravity.CENTER,
      backgroundColor: GlobalVariables.toastColor,
      textColor: Colors.white,
    );
  }
}
