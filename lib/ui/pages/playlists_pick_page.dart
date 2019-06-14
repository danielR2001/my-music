import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                          child: Container(),
                          flex: 3,
                        ),
                        Text(
                          "Add to playlist",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Expanded(
                          child: Container(),
                          flex: 5,
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
                        color: Constants.pinkColor,
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Text(
                        "New Playlist",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
                        itemCount: currentUser.getMyPlaylists != null
                            ? currentUser.getMyPlaylists.length
                            : 0,
                        itemBuilder: (BuildContext context, int index) {
                          return userPlaylists(
                              currentUser.getMyPlaylists[index]);
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
            fontSize: 18,
          ),
        ),
        onTap: () {
          selectedPlaylist(playlist);
        },
      ),
    );
  }

  void selectedPlaylist(Playlist playlist) async {
    bool songAlreadyExistsInPlaylist = false;
    Song updatedsong;
    playlist.getSongs.forEach((playlistSong) {
      if (playlistSong.getSongId == song.getSongId) {
        songAlreadyExistsInPlaylist = true;
      }
    });
    if (!songAlreadyExistsInPlaylist) {
      showLoadingBar();
      if (audioPlayerManager.currentPlaylist != null
          ? playlist.getName == audioPlayerManager.currentPlaylist.getName
          : false) {
        if (audioPlayerManager.playlistMode == PlaylistMode.shuffle) {
          if (song.getImageUrl.length == 0) {
            String imageUrl = await FetchData.getSongImageUrl(song);
            song.setImageUrl = imageUrl;
          }
          updatedsong = song;
          updatedsong.setDateAdded = DateTime.now().millisecondsSinceEpoch;
          updatedsong =
              FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
          playlist.addNewSong(updatedsong);
          currentUser.updatePlaylist(playlist);
          audioPlayerManager.loopPlaylist = playlist;
          audioPlayerManager.setCurrentPlaylist();
          Navigator.of(context, rootNavigator: true).pop('dialog');
          Navigator.pop(context);
        } else {
          if (song.getImageUrl.length == 0) {
            String imageUrl = await FetchData.getSongImageUrl(song);
            song.setImageUrl = imageUrl;
          }
          updatedsong = song;
          updatedsong.setDateAdded = DateTime.now().millisecondsSinceEpoch;
          updatedsong =
              FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
          playlist.addNewSong(updatedsong);
          currentUser.updatePlaylist(playlist);
          audioPlayerManager.loopPlaylist = playlist;
          Navigator.of(context, rootNavigator: true).pop('dialog');
          Navigator.pop(context);
        }
      } else {
        if (song.getImageUrl.length == 0) {
          String imageUrl = await FetchData.getSongImageUrl(song);
          song.setImageUrl = imageUrl;
        }
        updatedsong = song;
        updatedsong.setDateAdded = DateTime.now().millisecondsSinceEpoch;
        updatedsong = FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
        playlist.addNewSong(updatedsong);
        currentUser.updatePlaylist(playlist);
        Navigator.of(context, rootNavigator: true).pop('dialog');
        Navigator.pop(context);
      }
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

  Future createNewPlatlist() async {
    bool nameExists = false;
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      if (_playlistName != "Search Playlist") {
        currentUser.getMyPlaylists.forEach((playlist) {
          if (playlist.getName == _playlistName) {
            nameExists = true;
          }
        });
        if (!nameExists) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          showLoadingBar();
          Playlist playlist = Playlist(_playlistName, isPublic: _isPublic);

          if (song.getImageUrl.length == 0) {
            String imageUrl = await FetchData.getSongImageUrl(song);
            song.setImageUrl = imageUrl;
          }
          FirebaseDatabaseManager.addPlaylist(playlist);
          Song updatedsong =
              FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
          playlist.addNewSong(updatedsong);
          currentUser.addNewPlaylist(playlist);
          Navigator.of(context, rootNavigator: true).pop('dialog');
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
      } else {
        scafKey.currentState.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
              "Cant name playlist Search Playlist!",
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
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(18),
                        ],
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
                          activeColor: Constants.pinkColor,
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
                          color: Constants.pinkColor,
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

  void showLoadingBar() {
    showDialog(
      context: context,
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
                            Constants.pinkColor),
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
        color: Constants.lightGreyColor,
        shape: BoxShape.rectangle,
        border: Border.all(
          color: Constants.lightGreyColor,
          width: 0.4,
        ),
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
            Constants.lightGreyColor,
            Constants.darkGreyColor,
          ],
          begin: FractionalOffset.bottomLeft,
          stops: [0.3, 0.8],
          end: FractionalOffset.topRight,
        ),
        border: Border.all(
          color: Constants.darkGreyColor,
          width: 0.3,
        ),
      ),
      child: Icon(
        Icons.music_note,
        color: Constants.pinkColor,
        size: 40,
      ),
    );
  }
}
