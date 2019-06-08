import 'package:flutter/material.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/ui/pages/home_page.dart';
import 'package:myapp/ui/pages/music_player_page.dart';
import 'package:myapp/ui/widgets/playlist_options_modal_buttom_sheet.dart';
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
  final Playlist playlist;
  final String imagePath;
  _PlaylistPageState(this.playlist, this.imagePath);
  ImageProvider imageProvider;
  Color iconColor = Colors.white;
  ScrollController _scrollController;
  @override
  void initState() {
    // FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    //FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Constants.darkGreyColor,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(accentColor: Colors.grey),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverAppBar(
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      decoration: _scrollController.hasClients
                          ? _scrollController.offset > 300 - kToolbarHeight
                              ? BoxDecoration()
                              : BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Constants.lightGreyColor,
                                )
                          : BoxDecoration(
                              shape: BoxShape.circle,
                              color: Constants.lightGreyColor,
                            ),
                      child: IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: iconColor,
                        ),
                        iconSize: 30,
                        onPressed: () {
                          showPlaylistOptions(playlist);
                        },
                      ),
                    ),
                  ),
                ],
                leading: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    decoration: _scrollController.hasClients
                        ? _scrollController.offset > 300 - kToolbarHeight
                            ? BoxDecoration()
                            : BoxDecoration(
                                shape: BoxShape.circle,
                                color: Constants.lightGreyColor,
                              )
                        : BoxDecoration(
                            shape: BoxShape.circle,
                            color: Constants.lightGreyColor,
                          ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: iconColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                automaticallyImplyLeading: false,
                backgroundColor: _scrollController.hasClients
                    ? _scrollController.offset > 270 - kToolbarHeight
                        ? Constants.lightGreyColor
                        : Constants.darkGreyColor
                    : Constants.darkGreyColor,
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    playlist.getName,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: FractionalOffset.topCenter,
                        stops: [0, 1],
                        end: FractionalOffset.bottomCenter,
                        colors: [Constants.darkGreyColor, Colors.transparent],
                      ).createShader(
                          Rect.fromLTRB(0, 0, rect.width, rect.height));
                    },
                    blendMode: BlendMode.dstIn,
                    child: imagePath != ""
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
                              color: Constants.pinkColor,
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
                                audioPlayerManager.initSong(
                                  playlist.getSongs[0],
                                  playlist,
                                  PlaylistMode.loop,
                                );
                                FetchData.getSongPlayUrlDefault(
                                        playlist.getSongs[0])
                                    .then((streamUrl) {
                                  audioPlayerManager.playSong(
                                    streamUrl,
                                  );
                                });
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
                              color: Constants.pinkColor,
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
                                int randomNum =
                                    rnd.nextInt(playlist.getSongs.length);
                                audioPlayerManager.initSong(
                                  playlist.getSongs[randomNum],
                                  playlist,
                                  PlaylistMode.shuffle,
                                );
                                FetchData.getSongPlayUrlDefault(
                                        playlist.getSongs[randomNum])
                                    .then((streamUrl) {
                                  audioPlayerManager.playSong(
                                    streamUrl,
                                  );
                                });
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
          String title;
          String artist;
          if (playlist.getSongs[index].getTitle.length > 30) {
            int pos = playlist.getSongs[index].getTitle.lastIndexOf("", 30);
            if (pos < 20) {
              pos = 35;
            }
            title = playlist.getSongs[index].getTitle.substring(0, pos) + "...";
          } else {
            title = playlist.getSongs[index].getTitle;
          }
          if (playlist.getSongs[index].getArtist.length > 35) {
            int pos = playlist.getSongs[index].getArtist.lastIndexOf("", 35);
            if (pos < 20) {
              pos = 35;
            }
            artist =
                playlist.getSongs[index].getArtist.substring(0, pos) + "...";
          } else {
            artist = playlist.getSongs[index].getArtist;
          }
          return ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: Constants.lightGreyColor,
                  width: 0.5,
                ),
                image: DecorationImage(
                  image: playlist.getSongs[index].getImageUrl.length > 0
                      ? NetworkImage(
                          playlist.getSongs[index].getImageUrl,
                        )
                      : AssetImage('assets/images/default_song_pic.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: audioPlayerManager.currentSong != null &&
                        audioPlayerManager.currentPlaylist != null
                    ? audioPlayerManager.loopPlaylist.getName ==
                            playlist.getName
                        ? audioPlayerManager.currentSong.getSongId ==
                                playlist.getSongs[index].getSongId
                            ? Constants.pinkColor
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
                color: audioPlayerManager.currentSong != null &&
                        audioPlayerManager.currentPlaylist != null
                    ? audioPlayerManager.loopPlaylist.getName ==
                            playlist.getName
                        ? audioPlayerManager.currentSong.getSongId ==
                                playlist.getSongs[index].getSongId
                            ? Constants.pinkColor
                            : Colors.grey
                        : Colors.grey
                    : Colors.grey,
                fontSize: 12,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.more_vert,
                color: audioPlayerManager.currentSong != null &&
                        audioPlayerManager.currentPlaylist != null
                    ? audioPlayerManager.loopPlaylist.getName ==
                            playlist.getName
                        ? audioPlayerManager.currentSong.getSongId ==
                                playlist.getSongs[index].getSongId
                            ? Constants.pinkColor
                            : Colors.white
                        : Colors.white
                    : Colors.white,
              ),
              iconSize: 30,
              onPressed: () {
                setState(() {
                  showSongOptions(playlist.getSongs[index], playlist);
                });
              },
            ),
            onTap: () {
              if (audioPlayerManager.currentSong != null &&
                  audioPlayerManager.currentPlaylist != null) {
                if (audioPlayerManager.currentSong.getSongId ==
                        playlist.getSongs[index].getSongId &&
                    audioPlayerManager.currentPlaylist.getName ==
                        playlist.getName) {
                  Navigator.push(
                    homePageContext,
                    MaterialPageRoute(
                        builder: (homePageContext) => MusicPlayerPage()),
                  );
                } else {
                  audioPlayerManager.initSong(
                    playlist.getSongs[index],
                    playlist,
                    PlaylistMode.loop,
                  );
                  FetchData.getSongPlayUrlDefault(playlist.getSongs[index])
                      .then((streamUrl) {
                    audioPlayerManager.playSong(
                      streamUrl,
                    );
                  });
                }
              } else {
                audioPlayerManager.initSong(
                  playlist.getSongs[index],
                  playlist,
                  PlaylistMode.loop,
                );
                FetchData.getSongPlayUrlDefault(playlist.getSongs[index])
                    .then((streamUrl) {
                  audioPlayerManager.playSong(
                    streamUrl,
                  );
                });
              }
            },
          );
        }),
      ),
    );
  }

  void showSongOptions(Song song, Playlist currentPlaylist) {
    showModalBottomSheet(
      context: homePageContext,
      builder: (builder) {
        return SongOptionsModalSheet(
          song,
          currentPlaylist,
          false,
        );
      },
    );
  }

  void showPlaylistOptions(Playlist currentPlaylist) {
    showModalBottomSheet(
      context: homePageContext,
      builder: (builder) {
        return PlaylistOptionsModalSheet(
          currentPlaylist,
          context,
        );
      },
    );
  }
}
