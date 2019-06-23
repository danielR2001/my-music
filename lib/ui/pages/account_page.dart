import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/ui/pages/home_page.dart';
import 'package:myapp/ui/pages/settings_page.dart';
import 'package:myapp/ui/widgets/playlist_options_modal_buttom_sheet.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  AccountPage({this.onPush});
  final ValueChanged<Map> onPush;

  @override
  _AccountPageState createState() => _AccountPageState();
}

BuildContext accountPageContext;

class _AccountPageState extends State<AccountPage> {
  bool openPlaylists = true;
  @override
  Widget build(BuildContext context) {
    accountPageContext = context;
    return Navigator(onGenerateRoute: (RouteSettings settings) {
      return MaterialPageRoute(
        settings: settings,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Constants.darkGreyColor,
                  Constants.pinkColor,
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
                                homePageContext,
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
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.white,
                      ),
                      onTap: () {
                        Provider.of<PageNotifier>(context)
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
                        fontSize: 18,
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

  Padding userPlaylists(Playlist playlist, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 40,
        bottom: 10,
      ),
      child: ListTile(
          leading: playlist.getSongs.length > 0
              ? playlist.getSongs[0].getImageUrl.length > 0
                  ? drawSongImage(playlist.getSongs[0])
                  : drawDefaultSongImage()
              : drawDefaultSongImage(),
          title: AutoSizeText(
            cutPlaylistName(playlist),
            style: TextStyle(
              fontSize: 18,
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
            Provider.of<PageNotifier>(context).setCurrentPlaylistPagePlaylist =
                playlist;
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
              return userPlaylists(currentUser.getPlaylists[index], context);
            },
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget drawSongImage(Song song) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Constants.lightGreyColor,
        shape: BoxShape.rectangle,
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
          color: Constants.lightGreyColor,
          width: 0.4,
        ),
      ),
      child: Icon(
        Icons.music_note,
        color: Constants.pinkColor,
        size: 40,
      ),
    );
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
}
