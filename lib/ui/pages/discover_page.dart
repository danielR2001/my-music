import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:myapp/database/database_manager.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/widgets/playlist_options_modal_buttom_sheet.dart';

class DiscoverPage extends StatefulWidget {
  DiscoverPage({this.onPush});
  final onPush;

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  Map<String, ImageProvider> imageProviders = Map();
  bool needToReloadImages = false;
  @override
  void initState() {
    syncAllPublicPlaylists();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return Container(
              alignment: Alignment(0.0, 0.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GlobalVariables.darkGreyColor,
                    GlobalVariables.lightGreyColor,
                    GlobalVariables.pinkColor,
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
                      padding: const EdgeInsets.only(
                        top: 20,
                        bottom: 10,
                      ),
                      child: Text(
                        "Search",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 8.0,
                        left: 8.0,
                        bottom: 5,
                      ),
                      child: Row(children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 50,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              splashColor: Colors.transparent,
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.search,
                                    color: Colors.grey[700],
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Search artists or songs",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              elevation: 6.0,
                              onPressed: () {
                                widget.onPush();
                              },
                            ),
                          ),
                        ),
                      ]),
                    ),
                    drawPublicPlaylistsListView()
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  //* widgets
  Widget drawPublicPlaylistsListView() {
    if (!GlobalVariables.isOfflineMode && needToReloadImages) {
      checkForIntenetConnetionForNetworkImage();
      needToReloadImages = false;
    }
    return Expanded(
      child: ListView.builder(
        itemCount: GlobalVariables.publicPlaylists.length,
        itemBuilder: (BuildContext context, int index) {
          Padding row;
          Expanded padding1;
          Expanded padding2;
          if ((index + 1) % 2 != 0) {
            padding1 =
                drawPlaylists(GlobalVariables.publicPlaylists[index], context);
            padding2 = index + 1 != GlobalVariables.publicPlaylists.length
                ? drawPlaylists(
                    GlobalVariables.publicPlaylists[index + 1], context)
                : Expanded(child: Container());
            row = Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  children: <Widget>[
                    padding1,
                    SizedBox(
                      width: 20,
                    ),
                    padding2
                  ],
                ));
            return row;
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget drawPlaylists(Playlist playlist, BuildContext context) {
    String title = playlist.name;
    bool drawSongImage = false;
    if (playlist.name.length > 15) {
      int pos = playlist.name.lastIndexOf("", 15);
      if (pos < 5) {
        pos = 15;
      }
      title = playlist.name.substring(0, pos) + "...";
    } else {
      title = playlist.name;
    }
    if (playlist.songs.length > 0) {
      if (imageProviders.length != 0 &&
          imageProviders[playlist.songs[0].songId] != null) {
        drawSongImage = true;
      }
    }
    if (drawSongImage) {
      return drawPlaylist( playlist,  title);
    } else {
      return drawDefaultPlaylist(playlist,title);
    }
  }

  Widget drawPlaylist(Playlist playlist, String title){
    return Expanded(
        child: GestureDetector(
            child: Column(
              children: <Widget>[
                Container(
                  height: 180.0,
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
                    image: DecorationImage(
                      image: imageProviders[playlist.songs[0].songId],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                AutoSizeText(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
            onTap: () {
              widget.onPush(playlistValues: createMap(playlist));
            },),
      );
  }

  Widget drawDefaultPlaylist(Playlist playlist, String title){
    return Expanded(
        child: GestureDetector(
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  height: 180.0,
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
                    color: GlobalVariables.pinkColor,
                    size: 75,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                AutoSizeText(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
            onTap: () {
              widget.onPush(playlistValues: createMap(playlist));
            },),
      );
  }
  
  //* methods
  Future syncAllPublicPlaylists() async {
    await FirebaseDatabaseManager.buildPublicPlaylists();
    checkForIntenetConnetionForNetworkImage();
  }

  Map createMap(Playlist playlist) {
    Map<String, dynamic> playlistValues = Map();
    if (playlist.songs.length > 0) {
      playlistValues['playlist'] = playlist;
    } else {
      playlistValues['playlist'] = playlist;
    }
    playlistValues['playlistCreator'] = User(playlist.creator, null);
    playlistValues['playlistModalSheetMode'] = PlaylistModalSheetMode.public;
    return playlistValues;
  }
  //! TODO remove this method
  void checkForIntenetConnetionForNetworkImage() {
    if (!GlobalVariables.isOfflineMode) {
      GlobalVariables.publicPlaylists.forEach((playlist) {
        if (playlist.songs.length > 0) {
          GlobalVariables.manageLocalSongs
              .checkIfImageFileExists(playlist.songs[0])
              .then((exists) {
            if (exists) {
              File file = File(
                  "${GlobalVariables.manageLocalSongs.fullSongDownloadDir.path}/${playlist.songs[0].songId}/${playlist.songs[0].songId}.png");
              setState(() {
                imageProviders[playlist.songs[0].songId] = (FileImage(file));
              });
            } else {
              if (GlobalVariables.isNetworkAvailable) {
                setState(() {
                  imageProviders[playlist.songs[0].songId] = NetworkImage(
                    playlist.songs[0].imageUrl,
                  );
                });
              }
            }
          });
        }
      });
    } else {
      needToReloadImages = true;
    }
  }
}
