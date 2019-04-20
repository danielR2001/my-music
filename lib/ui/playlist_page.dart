import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:myapp/models/song.dart';
import 'package:myapp/main.dart';
import 'music_player_page.dart';
import 'dart:math';

class PlayListPage extends StatelessWidget {
  String albumOrArtistOrPlaylist;
  String imagePath;
  List<Song> songs = new List(0);

  PlayListPage({Key key, this.albumOrArtistOrPlaylist, this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imagePath == "") {
      imagePath = "assets/images/default_playlist_pic.png";
    }

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
                            onPressed: () {
                              var rnd = new Random();
                              MyApp.songStatus.currentSong =
                                  songs[rnd.nextInt(songs.length)];
                              playSongAndGoToMusicPlayer(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            makeSliverList(songs, context)
          ],
        ),
      ),
    );
  }

  SliverList makeSliverList(List<Song> songs, BuildContext context) {
    return new SliverList(
      delegate: new SliverChildListDelegate(
        new List.generate(
          songs.length,
          (int index) => new ListTile(
                onTap: () {
                  MyApp.songStatus.currentSong = songs[index];
                  MyApp.songStatus.playSong();
                  playSongAndGoToMusicPlayer(context);
                },
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
                      songs[index].songName +
                          "," +
                          songs[index].artist +
                          " Menu Opened",
                    );
                  },
                ),
              ),
        ),
      ),
    );
  }

  void playSongAndGoToMusicPlayer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerPage(),
      ),
    );
  }
}
