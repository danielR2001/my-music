import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:myapp/core/enums/page_state.dart';
import 'package:myapp/core/view_models/page_models/discover_model.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/pages/base_page.dart';
import 'package:provider/provider.dart';

class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  bool needToReloadImages = false;
  @override
  Widget build(BuildContext context) {
    return BasePage<DiscoverModel>(
      onModelReady: (model) => model.initModel(Provider.of<User>(context)),
      builder: (context, model, child) => Container(
        alignment: Alignment(0.0, 0.0),
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
                          Navigator.pushNamed(
                            context,
                            "/search",
                          );
                        },
                      ),
                    ),
                  ),
                ]),
              ),
              model.state == PageState.Idle
                  ? drawPublicPlaylistsListView(model)
                  : Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              CustomColors.pinkColor),
                          backgroundColor: Colors.pink[50],
                          strokeWidth: 5.0,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  //* widgets
  Widget drawPublicPlaylistsListView(DiscoverModel model) {
    return Expanded(
      child: ListView.builder(
        itemCount: model.publicPlaylists.length,
        itemBuilder: (BuildContext context, int index) {
          Padding row;
          Expanded padding1;
          Expanded padding2;
          if ((index + 1) % 2 != 0) {
            padding1 = drawPlaylists(model.publicPlaylists[index], context, model);
            padding2 = index + 1 != model.publicPlaylists.length
                ? drawPlaylists(model.publicPlaylists[index + 1], context, model)
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

  Widget drawPlaylists(Playlist playlist, BuildContext context, DiscoverModel model) {
    String title = playlist.name;
    if (playlist.name.length > 15) {
      int pos = playlist.name.lastIndexOf("", 15);
      if (pos < 5) {
        pos = 15;
      }
      title = playlist.name.substring(0, pos) + "...";
    } else {
      title = playlist.name;
    }
    if (model.imageProviders[playlist.publicPlaylistPushId] != null) {
      return drawPlaylist(playlist, model);
    } else {
      return drawDefaultPlaylist(playlist, title, model);
    }
  }

  Widget drawPlaylist(Playlist playlist, DiscoverModel model) {
    return Expanded(
      child: GestureDetector(
        child: Column(
          children: <Widget>[
            Container(
              height: 180.0,
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
                image: DecorationImage(
                  image: model.imageProviders[playlist.publicPlaylistPushId],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            AutoSizeText(
              playlist.name,
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
          Navigator.pushNamed(
            context,
            "/playlist",
            arguments: model.createMap(playlist),
          );
        },
      ),
    );
  }

  Widget drawDefaultPlaylist(Playlist playlist, String title, DiscoverModel model) {
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
          Navigator.pushNamed(
            context,
            "/playlist",
            arguments: model.createMap(playlist),
          );
        },
      ),
    );
  }
}
