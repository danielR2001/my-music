import 'package:flutter/material.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/ui/pages/home_page.dart';
import 'package:myapp/ui/widgets/sort_options_modal_buttom_sheet.dart';

class PlaylistOptionsModalSheet extends StatelessWidget {
  final Playlist playlist;
  PlaylistOptionsModalSheet(this.playlist);
  String _playlistNewName;
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      color: Colors.grey[850],
      height: 180,
      child: Column(
        children: <Widget>[
          Padding(
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
                showNewPlaylistDialog(context);
              },
            ),
          ),
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
                showPlaylistOptions(playlist, context);
              },
            ),
          ),
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
              onTap: () {},
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

  void showNewPlaylistDialog(BuildContext context) {
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
                          color: Colors.pink,
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
      FirebaseDatabaseManager.renamePlaylist(playlist, _playlistNewName);
      playlist.setName = _playlistNewName;
      currentUser.updatePlaylist(playlist);
      if (audioPlayerManager.currentPlaylist != null) {
        if (audioPlayerManager.currentPlaylist.getPushId ==
            playlist.getPushId) {
          audioPlayerManager.currentPlaylist.setName = _playlistNewName;
        }
      }
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }
  }
}
