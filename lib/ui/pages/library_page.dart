import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:myapp/core/view_models/page_models/library_model.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/custom_classes/custom_icons.dart';
import 'package:myapp/ui/pages/base_page.dart';
import 'package:provider/provider.dart';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  LibraryModel _model;
  bool openPlaylists = true;

  @override
  Widget build(BuildContext context) {
    return BasePage<LibraryModel>(
      onModelReady: (model) {
        _model = model;
        _model.initModel(Provider.of<User>(context));
      },
      builder: (context, model, child) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CustomColors.darkGreyColor,
              CustomColors.lightGreyColor,
              CustomColors.pinkColor,
            ],
            begin: FractionalOffset.bottomRight,
            stops: [0.2, 0.7, 1.0],
            end: FractionalOffset.topLeft,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        "Your Library",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: IconButton(
                        icon: Icon(
                          MyCustomIcons.logout_icon,
                          size: 22,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          showAlertDialog(context);
                        },
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 0,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ListTile(
                  leading: Icon(
                    Icons.save_alt,
                    color: Colors.white,
                    size: 30,
                  ),
                  title: Text(
                    "My device" +
                        "  (${Provider.of<User>(context).downloadedSongsPlaylist.songs.length})",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      "/playlist",
                      arguments: _model.createMap(
                          Provider.of<User>(context).downloadedSongsPlaylist),
                    );
                  }),
              SizedBox(
                height: 20,
              ),
              ListTile(
                leading: Icon(
                  Icons.queue_music,
                  color: Colors.white,
                  size: 30,
                ),
                title: Text(
                  "My Playlists",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  icon: openPlaylists
                      ? Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                  onPressed: () {
                    setState(() {
                      openPlaylists = !openPlaylists;
                    });
                  },
                ),
              ),
              showOrHidePlaylists(),
            ],
          ),
        ),
      ),
    );
  }

  //* widgets
  Widget userPlaylists(Playlist playlist, BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 40,
        bottom: 10,
      ),
      child: ListTile(
          leading: playlist.songs.length > 0
              ? drawSongImage(playlist.songs[0], index)
              : drawSongImage(null, index),
          title: AutoSizeText(
            _model.cutPlaylistName(playlist) + "  (${playlist.songs.length})",
            style: TextStyle(
              fontSize: 17,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: Colors.white,
          ),
          onTap: () {
            Navigator.pushNamed(context, "/playlist",
                arguments: _model.createMap(playlist));
          }),
    );
  }

  Widget showOrHidePlaylists() {
    if (openPlaylists) {
      return Expanded(
        child: ListView.builder(
          itemCount: Provider.of<User>(context).playlists.length,
          itemBuilder: (BuildContext context, int index) {
            return userPlaylists(
                Provider.of<User>(context).playlists[index], context, index);
          },
        ),
      );
    } else {
      return Container();
    }
  }

  Widget drawSongImage(Song song, int index) {
    if (song != null) {
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
          border: Border.all(
            color: Colors.black,
            width: 0.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[850],
              blurRadius: 0.1,
              spreadRadius: 0.1,
            ),
          ],
        ),
        child: _model.imageProviders.length != 0 &&
                _model.imageProviders[song.songId] != null
            ? Image(
                image: _model.imageProviders[song.songId],
                fit: BoxFit.cover,
              )
            : Icon(
                Icons.music_note,
                color: CustomColors.pinkColor,
                size: 30,
              ),
      );
    } else {
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
          border: Border.all(
            color: Colors.black,
            width: 0.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[850],
              blurRadius: 0.1,
              spreadRadius: 0.1,
            ),
          ],
        ),
        child: Icon(
          Icons.music_note,
          color: CustomColors.pinkColor,
          size: 30,
        ),
      );
    }
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "Hii " + Provider.of<User>(context).name + "!",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                "Are you sure you want to sign out? \n \nIf you will proceed with your action all your local songs will be erased.",
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
                          "Got it",
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () async {
                        await _model.logOut();
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
