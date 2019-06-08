import 'package:flutter/material.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/ui/pages/home_page.dart';
import 'package:myapp/ui/pages/settings_page.dart';

class AccountPage extends StatefulWidget {
  AccountPage({this.onPush});
  final ValueChanged<Map> onPush;

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // int playlistLength =
  //    currentUser.getMyPlaylists != null ? currentUser.getMyPlaylists.length : 0;
  bool openPlaylists = true;
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
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.white,
                    ),
                    onTap: () =>
                        widget.onPush(createMap(Playlist("Downloaded"))),
                  ),
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
                        fontSize: 20,
                        color: Colors.white,
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
        leading: Container(
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.rectangle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: playlist.getSongs.length>0
                  ? playlist.getSongs[0].getImageUrl != ""
                      ? NetworkImage(
                          playlist.getSongs[0].getImageUrl,
                        )
                      : AssetImage('assets/images/default_song_pic.png')
                  : AssetImage('assets/images/default_song_pic.png'),
            ),
          ),
        ),
        title: Text(
          playlist.getName,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          color: Colors.white,
        ),
        onTap: () => widget.onPush(createMap(playlist)),
      ),
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
    return playlistValues;
  }

  Widget showOrHidePlaylists() {
    if (openPlaylists) {
      return Expanded(
        child: Theme(
          data: Theme.of(context).copyWith(accentColor: Colors.grey),
          child: ListView.builder(
            itemCount: currentUser.getMyPlaylists != null
                ? currentUser.getMyPlaylists.length
                : 0,
            itemBuilder: (BuildContext context, int index) {
              return userPlaylists(currentUser.getMyPlaylists[index], context);
            },
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
