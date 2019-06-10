import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/ui/pages/home_page.dart';
import 'package:myapp/ui/widgets/sort_options_modal_buttom_sheet.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';

class PlaylistOptionsModalSheet extends StatefulWidget {
  final Playlist playlist;
  final BuildContext playlistPageContext;
  PlaylistOptionsModalSheet(this.playlist, this.playlistPageContext);

  @override
  _PlaylistOptionsModalSheetState createState() =>
      _PlaylistOptionsModalSheetState();
}

class _PlaylistOptionsModalSheetState extends State<PlaylistOptionsModalSheet> {
  String _playlistNewName;
  double widgetsCount = 5;
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    if(widget.playlist.getPushId ==
        currentUser.getDownloadedSongsPlaylist.getPushId){
          widgetsCount = 3;
        }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      color: Constants.lightGreyColor,
      height: 57*widgetsCount,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              leading: Icon(
                Icons.save_alt,
                color: Colors.grey,
                size: 30,
              ),
              title: Text(
                "Download All",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                downloadAll();
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "Started downloading all songs",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIos: 1,
                  backgroundColor: Constants.pinkColor,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                Future.delayed(
                    Duration(seconds: 2),
                    () => Fluttertoast.showToast(
                          msg:
                              "Don't worry! downloading only songs that aren't downloaded yet :D",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIos: 1,
                          backgroundColor: Constants.pinkColor,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        ));
              },
            ),
          ),
          showRenamePlaylist(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              leading: Icon(
                Icons.sort,
                color: Colors.grey,
                size: 30,
              ),
              title: Text(
                "Sort",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                showPlaylistOptions(widget.playlist, context);
              },
            ),
          ),
          showPlaylistPrivacy(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              leading: Icon(
                Icons.delete,
                color: Colors.grey,
                size: 30,
              ),
              title: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
                Navigator.of(widget.playlistPageContext).pop();
                FirebaseDatabaseManager.removePlaylist(widget.playlist);
                currentUser.removePlaylist(widget.playlist);
                if (audioPlayerManager.currentPlaylist.getName ==
                    audioPlayerManager.currentPlaylist.getName) {
                  audioPlayerManager.loopPlaylist = null;
                  audioPlayerManager.shuffledPlaylist = null;
                  audioPlayerManager.currentPlaylist = null;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void showPlaylistOptions(Playlist currentPlaylist, BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: homePageContext,
      builder: (builder) {
        return SortOptionsModalSheet(
          currentPlaylist,
        );
      },
    );
  }

  void showRenamePlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "Rename Playlist",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          backgroundColor: Constants.lightGreyColor,
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
                          labelText: "New name",
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                        validator: (value) => value.isEmpty
                            ? 'Playlist name can\'t be empty'
                            : null,
                        onSaved: (value) => _playlistNewName = value,
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
                          color: Constants.pinkColor,
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Text(
                          "Rename",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      changePlaylistName(context);
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

  void changePlaylistName(BuildContext context) {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      FirebaseDatabaseManager.renamePlaylist(widget.playlist, _playlistNewName);
      widget.playlist.setName = _playlistNewName;
      currentUser.updatePlaylist(widget.playlist);
      if (audioPlayerManager.currentPlaylist != null) {
        if (audioPlayerManager.currentPlaylist.getPushId ==
            widget.playlist.getPushId) {
          audioPlayerManager.currentPlaylist.setName = _playlistNewName;
        }
      }
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }
  }

  void downloadAll() {
    widget.playlist.getSongs.forEach((song) {
      ManageLocalSongs.checkIfFileExists(song).then((exists) {
        if (!exists) {
          ManageLocalSongs.downloadSong(song);
        }
      });
    });
  }

  Widget showPlaylistPrivacy() {
    if (widget.playlist.getPushId !=
        currentUser.getDownloadedSongsPlaylist.getPushId) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListTile(
          leading: Icon(
            widget.playlist.getIsPublic ? Icons.public : Icons.lock,
            color: Colors.grey,
            size: 30,
          ),
          title: Text(
            widget.playlist.getIsPublic ? "Public" : "Private",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          onTap: () {
            setState(() {
              widget.playlist.setIsPublic = !widget.playlist.getIsPublic;
            });
            FirebaseDatabaseManager.changePlaylistPrivacy(widget.playlist);
            currentUser.updatePlaylist(widget.playlist);
          },
        ),
      );
    } else {
      return Container();
    }
  }

  Widget showRenamePlaylist() {
    if (widget.playlist.getPushId !=
        currentUser.getDownloadedSongsPlaylist.getPushId) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListTile(
          leading: Icon(
            Icons.edit,
            color: Colors.grey,
            size: 30,
          ),
          title: Text(
            "Rename playlist",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          onTap: () {
            showRenamePlaylistDialog(context);
          },
        ),
      );
    } else {
      return Container();
    }
  }
}
