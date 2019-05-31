import 'package:flutter/material.dart';
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
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xE4000000),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(accentColor: Colors.grey),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
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
                expandedHeight: 300,
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
                      : Image.asset(
                          'assets/images/downloaded_image.jpg',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SliverList(
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
                            child: RaisedButton(
                              splashColor: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
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
                                audioPlayerManager.playSong(
                                    playlist.getSongs[0],
                                    playlist,
                                    PlaylistMode.loop);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: 150,
                            height: 45,
                            child: RaisedButton(
                              splashColor: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
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
                                var rnd = Random();
                                audioPlayerManager.playSong(
                                    playlist.getSongs[
                                        rnd.nextInt(playlist.getSongs.length)],
                                    playlist,
                                    PlaylistMode.shuffle);
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
    return SliverList(
      delegate: SliverChildListDelegate(
        List.generate(playlist.getSongs.length, (int index) {
          setSongImage(playlist.getSongs[index]);
          String title;
          String artist;
          if (playlist.getSongs[index].getTitle.length > 35) {
            int pos = playlist.getSongs[index].getTitle.lastIndexOf("", 35);
            if (pos < 20) {
              pos = 35;
            }
            title = playlist.getSongs[index].getTitle.substring(0, pos) + "...";
          } else {
            title = playlist.getSongs[index].getTitle;
          }
          if (playlist.getSongs[index].getArtist.length > 35) {
            int pos = playlist.getSongs[index].getArtist.lastIndexOf("", 35);
            if (pos < 25) {
              pos = 35;
            }
            artist =
                playlist.getSongs[index].getArtist.substring(0, pos) + "...";
          } else {
            artist = playlist.getSongs[index].getArtist;
          }
          return ListTile(
            onTap: () {
              audioPlayerManager.playSong(
                  playlist.getSongs[index], playlist, PlaylistMode.loop);
            },
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.black,
                  image:
                      DecorationImage(image: songImage, fit: BoxFit.contain)),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: audioPlayerManager.currentSong != null
                    ? audioPlayerManager.currentPlaylist == playlist
                        ? audioPlayerManager.currentSong.getSongId ==
                                playlist.getSongs[index].getSongId
                            ? Colors.pink
                            : Colors.white
                        : Colors.white
                    : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              artist,
              style: TextStyle(
                color: audioPlayerManager.currentSong != null
                    ? audioPlayerManager.currentPlaylist == playlist
                        ? audioPlayerManager.currentSong.getSongId ==
                                playlist.getSongs[index].getSongId
                            ? Colors.pink
                            : Colors.grey
                        : Colors.grey
                    : Colors.grey,
                fontSize: 12,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.more_vert,
                color: audioPlayerManager.currentSong != null
                    ? audioPlayerManager.currentPlaylist == playlist
                        ? audioPlayerManager.currentSong.getSongId ==
                                playlist.getSongs[index].getSongId
                            ? Colors.pink
                            : Colors.white
                        : Colors.white
                    : Colors.white,
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
      songImage = NetworkImage(
        song.getImageUrl,
      );
    } else {
      songImage = AssetImage('assets/images/default_song_pic.png');
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
