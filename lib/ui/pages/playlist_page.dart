import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/ui/decorations/my_custom_icons.dart';
import 'package:myapp/ui/pages/music_player_page.dart';
import 'package:myapp/ui/widgets/playlist_options_modal_buttom_sheet.dart';
import 'package:myapp/ui/widgets/song_options_modal_buttom_sheet.dart';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';

class PlaylistPage extends StatefulWidget {
  final Playlist playlist;
  final User playlistCreator;
  final PlaylistModalSheetMode playlistModalSheetMode;
  PlaylistPage(
      {this.playlist, this.playlistCreator, this.playlistModalSheetMode});

  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  ImageProvider imageProvider;
  Color iconColor = Colors.white;
  ScrollController _scrollController;
  @override
  void initState() {
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    checkForIntenetConnetionForNetworkImage();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: GlobalVariables.darkGreyColor,
        ),
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
                                color: GlobalVariables.lightGreyColor,
                              )
                        : BoxDecoration(
                            shape: BoxShape.circle,
                            color: GlobalVariables.lightGreyColor,
                          ),
                    child: IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: iconColor,
                      ),
                      iconSize: 30,
                      onPressed: () {
                        showPlaylistOptions(widget.playlist);
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
                              color: GlobalVariables.lightGreyColor,
                            )
                      : BoxDecoration(
                          shape: BoxShape.circle,
                          color: GlobalVariables.lightGreyColor,
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
                      ? GlobalVariables.lightGreyColor
                      : GlobalVariables.darkGreyColor
                  : GlobalVariables.darkGreyColor,
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.only(),
                title: Container(
                  height: 50,
                  width: 200,
                  child: Column(
                    children: <Widget>[
                      AutoSizeText(
                        widget.playlist.getName,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      AutoSizeText(
                        currentUser != null
                            ? widget.playlistModalSheetMode !=
                                    PlaylistModalSheetMode.download
                                ? "by: " + widget.playlistCreator.getName
                                : ""
                            : "",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                background: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: FractionalOffset.topCenter,
                      stops: [0, 1],
                      end: FractionalOffset.bottomCenter,
                      colors: [
                        GlobalVariables.darkGreyColor,
                        Colors.transparent
                      ],
                    ).createShader(
                        Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: imageProvider != null
                      ? Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.music_note,
                          color: GlobalVariables.pinkColor,
                          size: 75,
                        ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  drawPlaylistButtons(),
                ],
              ),
            ),
            makeSliverList(
                widget.playlistModalSheetMode == PlaylistModalSheetMode.public
                    ? widget.playlist
                    : Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                                .currentPlaylistPagePlaylist
                                .getPushId ==
                            widget.playlist.getPushId
                        ? Provider.of<PageNotifier>(
                                GlobalVariables.homePageContext)
                            .currentPlaylistPagePlaylist
                        : widget.playlist,
                context)
          ],
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
          if (playlist.getSongs[index].getTitle.length > 35) {
            int pos = playlist.getSongs[index].getTitle.lastIndexOf("", 35);
            if (pos < 25) {
              pos = 35;
            }
            title = playlist.getSongs[index].getTitle.substring(0, pos) + "...";
          } else {
            title = playlist.getSongs[index].getTitle;
          }
          if (playlist.getSongs[index].getArtist.length > 36) {
            int pos = playlist.getSongs[index].getArtist.lastIndexOf("", 36);
            if (pos < 26) {
              pos = 36;
            }
            artist =
                playlist.getSongs[index].getArtist.substring(0, pos) + "...";
          } else {
            artist = playlist.getSongs[index].getArtist;
          }
          return ListTile(
            contentPadding: EdgeInsets.only(left: 20, right: 4),
            title: Text(
              title,
              style: TextStyle(
                color: setSongColor(playlist, playlist.getSongs[index], true),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              artist,
              style: TextStyle(
                color: setSongColor(playlist, playlist.getSongs[index], false),
                fontSize: 13,
              ),
            ),
            trailing:
                ManageLocalSongs.isSongDownloading(playlist.getSongs[index]) &&
                        widget.playlistModalSheetMode !=
                            PlaylistModalSheetMode.public
                    ? Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          child: CircularProgressIndicator(
                            value: Provider.of<PageNotifier>(
                                        GlobalVariables.homePageContext)
                                    .downloadedProgresses[
                                        playlist.getSongs[index].getSongId]
                                    .toDouble() /
                                Provider.of<PageNotifier>(
                                        GlobalVariables.homePageContext)
                                    .downloadedTotals[
                                        playlist.getSongs[index].getSongId]
                                    .toDouble(),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                GlobalVariables.pinkColor),
                            backgroundColor: Colors.pink[50],
                            strokeWidth: 4.0,
                          ),
                          onTap: () {},
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: setSongColor(
                              playlist, playlist.getSongs[index], true),
                        ),
                        iconSize: 30,
                        onPressed: () {
                          setState(() {
                            showSongOptions(playlist.getSongs[index], playlist);
                          });
                        },
                      ),
            onTap: () {
              String playlistPushId;
              bool openMusicPlayer = false;
              if (audioPlayerManager.currentSong != null &&
                  audioPlayerManager.currentPlaylist != null) {
                if (audioPlayerManager.currentPlaylist.getPushId != null) {
                  playlistPushId = audioPlayerManager.currentPlaylist.getPushId;
                } else {
                  playlistPushId = audioPlayerManager
                      .currentPlaylist.getPublicPlaylistPushId;
                }

                if (playlist.getPushId != null) {
                  if (playlist.getPushId == playlistPushId) {
                    if (audioPlayerManager.currentSong.getSongId ==
                        playlist.getSongs[index].getSongId) {
                      openMusicPlayer = true;
                    }
                  }
                } else {
                  if (playlist.getPublicPlaylistPushId == playlistPushId) {
                    if (audioPlayerManager.currentSong.getSongId ==
                        playlist.getSongs[index].getSongId) {
                      openMusicPlayer = true;
                    }
                  }
                }
              }
              if (audioPlayerManager.isLoaded) {
                if (openMusicPlayer) {
                  Navigator.push(
                    GlobalVariables.homePageContext,
                    MaterialPageRoute(builder: (context) => MusicPlayerPage()),
                  );
                } else {
                  audioPlayerManager.initSong(
                    song: playlist.getSongs[index],
                    playlist: playlist,
                    playlistMode: PlaylistMode.loop,
                  );
                }
              }
            },
          );
        }),
      ),
    );
  }

  Color setSongColor(Playlist playlist, Song song, bool returnWhite) {
    String playlistPushId;
    if (audioPlayerManager.currentSong != null &&
        audioPlayerManager.currentPlaylist != null) {
      if (audioPlayerManager.currentPlaylist.getPushId != null) {
        playlistPushId = audioPlayerManager.currentPlaylist.getPushId;
      } else {
        playlistPushId =
            audioPlayerManager.currentPlaylist.getPublicPlaylistPushId;
      }

      if (playlist.getPushId != null) {
        if (playlist.getPushId == playlistPushId) {
          if (audioPlayerManager.currentSong.getSongId == song.getSongId) {
            return GlobalVariables.pinkColor;
          } else {
            return returnWhite ? Colors.white : Colors.grey;
          }
        } else {
          return returnWhite ? Colors.white : Colors.grey;
        }
      } else {
        if (playlist.getPublicPlaylistPushId == playlistPushId) {
          if (audioPlayerManager.currentSong.getSongId == song.getSongId) {
            return GlobalVariables.pinkColor;
          } else {
            return returnWhite ? Colors.white : Colors.grey;
          }
        } else {
          return returnWhite ? Colors.white : Colors.grey;
        }
      }
    } else {
      return returnWhite ? Colors.white : Colors.grey;
    }
  }

  void showSongOptions(Song song, Playlist currentPlaylist) {
    if (currentUser != null) {
      SongModalSheetMode songModalSheetMode;
      if (currentUser.getPlaylists.contains(currentPlaylist)) {
        songModalSheetMode = SongModalSheetMode.regular;
      } else {
        songModalSheetMode = SongModalSheetMode.download_public_search_artist;
      }
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: GlobalVariables.homePageContext,
        builder: (builder) {
          return SongOptionsModalSheet(
            song,
            currentPlaylist,
            false,
            songModalSheetMode,
          );
        },
      );
    }
  }

  void showPlaylistOptions(Playlist currentPlaylist) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: GlobalVariables.homePageContext,
      builder: (builder) {
        return PlaylistOptionsModalSheet(
            currentPlaylist, context, widget.playlistModalSheetMode);
      },
    );
  }

  void checkForIntenetConnetionForNetworkImage() {
    if (widget.playlist.getSongs.length > 0) {
      Connectivity().checkConnectivity().then((connectivityResult) {
        ManageLocalSongs.checkIfFileExists(widget.playlist.getSongs[0])
            .then((exists) {
          if (exists) {
            File file = File(
                "${ManageLocalSongs.fullSongDownloadDir.path}/${widget.playlist.getSongs[0].getSongId}/${widget.playlist.getSongs[0].getSongId}.png");
            setState(() {
              imageProvider = (FileImage(file));
            });
          } else {
            if (connectivityResult == ConnectivityResult.mobile ||
                connectivityResult == ConnectivityResult.wifi) {
              setState(() {
                imageProvider = NetworkImage(
                  widget.playlist.getSongs[0].getImageUrl,
                );
              });
            }
          }
        });
      });
    }
  }

  Widget drawSongImage(Song song) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: GlobalVariables.lightGreyColor,
        shape: BoxShape.rectangle,
        border: Border.all(
          color: GlobalVariables.lightGreyColor,
          width: 0.4,
        ),
        image: DecorationImage(
          fit: BoxFit.fill,
          image: NetworkImage(
            song.getImageUrl,
          ),
        ),
      ),
    );
  }

  Widget drawDefaultSongImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlobalVariables.lightGreyColor,
            GlobalVariables.darkGreyColor,
          ],
          begin: FractionalOffset.bottomLeft,
          stops: [0.3, 0.8],
          end: FractionalOffset.topRight,
        ),
        border: Border.all(
          color: GlobalVariables.lightGreyColor,
          width: 0.4,
        ),
      ),
      child: Icon(
        Icons.music_note,
        color: GlobalVariables.pinkColor,
        size: 40,
      ),
    );
  }

  Widget drawPlaylistButtons() {
    return Padding(
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
              color: GlobalVariables.pinkColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Icon(
                      MyCustomIcons.play_icon,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Play all",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              elevation: 6.0,
              onPressed: () {
                if (widget.playlist.getSongs.length > 0) {
                  audioPlayerManager.initSong(
                    song: widget.playlist.getSongs[0],
                    playlist: widget.playlist,
                    playlistMode: PlaylistMode.loop,
                  );
                }
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
              color: GlobalVariables.pinkColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Icon(
                      MyCustomIcons.shuffle_icon,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Shuffle",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              elevation: 6.0,
              onPressed: () {
                if (widget.playlist.getSongs.length > 0) {
                  var rnd = Random();
                  int randomNum = rnd.nextInt(widget.playlist.getSongs.length);
                  audioPlayerManager.initSong(
                    song: widget.playlist.getSongs[randomNum],
                    playlist: widget.playlist,
                    playlistMode: PlaylistMode.shuffle,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
