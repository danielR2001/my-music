import 'package:flutter/material.dart';

class DiscoverPage extends StatelessWidget {
  DiscoverPage({this.onPush});
  final List<String> genres = [
    "R&B/Soul",
    "Rock",
    "Chill",
    "Classical",
    "Pop",
    "Rap",
    "Jazz",
    "Blues",
    "Electronic",
    "Hip Hop",
    "Country",
    "Dance/EDM"
  ];
  final List<String> genresUrls = [
    "assets/images/r&b.png",
    "assets/images/rock.png",
    "assets/images/chill.png",
    "assets/images/classical.png",
    "assets/images/pop.png",
    "assets/images/rap.png",
    "assets/images/jazz.png",
    "assets/images/blues.png",
    "assets/images/electronic.png",
    "assets/images/hip_hop.png",
    "assets/images/country.png",
    "assets/images/dance_edm.png",
  ];
  final List<String> genresIconUrls = [
    'assets/images/r&b-512.png',
    'assets/images/rock-512.png',
    'assets/images/chill-512.png',
    'assets/images/classic-512.png',
    'assets/images/pop-512.png',
    'assets/images/rap-512.png',
    'assets/images/jazz-512.png',
    'assets/images/blues-512.png',
    'assets/images/electronic-512.png',
    'assets/images/hip-hop-512.png',
    'assets/images/country-512.png',
    'assets/images/dance_edm-512.png',
  ];
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
              decoration:  BoxDecoration(
                gradient:  LinearGradient(
                  colors: [
                    Color(0xEA000000),
                    Colors.pink,
                  ],
                  begin: FractionalOffset.bottomRight,
                  stops: [0.7, 1.0],
                  end: FractionalOffset.topLeft,
                ),
              ),
              child: SafeArea(
                child: Theme(
                  data: Theme.of(context).copyWith(accentColor: Colors.grey),
                  child:  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                          bottom: 10,
                        ),
                        child:  Text(
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
                              //width: 196,
                              child:  RaisedButton(
                                shape:  RoundedRectangleBorder(
                                  borderRadius:  BorderRadius.circular(8.0),
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
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => SearchPage(),
                                  //   ),
                                  // );
                                  onPush();
                                },
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Expanded(
                        child:  ListView.builder(
                          itemCount: 6,
                          itemBuilder: (BuildContext context, int index) {
                            Padding padding = createGenres(index, context);
                            index++;
                            return padding;
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
                    colorFilter:  ColorFilter.mode(
                        Colors.black.withOpacity(0.2), BlendMode.dstATop),
                    image: ExactAssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: Colors.black,
                    width: 0.2,
                  ),
                ),
                child:  Container(
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
              child:  Text(
                genre,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
        onTap: () => {});
  }

  Padding createGenres(int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            child: drawGenreWidget(
              genresUrls[index * 2],
              genresIconUrls[index * 2],
              genres[index * 2],
              context,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            child: drawGenreWidget(
              genresUrls[index * 2 + 1],
              genresIconUrls[index * 2 + 1],
              genres[index * 2 + 1],
              context,
            ),
          ),
        ],
      ),
    );
  }
}
