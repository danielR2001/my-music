import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/core/view_models/page_models/playlist_pick_model.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/core/services/toast_service.dart';
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
  String _playlistName;
  bool _isPublic;
  final formKey = GlobalKey<FormState>();
  final scafKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BasePage<PlaylistPickModel>(
      onModelReady: (model) =>
          model.initModel(Provider.of<User>(context).playlists),
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
                    drawNewPlaylistButton(model),
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
                              Provider.of<User>(context).playlists[index],
                              model);
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

  Widget drawUserPlaylists(Playlist playlist, PlaylistPickModel model) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: drawSongImageWidget(playlist, model),
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
            addSongToPlaylist(playlist, widget.song, false, model)
                .then((added) {
              if (added) {
                hideLoadingBar();
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: true).pop('dialog');
                model.makeToast(
                  ToastService.songAddedToPlaylist + "${playlist.name}",
                  toastLength: Toast.LENGTH_LONG,
                  fontSize: 18,
                  backgroundColor: CustomColors.toastColor,
                  gravity: ToastGravity.CENTER,
                );
              }
            });
          } else {
            addAllSongToPlaylist(playlist, model);
            Navigator.pop(context);
            hideLoadingBar();
            model.makeToast(ToastService.somethingWentWrong);
            model.makeToast(
              ToastService.songAddedToPlaylist + "${playlist.name}",
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

  Widget drawSongImageWidget(Playlist playlist, PlaylistPickModel model) {
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
              blurRadius: 0.3,
              spreadRadius: 0.2,
            ),
          ],
        ),
        child: model.imageProviders[playlist.publicPlaylistPushId] != null
            ? Image(
                image: model.imageProviders[playlist.publicPlaylistPushId],
                fit: BoxFit.contain,
              )
            : Icon(
                Icons.music_note,
                color: CustomColors.pinkColor,
                size: 30,
              ),);
  }

  Widget drawNewPlaylistButton(PlaylistPickModel model) {
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
        showNewPlaylistDialog(model);
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
  Future<bool> addSongToPlaylist(Playlist playlist, Song song,
      bool addingAllSongs, PlaylistPickModel model) async {
    playlist = await model.addSongToPlaylist(playlist, song);
    if (playlist != null) {
      Provider.of<User>(context).updatePlaylist(playlist);
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

  Future<void> createNewPlatlist(PlaylistPickModel model) async {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      if (model.checkIfPlaylistNameValid(
          _playlistName, Provider.of<User>(context).playlists)) {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        showLoadingBar(context);
        Playlist playlist = await model.createNewPlatlist(
            widget.song,
            widget.songs,
            _playlistName,
            Provider.of<User>(context).name,
            _isPublic);
        Provider.of<User>(context).addNewPlaylist(playlist);
        hideLoadingBar();
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
    }
  }

  void showNewPlaylistDialog(PlaylistPickModel model) {
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
                      createNewPlatlist(model);
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

  Future<void> addAllSongToPlaylist(
      Playlist playlist, PlaylistPickModel model) async {
    model.addAllSongsToPlaylist(playlist, widget.songs);
  }
}
