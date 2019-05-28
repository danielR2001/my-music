import 'package:flutter/material.dart';
//import 'package:myapp/manage_local_songs/manage_local_songs.dart';
import 'package:myapp/models/playlist.dart';
import 'dart:ui';
import 'package:myapp/main.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/ui/pages/home_page.dart';
import 'package:myapp/ui/widgets/song_options_modal_buttom_sheet.dart';
import 'dart:math';

class PlaylistPage extends StatefulWidget {
  final Playlist playlist;
  final String imagePath;

  PlaylistPage({this.playlist, this.imagePath});

  @override
  _PlaylistPageState createState() => _PlaylistPageState(playlist, imagePath);
}

class _PlaylistPageState extends State<PlaylistPage> {
  ImageProvider songImage;
  final Playlist playlist;
  final String imagePath;
  _PlaylistPageState(this.playlist, this.imagePath);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Navigator.pop(context);
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
                    ),
                  ),
                  background: imagePath != ""
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                        )
                      : Image.asset('assets/images/default_song_pic_small.png',
                          fit: BoxFit.none,),
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
                                audioPlayerManager.playSong(playlist.getSongs[0],playlist: playlist,playlistMode: PlaylistMode.loop);
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
                                audioPlayerManager.playSong(playlist.getSongs[
                                    rnd.nextInt(playlist.getSongs.length)],playlist: playlist,playlistMode: PlaylistMode.shuffle);
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
    );
  }

  SliverList makeSliverList(Playlist playlist, BuildContext context) {
    return new SliverList(
      delegate: new SliverChildListDelegate(
        new List.generate(playlist.getSongs.length, (int index) {
          setSongImage(playlist.getSongs[index]);
          String title;
          String artist;
          if (playlist.getSongs[index].getTitle.length > 20) {
            int pos = playlist.getSongs[index].getTitle.lastIndexOf("", 20);
            if (pos < 15) {
              pos = 20;
            }
            title = playlist.getSongs[index].getTitle.substring(0, pos) + "...";
          } else {
            title = playlist.getSongs[index].getTitle;
          } //TODO exact cut
          if (playlist.getSongs[index].getArtist.length > 40) {
            int pos =
                playlist.getSongs[index].getArtist.lastIndexOf("", 40);
            if (pos < 30) {
              pos = 40;
            }
            artist =
                playlist.getSongs[index].getArtist.substring(0, pos) +
                    "...";
          } else {
            artist = playlist.getSongs[index].getArtist;
          }
          return new ListTile(
            onTap: () {
              audioPlayerManager.playSong(playlist.getSongs[index],playlist: playlist,playlistMode: PlaylistMode.loop);
            },
            leading: new Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black,
                  image: DecorationImage(
                image: songImage,
                fit: BoxFit.contain
              )),
            ),
            title: new Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
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
                  showMoreOptions(playlist.getSongs[index], playlist);
                });
              },
            ),
          );
        }),
      ),
    );
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

  void showMoreOptions(Song song, Playlist currentPlaylist) {
    showModalBottomSheet(
      context: homePageContext,
      builder: (builder) {
        return SongOptionsModalSheet(song, currentPlaylist);
      },
    );
  }
}
