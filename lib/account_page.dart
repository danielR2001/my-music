import 'package:flutter/material.dart';
import 'playlist.dart';
import 'playlist_page.dart';

class AccountPage extends StatelessWidget {
  final Playlist playlist = new Playlist("My First Playlist");
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Color(0xE4000000),
              Colors.pink[900],
            ],
            begin: FractionalOffset.bottomRight,
            stops: [0.7, 1.0],
            end: FractionalOffset.topLeft,
          ),
        ),
        child: new ListView(
          children: <Widget>[
            new ListTile(
              trailing: new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Icon(
                    Icons.notifications,
                    size: 30,
                    color: Colors.grey,
                  ),
                  new SizedBox(
                    width: 25,
                  ),
                  new Icon(
                    Icons.settings,
                    size: 30,
                    color: Colors.grey,
                  )
                ],
              ),
            ),
            createSpace(15),
            new ListTile(
              leading: new Container(
                width: 30.0,
                height: 30.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: ExactAssetImage(
                      "assets/images/profile_pic.png",
                    ),
                  ),
                ),
              ),
              title: Text(
                "Daniel Rachlin",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                "View Your Profile",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
              ),
            ),
            createSpace(50),
            new ListTile(
              leading: Icon(
                Icons.file_download,
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
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayListPage(
                            albumOrArtistOrPlaylist: "Favorites",
                            imagePath: "",
                          ),
                    ));
              },
            ),
            createSpace(25),
            new ListTile(
              leading: Icon(
                Icons.favorite_border,
                color: Colors.white,
                size: 30,
              ),
              title: Text(
                "Favourites",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayListPage(
                            albumOrArtistOrPlaylist: "Favorites",
                            imagePath: "",
                          ),
                    ));
              },
            ),
            createSpace(25),
            new ListTile(
              leading: Icon(
                Icons.library_music,
                color: Colors.white,
                size: 30,
              ),
              title: Text(
                "Playlists",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              trailing: Icon(
                Icons.add_circle_outline,
                color: Colors.white,
              ),
              onTap: () {},
            ),
            createSpace(25),
            createPlaylistTile(playlist, context),
          ],
        ),
      ),
    );
  }

  SizedBox createSpace(double space) {
    return new SizedBox(
      height: space,
    );
  }

  Padding createPlaylistTile(Playlist playlist, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 40,
      ),
      child: new ListTile(
        leading: new Container(
          width: 70.0,
          height: 70.0,
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              new BoxShadow(
                color: Colors.black,
                blurRadius: 20.0,
              ),
            ],
            image: new DecorationImage(
              fit: BoxFit.fill,
              image: ExactAssetImage(
                "assets/images/music_player_pic.png",
              ),
            ),
          ),
        ),
        title: Text(
          playlist.getName(),
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          color: Colors.white,
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayListPage(
                      albumOrArtistOrPlaylist: playlist.getName(),
                      imagePath: "",
                    ),
              ));
        },
      ),
    );
  }
}
