import 'package:flutter/material.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/models/playlist.dart';

class DiscoverPage extends StatelessWidget {
  DiscoverPage({this.onPush});
  final onPush;
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
                            fontSize: 40,
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
                                  onPush();
                                },
                              ),
                            ),
                          ),
                        ]),
                      ),
                      // Expanded(
                      //   child: ListView.builder(
                      //     itemCount: 6,
                      //     itemBuilder: (BuildContext context, int index) {
                      //       Padding padding = createGenres(index, context);
                      //       index++;
                      //       return padding;
                      //     },
                      //   ),
                      // ),
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

  GestureDetector drawGenreWidget(
    String imagePath,
    String iconPath,
    String genre,
    BuildContext context,
  ) {
    return GestureDetector(
      child: Column(
        children: <Widget>[
          Container(
              alignment: Alignment.center,
              width: 180.0,
              height: 120.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3), BlendMode.dstATop),
                  image: ExactAssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: Constants.lightGreyColor,
                  width: 0.5,
                ),
              ),
              child: Container(
                alignment: Alignment.center,
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: ExactAssetImage(iconPath),
                    fit: BoxFit.cover,
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              genre,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      //onTap: () => onPush(createMap(Playlist(genre))),
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
      playlistValues['imageUrl'] = "assets/images/downloaded_image.jpg";
    }
    return playlistValues;
  }
}
