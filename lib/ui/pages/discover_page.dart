import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/main.dart';
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

  _DiscoverPageState();
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
                    Constants.darkGreyColor,
                    Constants.pinkColor,
                  ],
                  begin: FractionalOffset.bottomRight,
                  stops: [0.7, 1.0],
                  end: FractionalOffset.topLeft,
                ),
              ),
              child: SafeArea(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    accentColor: Colors.grey,
                  ),
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
                      Expanded(
                        child: ListView.builder(
                          itemCount: publicPlaylists.length,
                          itemBuilder: (BuildContext context, int index) {
                            Padding row;
                            Expanded padding1;
                            Expanded padding2;
                            if ((index + 1) % 2 != 0) {
                              padding1 = drawPlaylists(
                                  publicPlaylists[index], context);
                              padding2 = index + 1 != publicPlaylists.length
                                  ? drawPlaylists(
                                      publicPlaylists[index + 1], context)
                                  : Expanded(child: Container());
                              row = Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
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
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future syncAllPublicPlaylists() async {
    await FirebaseDatabaseManager.buildPublicPlaylists();
    setState(() {
    });
  }

  Expanded drawPlaylists(Playlist playlist, BuildContext context) {
    String name = playlist.getName;
    if (playlist.getName.length > 15) {
      int pos = playlist.getName.lastIndexOf("", 15);
      if (pos < 5) {
        pos = 15;
      }
      name = playlist.getName.substring(0, pos) + "...";
    } else {
      name = playlist.getName;
    }
    return Expanded(
      child: GestureDetector(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                height: 180.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(1.0), BlendMode.dstATop),
                    image: playlist.getSongs.length > 0
                        ? NetworkImage(playlist.getSongs[0].getImageUrl)
                        : AssetImage(
                            "assets/images/default_playlist_image.jpg"),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: Constants.lightGreyColor,
                    width: 0.5,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              AutoSizeText(
                name,
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
    playlistValues['playlistCreator'] = User(playlist.getCreator, null, false);
    playlistValues['playlistModalSheetMode'] = PlaylistModalSheetMode.public;
    return playlistValues;
  }
}
