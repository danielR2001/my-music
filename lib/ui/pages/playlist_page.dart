import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/custom_classes/custom_colors.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/managers/audio_player_manager.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/custom_classes/custom_icons.dart';
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
                title: drawPlaylistAndCreatorName(),
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
                                .currentPlaylistPagePlaylist !=
                            null
                        ? Provider.of<PageNotifier>(
                                        GlobalVariables.homePageContext)
                                    .currentPlaylistPagePlaylist
                                    .pushId ==
                                widget.playlist.pushId
                            ? Provider.of<PageNotifier>(
                                    GlobalVariables.homePageContext)
                                .currentPlaylistPagePlaylist
                            : widget.playlist
                        : widget.playlist,
                context)
          ],
        ),
      ),
    );
  }

  //* widgets
  Widget makeSliverList(Playlist playlist, BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        List.generate(playlist.songs.length, (int index) {
          String title;
          String artist;
          if (playlist.songs[index].title.length > 33) {
            int pos = playlist.songs[index].title.lastIndexOf("", 33);
            if (pos < 25) {
              pos = 33;
            }
            title = playlist.songs[index].title.substring(0, pos) + "...";
          } else {
            title = playlist.songs[index].title;
          }
          if (playlist.songs[index].artist.length > 36) {
            int pos = playlist.songs[index].artist.lastIndexOf("", 36);
            if (pos < 26) {
              pos = 36;
            }
            artist = playlist.songs[index].artist.substring(0, pos) + "...";
          } else {
            artist = playlist.songs[index].artist;
          }
          return ListTile(
            contentPadding: EdgeInsets.only(left: 20, right: 4),
            title: Text(
              title,
              style: TextStyle(
                color: setSongColor(playlist, playlist.songs[index], true),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              artist,
              style: TextStyle(
                color: setSongColor(playlist, playlist.songs[index], false),
                fontSize: 13,
              ),
            ),
            trailing: GlobalVariables.manageLocalSongs
                        .isSongDownloading(playlist.songs[index]) &&
                    widget.playlistModalSheetMode !=
                        PlaylistModalSheetMode.public
                ? Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      child: CircularProgressIndicator(
                        value: Provider.of<PageNotifier>(
                                    GlobalVariables.homePageContext)
                                .downloadedProgresses[
                                    playlist.songs[index].songId]
                                .toDouble() /
                            Provider.of<PageNotifier>(
                                    GlobalVariables.homePageContext)
                                .downloadedTotals[playlist.songs[index].songId]
                                .toDouble(),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            GlobalVariables.pinkColor),
                        backgroundColor: Colors.pink[50],
                        strokeWidth: 4.0,
                      ),
                      onTap: () {
                        GlobalVariables.manageLocalSongs
                            .cancelDownLoad(playlist.songs[index]);
                      },
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color:
                          setSongColor(playlist, playlist.songs[index], true),
                    ),
                    iconSize: 30,
                    onPressed: () {
                      setState(() {
                        showSongOptions(playlist.songs[index], playlist);
                      });
                    },
                  ),
            onTap: () {
              String playlistPushId;
              bool openMusicPlayer = false;
              if (GlobalVariables.audioPlayerManager.currentSong != null &&
                  GlobalVariables.audioPlayerManager.currentPlaylist != null) {
                if (GlobalVariables.audioPlayerManager.currentPlaylist.pushId !=
                    null) {
                  playlistPushId =
                      GlobalVariables.audioPlayerManager.currentPlaylist.pushId;
                } else {
                  playlistPushId = GlobalVariables
                      .audioPlayerManager.currentPlaylist.publicPlaylistPushId;
                }

                if (playlist.pushId != null) {
                  if (playlist.pushId == playlistPushId) {
                    if (GlobalVariables.audioPlayerManager.currentSong.songId ==
                        playlist.songs[index].songId) {
                      openMusicPlayer = true;
                    }
                  }
                } else {
                  if (playlist.publicPlaylistPushId == playlistPushId) {
                    if (GlobalVariables.audioPlayerManager.currentSong.songId ==
                        playlist.songs[index].songId) {
                      openMusicPlayer = true;
                    }
                  }
                }
              }
              if (GlobalVariables.audioPlayerManager.isSongLoaded) {
                if (openMusicPlayer) {
                  Navigator.push(
                    GlobalVariables.homePageContext,
                    MaterialPageRoute(builder: (context) => MusicPlayerPage()),
                  );
                } else {
                  GlobalVariables.audioPlayerManager.initSong(
                    song: playlist.songs[index],
                    playlist: playlist,
                    mode: PlaylistMode.loop,
                  );
                }
              }
            },
          );
        }),
      ),
    );
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
            song.imageUrl,
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
          drawPlayAllButton(),
          SizedBox(
            width: 20,
          ),
          drawShuffleButton(),
        ],
      ),
    );
  }

  Widget drawPlayAllButton() {
    return Container(
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
          if (widget.playlist.songs.length > 0) {
            GlobalVariables.audioPlayerManager.initSong(
              song: widget.playlist.songs[0],
              playlist: widget.playlist,
              mode: PlaylistMode.loop,
            );
          }
        },
      ),
    );
  }

  Widget drawShuffleButton() {
    return Container(
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
          if (widget.playlist.songs.length > 0) {
            var rnd = Random();
            int randomNum = rnd.nextInt(widget.playlist.songs.length);
            GlobalVariables.audioPlayerManager.initSong(
              song: widget.playlist.songs[randomNum],
              playlist: widget.playlist,
              mode: PlaylistMode.shuffle,
            );
          }
        },
      ),
    );
  }

  Widget drawPlaylistAndCreatorName() {
    return Container(
      height: 50,
      width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AutoSizeText(
            widget.playlist.name,
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
            GlobalVariables.currentUser != null
                ? widget.playlistModalSheetMode !=
                        PlaylistModalSheetMode.download
                    ? "by: " + widget.playlistCreator.name
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
    );
  }

  //* methods
  Color setSongColor(Playlist playlist, Song song, bool returnWhite) {
    String playlistPushId;
    if (GlobalVariables.audioPlayerManager.currentSong != null &&
        GlobalVariables.audioPlayerManager.currentPlaylist != null) {
      if (GlobalVariables.audioPlayerManager.currentPlaylist.pushId != null) {
        playlistPushId =
            GlobalVariables.audioPlayerManager.currentPlaylist.pushId;
      } else {
        playlistPushId = GlobalVariables
            .audioPlayerManager.currentPlaylist.publicPlaylistPushId;
      }

      if (playlist.pushId != null) {
        if (playlist.pushId == playlistPushId) {
          if (GlobalVariables.audioPlayerManager.currentSong.songId ==
              song.songId) {
            return GlobalVariables.pinkColor;
          } else {
            return returnWhite ? Colors.white : Colors.grey;
          }
        } else {
          return returnWhite ? Colors.white : Colors.grey;
        }
      } else {
        if (playlist.publicPlaylistPushId == playlistPushId) {
          if (GlobalVariables.audioPlayerManager.currentSong.songId ==
              song.songId) {
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
    if (GlobalVariables.currentUser != null) {
      SongModalSheetMode songModalSheetMode;
      if (GlobalVariables.currentUser.playlists.contains(currentPlaylist)) {
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
    if (widget.playlist.songs.length > 0 && widget.playlist.songs[0].imageUrl != "") {
      GlobalVariables.manageLocalSongs
          .checkIfImageFileExists(widget.playlist.songs[0])
          .then((exists) {
        if (exists) {
          File file = File(
              "${GlobalVariables.manageLocalSongs.fullSongDownloadDir.path}/${widget.playlist.songs[0].songId}/${widget.playlist.songs[0].songId}.png");
          setState(() {
            imageProvider = (FileImage(file));
          });
        } else {
          if (GlobalVariables.isNetworkAvailable) {
            setState(() {
              imageProvider = NetworkImage(
                widget.playlist.songs[0].imageUrl,
              );
            });
          }
        }
      });
    }else{
      setState(() {
        imageProvider = null;
      });
    }
  }
}
