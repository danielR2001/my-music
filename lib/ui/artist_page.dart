import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:myapp/modules/song.dart';

class PlayListPage extends StatelessWidget {
  String albumOrArtistOrPlaylist;
  String imagePath;
  List<Song> songs = new List(10);
  PlayListPage({Key key, this.albumOrArtistOrPlaylist, this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imagePath == "") {
      imagePath = "assets/images/default_playlist_pic.png";
    }
    songs[0] = new Song("Alone", "Alan Walker");
    songs[1] = new Song("Hello", "Adelle");
    songs[2] = new Song("Gasoloni", "Halsey");
    songs[3] = new Song("Him & I", "Halsey");
    songs[4] = new Song("Jubel", "Klingande");
    songs[5] = new Song("Hate Me", "Blue October");
    songs[6] = new Song("Save The World", "Swedish House Mafia");
    songs[7] = new Song("Years", "Alesso");
    songs[8] = new Song("Paradise", "Coldplay");
    songs[9] = new Song("Old Town Road", "Lil Nas X, Billy Ray Cyrus");

    return Scaffold(
      body: new Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Colors.pink[900],
              Colors.grey[850],
            ],
            begin: FractionalOffset.bottomRight,
            stops: [0.0, 1.0],
            end: FractionalOffset.topLeft,
          ),
        ),
        child: new CustomScrollView(
          slivers: <Widget>[
            new SliverAppBar(
              backgroundColor: Colors.grey[850],
              expandedHeight: 200,
              pinned: true,
              floating: false,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  albumOrArtistOrPlaylist,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                background: new Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            new SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    height: 70,
                    child: Column(
                      children: <Widget>[
                        new SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          width: 150,
                          height: 45,
                          child: new RaisedButton(
                            splashColor: Colors.deepOrange,
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0),
                            ),
                            color: Colors.deepOrangeAccent[700],
                            child: Text(
                              "Shuffle",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            elevation: 6.0,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            makeSliverList(songs)
          ],
        ),
      ),
    );
  }

  SliverList makeSliverList(List<Song> songs) {
    return new SliverList(
      delegate: new SliverChildListDelegate(
        new List.generate(
          songs.length,
          (int index) => new ListTile(
                title: new Text(
                  songs[index].songName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: new Text(
                  songs[index].artist,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    print(
                      songs[index].songName + "," + songs[index].artist,
                    );
                  },
                ),
              ),
        ),
      ),
    );
  }
}
