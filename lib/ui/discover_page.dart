import 'package:flutter/material.dart';
import 'playlist_page.dart';
import 'search_page.dart';

class DiscoverPage extends StatelessWidget {
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
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        alignment: Alignment(0.0, 0.0),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Color(0xE4000000),
              Colors.pink,
            ],
            begin: FractionalOffset.bottomRight,
            stops: [0.7, 1.0],
            end: FractionalOffset.topLeft,
          ),
        ),
        child: new ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 10,
              ),
              child: new Text(
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
                right: 15.0,
                left: 15.0,
                bottom: 30.0,
              ),
              child: Container(
                width: 150,
                height: 45,
                child: new RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  ),
                  splashColor: Colors.transparent,
                  color: Colors.white,
                  child: Text(
                    "Artists, songs or albums",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  elevation: 6.0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 20,
                left: 10,
              ),
              child: new Text(
                "Top Genres:",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            createGenres(0, context),
            new SizedBox(
              height: 10.0,
            ),
            createGenres(2, context),
            new SizedBox(
              height: 10.0,
            ),
            createGenres(4, context),
            new SizedBox(
              height: 10.0,
            ),
            createGenres(6, context),
            new SizedBox(
              height: 10.0,
            ),
            createGenres(8, context),
            new SizedBox(
              height: 10.0,
            ),
            createGenres(10, context),
            new SizedBox(
              height: 70.0,
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector drawGenreWidget(
    String imagePath,
    String genre,
    BuildContext context,
  ) {
    return GestureDetector(
        child: new Container(
          alignment: Alignment.center,
          width: 180.0,
          height: 150.0,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(30.0),
            image: DecorationImage(
              colorFilter: new ColorFilter.mode(
                  Colors.white.withOpacity(0.6), BlendMode.dstATop),
              image: ExactAssetImage(imagePath),
              fit: BoxFit.cover,
            ),
            border: Border.all(
              color: Colors.grey[400],
            ),
          ),
          child: new Text(
            genre,
            style: TextStyle(
              color: Colors.white,
              shadows: [
                Shadow(
                    // bottomLeft
                    offset: Offset(-1.0, -1.0),
                    color: Colors.black),
                Shadow(
                    // bottomRight
                    offset: Offset(1.0, -1.0),
                    color: Colors.black),
                Shadow(
                    // topRight
                    offset: Offset(1.0, 1.0),
                    color: Colors.black),
                Shadow(
                    // topLeft
                    offset: Offset(-1.0, 1.0),
                    color: Colors.black),
              ],
              fontSize: 32.0,
            ),
          ),
        ),
        onTap: () => {}
        //  Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => PlayListPage(
        //               playlist: genre,
        //               imagePath: imagePath,
        //             ),
        //       ),
        //     ),
        );
  }

  Row createGenres(int index, BuildContext context) {
    return new Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: drawGenreWidget(
            genresUrls[index],
            genres[index],
            context,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: drawGenreWidget(
            genresUrls[index + 1],
            genres[index + 1],
            context,
          ),
        ),
      ],
    );
  }
}
