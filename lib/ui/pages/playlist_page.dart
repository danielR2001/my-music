import 'package:flutter/material.dart';
import 'package:myapp/ui/decorations/page_slide.dart';
import 'package:myapp/models/playlist.dart';
import 'dart:ui';
import 'package:myapp/main.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/playing_now/playing_now.dart';
import 'home_page.dart';
import 'package:myapp/ui/widgets/song_options_modal_buttom_sheet.dart';
import 'music_player_page.dart';
import 'dart:math';

class PlayListPage extends StatefulWidget {
  final Playlist playlist;
  final String imagePath;

  PlayListPage({Key key, this.playlist, this.imagePath}) : super(key: key);

  @override
  _PlayListPageState createState() => _PlayListPageState(playlist, imagePath);
}

class _PlayListPageState extends State<PlayListPage> {
  ImageProvider songImage;
  final Playlist playlist;
  final String imagePath;
  _PlayListPageState(this.playlist, this.imagePath);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleBackButton,
      child: Scaffold(
        body: new Container(
          decoration: new BoxDecoration(
            color: Color(0xE4000000),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(accentColor: Colors.grey),
            child: new CustomScrollView(
              slivers: <Widget>[
                new SliverAppBar(
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        new MyCustomRoute(
                          builder: (context) => new HomePage(1),
                        ),
                      );
                    },
                  ),
                  automaticallyImplyLeading: false,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 150,
                              height: 45,
                              child: new RaisedButton(
                                splashColor: Colors.deepOrange,
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                                color: Colors.pink,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        "Play",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                elevation: 6.0,
                                onPressed: () {
                                  playingNow.currentPlaylist = playlist;
                                  playingNow.playlistMode = PlaylistMode.loop;
                                  playingNow.playSong(playlist.getSongs[0]);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MusicPlayerPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            new SizedBox(
                              width: 20,
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Icon(
                                        Icons.shuffle,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Shuffle",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                elevation: 6.0,
                                onPressed: () {
                                  var rnd = new Random();
                                  playingNow.currentPlaylist = playlist;
                                  playingNow.playlistMode =
                                      PlaylistMode.shuffle;
                                  playingNow.playSong(playlist.getSongs[
                                      rnd.nextInt(playlist.getSongs.length)]);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MusicPlayerPage(),
                                    ),
                                  );
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
        ),
      ),
    );
  }

  SliverList makeSliverList(Playlist playlist, BuildContext context) {
    return new SliverList(
      delegate: new SliverChildListDelegate(
        new List.generate(playlist.getSongs.length, (int index) {
          setSongImage(playlist.getSongs[index]);
          String title;
          String artist;
          if (playlist.getSongs[index].getSongName.length > 20) {
            int pos = playlist.getSongs[index].getSongName.lastIndexOf("", 20);
            if (pos < 15) {
              pos = 20;
            }
            title =
                playlist.getSongs[index].getSongName.substring(0, pos) + "...";
          } else {
            title = playlist.getSongs[index].getSongName;
          } //TODO exact cut
          if (playlist.getSongs[index].getArtist.length > 40) {
            int pos = playlist.getSongs[index].getArtist.lastIndexOf("", 40);
            if (pos < 30) {
              pos = 40;
            }
            artist =
                playlist.getSongs[index].getArtist.substring(0, pos) + "...";
          } else {
            artist = playlist.getSongs[index].getArtist;
          }
          return new ListTile(
            onTap: () {
              playingNow.currentPlaylist = playlist;
              playingNow.playlistMode = PlaylistMode.loop;
              playingNow.playSong(playlist.getSongs[index]);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MusicPlayerPage(),
                ),
              );
            },
            leading: new Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: songImage,
              )),
            ),
            title: new Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: new Text(
              artist,
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
                setState(() {
                  showMoreOptions(context, playlist.getSongs[index]);
                });
              },
            ),
          );
        }),
      ),
    );
  }

  Future<bool> handleBackButton() {
    return Navigator.pushReplacement(
          context,
          new MyCustomRoute(
            builder: (context) => new HomePage(1),
          ),
        ) ??
        false;
  }

  void setSongImage(Song song) {
    if (song.getImageUrl.length > 0) {
      songImage = new NetworkImage(
        song.getImageUrl,
      );
    } else {
      songImage = new AssetImage('assets/images/default_song_pic.png');
    }
  }

  void showMoreOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return SongOptionsModalSheet(song, playlist);
      },
    );
  }
}
