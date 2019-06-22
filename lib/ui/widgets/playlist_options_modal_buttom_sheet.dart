import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/ui/pages/home_page.dart';
import 'package:myapp/ui/pages/playlists_pick_page.dart';
import 'package:myapp/ui/widgets/sort_options_modal_buttom_sheet.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';

enum PlaylistModalSheetMode {
  regular,
  download,
  public,
}

class PlaylistOptionsModalSheet extends StatefulWidget {
  final Playlist playlist;
  final BuildContext playlistPageContext;
  final PlaylistModalSheetMode playlistMode;
  PlaylistOptionsModalSheet(
      this.playlist, this.playlistPageContext, this.playlistMode);

  @override
  _PlaylistOptionsModalSheetState createState() =>
      _PlaylistOptionsModalSheetState();
}

class _PlaylistOptionsModalSheetState extends State<PlaylistOptionsModalSheet> {
  String _playlistNewName;
  double widgetsCount = 7;
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    if (widget.playlistMode == PlaylistModalSheetMode.download) {
      widgetsCount = 2;
    } else if (widget.playlistMode == PlaylistModalSheetMode.public) {
      widgetsCount = 3;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      color: Constants.lightGreyColor,
      height: 52 * widgetsCount,
      child: Column(
        children: <Widget>[
          showDownloadAll(),
          showUnDownloadAll(),
          showAddAllToPlayList(),
          showRenamePlaylist(),
          showSort(),
          showPlaylistPrivacy(),
          showDelete(),
        ],
      ),
    );
  }

  Widget showDownloadAll() {
    if (widget.playlistMode == PlaylistModalSheetMode.regular ||
        widget.playlistMode == PlaylistModalSheetMode.public) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        dense: true,
        leading: Icon(
          Icons.save_alt,
          color: Colors.grey,
          size: 30,
        ),
        title: Text(
          "Download all",
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
      );
    } else {
      return Container();
    }
  }

  Widget showAddAllToPlayList() {
    if (widget.playlistMode == PlaylistModalSheetMode.regular ||
        widget.playlistMode == PlaylistModalSheetMode.public) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        dense: true,
        leading: Icon(
          Icons.playlist_add,
          color: Colors.grey,
          size: 30,
        ),
        title: Text(
          "Add all to playlist",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PlaylistPickPage(song: null, songs: widget.playlist.getSongs),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

  Widget showUnDownloadAll() {
    if (widget.playlistMode == PlaylistModalSheetMode.regular ||
        widget.playlistMode == PlaylistModalSheetMode.download) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        dense: true,
        leading: Icon(
          Icons.delete_sweep,
          color: Colors.grey,
          size: 30,
        ),
        title: Text(
          "Undownload all",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        onTap: () {
          if (ManageLocalSongs.currentDownloading.length == 0) {
            unDownloadAll();
            Navigator.pop(context);
            Fluttertoast.showToast(
              msg: "undownloaded all songs!",
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
                          "Don't worry! undownloading only songs that aren downloaded yet :D",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIos: 1,
                      backgroundColor: Constants.pinkColor,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    ));
          } else {
            Fluttertoast.showToast(
              msg: "Can't undownload songs when download is in progress",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: Constants.pinkColor,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        },
      );
    } else {
      return Container();
    }
  }

  Widget showRenamePlaylist() {
    if (widget.playlistMode == PlaylistModalSheetMode.regular) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        dense: true,
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
      );
    } else {
      return Container();
    }
  }

  Widget showSort() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
      dense: true,
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
    );
  }

  Widget showPlaylistPrivacy() {
    if (widget.playlistMode == PlaylistModalSheetMode.regular) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        dense: true,
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
        onTap: () async {
          setState(() {
            widget.playlist.setIsPublic = !widget.playlist.getIsPublic;
          });
          Playlist temp = widget.playlist;
          if (widget.playlist.getIsPublic) {
            temp = await FirebaseDatabaseManager.addPublicPlaylist(widget.playlist);
          } else {
            FirebaseDatabaseManager.removeFromPublicPlaylist(widget.playlist);
          }
          FirebaseDatabaseManager.changePlaylistPrivacy(temp);
          currentUser.updatePlaylist(temp);
        },
      );
    } else {
      return Container();
    }
  }

  Widget showDelete() {
    if (widget.playlistMode == PlaylistModalSheetMode.regular) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        dense: true,
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
          FirebaseDatabaseManager.removePlaylist(widget.playlist);
          currentUser.removePlaylist(widget.playlist);
          if (audioPlayerManager.currentPlaylist != null) {
            if (audioPlayerManager.currentPlaylist.getName ==
                audioPlayerManager.currentPlaylist.getName) {
              audioPlayerManager.loopPlaylist = null;
              audioPlayerManager.shuffledPlaylist = null;
              audioPlayerManager.currentPlaylist = null;
            }
          }
          Navigator.of(context, rootNavigator: true).pop('dialog');
          Navigator.of(widget.playlistPageContext).pop();
        },
      );
    } else {
      return Container();
    }
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
                        horizontal: 20, vertical: 20),
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

  void unDownloadAll() {
    widget.playlist.getSongs.forEach((song) {
      ManageLocalSongs.checkIfFileExists(song).then((exists) {
        if (exists) {
          ManageLocalSongs.deleteSongDirectory(song);
          currentUser.removeSongToDownloadedPlaylist(song);
        }
      });
    });
  }
}
