import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/core/view_models/modal_sheet_models/playlist_options_model.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/core/services/toast_service.dart';
import 'package:myapp/ui/custom_classes/custom_icons.dart';
import 'package:myapp/ui/pages/base_page.dart';
import 'package:myapp/ui/pages/playlists_pick_page.dart';
import 'package:myapp/ui/modal_sheets/sort_modal_buttom_sheet.dart';
import 'package:provider/provider.dart';

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
    return BasePage<PlaylistOptionsModel>(
      builder: (context, model, child) => Container(
        alignment: Alignment.topCenter,
        height: 53 * widgetsCount,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0)),
          color: CustomColors.lightGreyColor,
        ),
        child: Column(
          children: <Widget>[
            drawDownloadAll(model),
            drawUnDownloadAll(model),
            drawAddAllToPlayList(),
            drawRenamePlaylist(model),
            drawSort(),
            drawPlaylistPrivacy(model),
            drawDelete(model),
          ],
        ),
      ),
    );
  }

  Widget drawDownloadAll(PlaylistOptionsModel model) {
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
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          model.downloadAll(widget.playlist.songs);
          Navigator.pop(context);
          model.makeToast(ToastService.startedDownloadAllSongs);
        },
      );
    } else {
      return Container();
    }
  }

  Widget drawAddAllToPlayList() {
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
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PlaylistPickPage(song: null, songs: widget.playlist.songs),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

  Widget drawUnDownloadAll(PlaylistOptionsModel model) {
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
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          if (model.getCurrentDownloading().length == 0) {
            model.unDownloadAll(widget.playlist);
            Navigator.pop(context);
            model.makeToast(ToastService.undownloadAllSongs);
          } else {
            model.makeToast(ToastService.undownloadAllError);
          }
        },
      );
    } else {
      return Container();
    }
  }

  Widget drawRenamePlaylist(PlaylistOptionsModel model) {
    if (widget.playlistMode == PlaylistModalSheetMode.regular) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        dense: true,
        leading: Icon(
          Icons.edit,
          color: Colors.grey,
          size: 28,
        ),
        title: Text(
          "Rename playlist",
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          showRenamePlaylistDialog(context, model);
        },
      );
    } else {
      return Container();
    }
  }

  Widget drawSort() {
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
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        showPlaylistOptions(widget.playlist, context);
      },
    );
  }

  Widget drawPlaylistPrivacy(PlaylistOptionsModel model) {
    if (widget.playlistMode == PlaylistModalSheetMode.regular) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        dense: true,
        leading: Icon(
          widget.playlist.isPublic ? Icons.public : MyCustomIcons.private_icon,
          color: Colors.grey,
          size: 30,
        ),
        title: Text(
          widget.playlist.isPublic ? "Public" : "Private",
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        onTap: () async {
          setState(() {
            widget.playlist.setIsPublic = !widget.playlist.isPublic;
          });
          final Playlist temp = await model.changePlaylistPrivacy(widget.playlist);
          Provider.of<User>(context).updatePlaylist(temp);
        },
      );
    } else {
      return Container();
    }
  }

  Widget drawDelete(PlaylistOptionsModel model) {
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
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          showAlertDialog(context, model);
        },
      );
    } else {
      return Container();
    }
  }

  void showPlaylistOptions(Playlist currentPlaylist, BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) {
        return SortModalSheet(
          currentPlaylist,
          widget.playlistMode == PlaylistModalSheetMode.public ? false : true,
        );
      },
    );
  }

  void showRenamePlaylistDialog(BuildContext context, PlaylistOptionsModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "Rename Playlist",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: CustomColors.lightGreyColor,
          children: <Widget>[
            Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  drawNewNameTextField(),
                  drawRenameButton(model),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  //* widgets
  Widget drawNewNameTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
          validator: (value) =>
              value.isEmpty ? 'Playlist name can\'t be empty' : null,
          onSaved: (value) => _playlistNewName = value,
        ),
      ),
    );
  }

  Widget drawRenameButton(PlaylistOptionsModel model) {
    return GestureDetector(
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
            "Rename",
            style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
      onTap: () {
        changePlaylistName(context, model);
      },
    );
  }

  //* methods
  Future<void> changePlaylistName(BuildContext context, PlaylistOptionsModel model) async {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      final Playlist temp = await model.changePlaylistName(widget.playlist, _playlistNewName);
      Provider.of<User>(context).updatePlaylist(temp);
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }
  }

  void showAlertDialog(BuildContext context, PlaylistOptionsModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "Hii " + Provider.of<User>(context).name + "!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                "Are you sure?",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        height: 50.0,
                        width: 90,
                        decoration: BoxDecoration(
                          color: CustomColors.pinkColor,
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        height: 50.0,
                        width: 90,
                        decoration: BoxDecoration(
                          color: CustomColors.pinkColor,
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Text(
                          "Yes",
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () {
                        model.removePlaylist(widget.playlist);
                        Provider.of<User>(context).removePlaylist(widget.playlist); //! TODO maybe wrong
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                        // Navigator.of(context, rootNavigator: true)
                        //     .pop('dialog');
                        Navigator.of(widget.playlistPageContext).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          backgroundColor: Colors.grey[850],
        );
      },
    );
  }
}
