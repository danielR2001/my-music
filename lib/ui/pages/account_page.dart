import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:myapp/communicate_with_native/internet_connection_check.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/main.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/ui/pages/settings_page.dart';
import 'package:myapp/ui/widgets/playlist_options_modal_buttom_sheet.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  AccountPage({this.onPush});
  final ValueChanged<Map> onPush;

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool openPlaylists = true;
  Map<String, ImageProvider> imageProviders = Map();
  @override
  void initState() {
    super.initState();
    checkForIntenetConnetionForNetworkImage();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(onGenerateRoute: (RouteSettings settings) {
      return MaterialPageRoute(
        settings: settings,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GlobalVariables.darkGreyColor,
                  GlobalVariables.pinkColor,
                ],
                begin: FractionalOffset.bottomRight,
                stops: [0.7, 1.0],
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
                              Icons.settings,
                              size: 30,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                GlobalVariables.homePageContext,
                                MaterialPageRoute(
                                  builder: (context) => SettingsPage(),
                                ),
                              );
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
                        "Downloaded",
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
                        Provider.of<PageNotifier>(
                                    GlobalVariables.homePageContext)
                                .setCurrentPlaylistPagePlaylist =
                            currentUser.getDownloadedSongsPlaylist;
                        widget.onPush(
                            createMap(currentUser.getDownloadedSongsPlaylist));
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
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            )
                          : Icon(
                              Icons.keyboard_arrow_up,
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
          );
        },
      );
    });
  }

  Padding userPlaylists(Playlist playlist, BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 40,
        bottom: 10,
      ),
      child: ListTile(
          leading: playlist.getSongs.length > 0
              ? drawSongImage(playlist.getSongs[0], index)
              : drawSongImage(null, index),
          title: AutoSizeText(
            cutPlaylistName(playlist),
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
            Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                .setCurrentPlaylistPagePlaylist = playlist;
            widget.onPush(createMap(playlist));
          }),
    );
  }

  Map createMap(Playlist playlist) {
    Map<String, dynamic> playlistValues = Map();
    if (playlist.getSongs.length > 0) {
      playlistValues['playlist'] = playlist;
      playlistValues['imageUrl'] = playlist.getSongs[0].getImageUrl != ""
          ? playlist.getSongs[0].getImageUrl
          : "";
    } else {
      playlistValues['playlist'] = playlist;
      playlistValues['imageUrl'] = "";
    }
    playlistValues['playlistCreator'] = currentUser;
    playlistValues['playlistModalSheetMode'] =
        playlist.getPushId != currentUser.getDownloadedSongsPlaylist.getPushId
            ? PlaylistModalSheetMode.regular
            : PlaylistModalSheetMode.download;
    return playlistValues;
  }

  Widget showOrHidePlaylists() {
    if (openPlaylists) {
      return Expanded(
        child: Theme(
          data: Theme.of(context).copyWith(accentColor: Colors.grey),
          child: ListView.builder(
            itemCount: currentUser != null
                ? currentUser.getPlaylists != null
                    ? currentUser.getPlaylists.length
                    : 0
                : 0,
            itemBuilder: (BuildContext context, int index) {
              return userPlaylists(
                  currentUser.getPlaylists[index], context, index);
            },
          ),
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
              GlobalVariables.lightGreyColor,
              GlobalVariables.darkGreyColor,
            ],
            begin: FractionalOffset.bottomLeft,
            stops: [0.3, 0.8],
            end: FractionalOffset.topRight,
          ),
          // border: Border.all(
          //   color: Colors.black,
          //   width: 0.1,
          // ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey[850],
          //     blurRadius: 0.1,
          //     spreadRadius: 0.1,
          //   ),
          // ],
        ),
        child:
            imageProviders.length != 0 && imageProviders[song.getSongId] != null
                ? Image(
                    image: imageProviders[song.getSongId],
                    fit: BoxFit.contain,
                  )
                : Icon(
                    Icons.music_note,
                    color: GlobalVariables.pinkColor,
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
              GlobalVariables.lightGreyColor,
              GlobalVariables.darkGreyColor,
            ],
            begin: FractionalOffset.bottomLeft,
            stops: [0.3, 0.8],
            end: FractionalOffset.topRight,
          ),
          // border: Border.all(
          //   color: Colors.black,
          //   width: 0.1,
          // ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey[850],
          //     blurRadius: 0.1,
          //     spreadRadius: 0.1,
          //   ),
          // ],
        ),
        child: Icon(
          Icons.music_note,
          color: GlobalVariables.pinkColor,
          size: 30,
        ),
      );
    }
  }

  String cutPlaylistName(Playlist playlist) {
    String name;
    if (playlist.getName.length > 18) {
      int pos = playlist.getName.lastIndexOf("", 18);
      if (pos < 10) {
        pos = 18;
      }
      name = playlist.getName.substring(0, pos) + "...";
    } else {
      name = playlist.getName;
    }
    return name;
  }

  void checkForIntenetConnetionForNetworkImage() {
    InternetConnectionCheck.check().then((available) {
      currentUser.getPlaylists.forEach((playlist) {
        if (playlist.getSongs.length > 0) {
          ManageLocalSongs.checkIfFileExists(playlist.getSongs[0])
              .then((exists) {
            if (exists) {
              File file = File(
                  "${ManageLocalSongs.fullSongDownloadDir.path}/${playlist.getSongs[0].getSongId}/${playlist.getSongs[0].getSongId}.png");
              setState(() {
                imageProviders[playlist.getSongs[0].getSongId] =
                    (FileImage(file));
              });
            } else {
              if (available) {
                setState(() {
                  imageProviders[playlist.getSongs[0].getSongId] = NetworkImage(
                    playlist.getSongs[0].getImageUrl,
                  );
                });
              }
            }
          });
        } 
      });
    });
  }
}
