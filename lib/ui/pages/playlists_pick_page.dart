import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/core/view_models/page_models/playlist_pick_model.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/database/firebase/database_manager.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/core/utils/toast.dart';
import 'package:myapp/ui/pages/base_page.dart';
import 'package:provider/provider.dart';

class PlaylistPickPage extends StatefulWidget {
  final song;
  final List<Song> songs;
  PlaylistPickPage({this.song, this.songs});
  @override
  _PlaylistPickPageState createState() => _PlaylistPickPageState();
}

class _PlaylistPickPageState extends State<PlaylistPickPage> {
  PlaylistPickModel _model;
  String _playlistName;
  bool _isPublic;
  final formKey = GlobalKey<FormState>();
  final scafKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BasePage<PlaylistPickModel>(
      onModelReady: (model) => _model = model,
      builder: (context, model, child) => Container(
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
                          drawBackButton(),
                          drawPageTitle(),
                          Container(
                            width: 50,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    drawNewPlaylistButton(),
                    SizedBox(
                      height: 15,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: Provider.of<User>(context).playlists != null
                            ? Provider.of<User>(context).playlists.length
                            : 0,
                        itemBuilder: (BuildContext context, int index) {
                          return drawUserPlaylists(
                              Provider.of<User>(context).playlists[index]);
                        },
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
      ),
    );
  }

  //* widgets
  Widget drawBackButton() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget drawPageTitle() {
    return Expanded(
      child: Text(
        "Add to playlist",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget drawUserPlaylists(Playlist playlist) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: playlist.songs.length > 0
            ? playlist.songs[0].imageUrl.length > 0
                ? drawSongImage(playlist.songs[0])
                : drawDefaultSongImage()
            : drawDefaultSongImage(),
        title: Text(
          playlist.name,
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
                hideLoadingBar();
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: true).pop('dialog');
                _model.makeToast(
                  ToastManager.songAddedToPlaylist + "${playlist.name}",
                  toastLength: Toast.LENGTH_LONG,
                  fontSize: 18,
                  backgroundColor: CustomColors.toastColor,
                  gravity: ToastGravity.CENTER,
                );
              }
            });
          } else {
            addAllSongToPlaylist(playlist);
            Navigator.pop(context);
            hideLoadingBar();
            _model.makeToast(ToastManager.somethingWentWrong);
            _model.makeToast(
              ToastManager.songAddedToPlaylist + "${playlist.name}",
              toastLength: Toast.LENGTH_LONG,
              fontSize: 18,
              backgroundColor: CustomColors.toastColor,
              gravity: ToastGravity.CENTER,
            );
          }
        },
      ),
    );
  }

  Widget drawSongImage(Song song) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: CustomColors.lightGreyColor,
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
            song.imageUrl,
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
            CustomColors.lightGreyColor,
            CustomColors.darkGreyColor,
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
        color: CustomColors.pinkColor,
        size: 40,
      ),
    );
  }

  Widget drawNewPlaylistButton() {
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        height: 55,
        width: 180,
        decoration: BoxDecoration(
          color: CustomColors.pinkColor,
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
        showNewPlaylistDialog();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(
                        value: null,
                        strokeWidth: 3.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            CustomColors.pinkColor),
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

  void hideLoadingBar() {
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }

  //* methods
  Future<bool> addSongToPlaylist(
      Playlist playlist, Song song, bool addingAllSongs) async {
    bool songAlreadyExistsInPlaylist = false;
    Song updatedsong;
    playlist.songs.forEach((playlistSong) {
      if (playlistSong.songId == song.songId) {
        songAlreadyExistsInPlaylist = true;
      }
    });
    if (!songAlreadyExistsInPlaylist) {
      if (song.imageUrl.length == 0) {
        String imageUrl =
            await CustomColors.apiService.getSongImageUrl(song, false);
        if (imageUrl != null) {
          song.setImageUrl = imageUrl;
        }
      }
      if (CustomColors.audioPlayerManager.currentPlaylist != null
          ? playlist.name ==
              CustomColors.audioPlayerManager.currentPlaylist.name
          : false) {
        if (CustomColors.audioPlayerManager.playlistMode ==
            PlaylistMode.shuffle) {
          updatedsong = song;
          updatedsong.setDateAdded = DateTime.now().millisecondsSinceEpoch;
          updatedsong =
              FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
          playlist.addNewSong(updatedsong);
          CustomColors.currentUser.updatePlaylist(playlist);
          CustomColors.audioPlayerManager.loopPlaylist = playlist;
          CustomColors.audioPlayerManager.setCurrentPlaylist();
        } else {
          updatedsong = song;
          updatedsong.setDateAdded = DateTime.now().millisecondsSinceEpoch;
          updatedsong =
              FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
          playlist.addNewSong(updatedsong);
          CustomColors.currentUser.updatePlaylist(playlist);
          CustomColors.audioPlayerManager.loopPlaylist = playlist;
        }
      } else {
        updatedsong = song;
        updatedsong.setDateAdded = DateTime.now().millisecondsSinceEpoch;
        updatedsong = FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
        playlist.addNewSong(updatedsong);
        CustomColors.currentUser.updatePlaylist(playlist);
      }
      return true;
    } else {
      if (!addingAllSongs) {
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
        CustomColors.currentUser.playlists.forEach((playlist) {
          if (playlist.name == _playlistName) {
            nameExists = true;
          }
        });
        if (!nameExists) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          showLoadingBar(context);
          Playlist playlist = Playlist(_playlistName,
              creator: CustomColors.currentUser.name, isPublic: _isPublic);
          playlist.setPushId = FirebaseDatabaseManager.addPlaylist(playlist);
          if (playlist.isPublic) {
            playlist =
                await FirebaseDatabaseManager.addPublicPlaylist(playlist, true);
          }
          if (widget.song != null) {
            if (widget.song.imageUrl.length == 0) {
              String imageUrl = await CustomColors.apiService
                  .getSongImageUrl(widget.song, false);
              if (imageUrl != null) {
                widget.song.setImageUrl = imageUrl;
              }
            }
            updatedsong = widget.song;
            updatedsong.setDateAdded = DateTime.now().millisecondsSinceEpoch;
            updatedsong = FirebaseDatabaseManager.addSongToPlaylist(
                playlist, widget.song);
            playlist.addNewSong(updatedsong);
            CustomColors.currentUser.addNewPlaylist(playlist);
          } else {
            widget.songs.forEach((song) {
              if (song.imageUrl == "") {
                CustomColors.apiService
                    .getSongImageUrl(song, false)
                    .then((imageUrl) {
                  if (imageUrl != null) {
                    song.setImageUrl = imageUrl;
                    updatedsong = FirebaseDatabaseManager.addSongToPlaylist(
                        playlist, song);
                    playlist.addNewSong(updatedsong);
                  }
                });
              } else {
                updatedsong =
                    FirebaseDatabaseManager.addSongToPlaylist(playlist, song);
                playlist.addNewSong(updatedsong);
              }
            });
            CustomColors.currentUser.addNewPlaylist(playlist);
          }
          hideLoadingBar();
          Navigator.pop(context);
        } else {
          hideLoadingBar();
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
                          activeColor: CustomColors.pinkColor,
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
                          color: CustomColors.pinkColor,
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

  Future<void> addAllSongToPlaylist(Playlist playlist) async {
    widget.songs.forEach((song) {
      addSongToPlaylist(playlist, song, true);
    });
  }
}
