import 'package:flutter/material.dart';
import 'package:myapp/models/playlist.dart';
import 'dart:ui';
import 'package:myapp/models/song.dart';
import 'package:myapp/main.dart';
import 'music_player_page.dart';
import 'dart:math';

class PlayListPage extends StatelessWidget {
  final Playlist playlist;
  final String imagePath;
  PlayListPage({Key key, this.playlist, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        decoration: new BoxDecoration(
          color: Color(0xE4000000),
          // gradient: new LinearGradient(
          //   colors: [
          //     Color(0xE4000000),
          //     Colors.pink,
          //   ],
          //   begin: FractionalOffset.bottomCenter,
          //   stops: [0.5, 1.0],
          //   end: FractionalOffset.topCenter,
          // ),
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
                  playlist.getName,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
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
                background: new Image.network(
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
                            color: Colors.pink,
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
                              playingNow.currentSong = playlist.getSongs[
                                  rnd.nextInt(playlist.getSongs.length)];
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
            makeSliverList(playlist, context)
          ],
        ),
      ),
    );
  }

  SliverList makeSliverList(Playlist playlist, BuildContext context) {
    return new SliverList(
      delegate: new SliverChildListDelegate(
        new List.generate(
          playlist.getSongs.length,
          (int index) => new ListTile(
                onTap: () {
                  playingNow.playSong(playlist.getSongs[index]);
                  playSongAndGoToMusicPlayer(context);
                },
                title: new Text(
                  playlist.getSongs[index].getSongName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: new Text(
                  playlist.getSongs[index].getArtist,
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
                  onPressed: () {},
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
