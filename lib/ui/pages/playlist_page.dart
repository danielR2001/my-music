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
import 'package:myapp/ui/pages/music_player_page.dart';
import 'package:myapp/ui/widgets/playlist_options_modal_buttom_sheet.dart';
import 'package:myapp/ui/widgets/song_options_modal_buttom_sheet.dart';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';

class PlaylistPage extends StatefulWidget {
  final Playlist playlist;
  final String imagePath;
  final User playlistCreator;
  final PlaylistModalSheetMode playlistModalSheetMode;
  PlaylistPage(
      {this.playlist,
      this.imagePath,
      this.playlistCreator,
      this.playlistModalSheetMode});

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
                        colors: [GlobalVariables.darkGreyColor, Colors.transparent],
                      ).createShader(
                          Rect.fromLTRB(0, 0, rect.width, rect.height));
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image(
                      image: widget.imagePath != ""
                          ? NetworkImage(
                              widget.imagePath,
                            )
                          : AssetImage(
                              'assets/images/default_playlist_image.jpg',
                            ),
                      fit: BoxFit.cover,
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
                          ? Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                              .currentPlaylistPagePlaylist
                          : widget.playlist,
                  context)
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
            contentPadding: EdgeInsets.only(left: 20,right: 4),
            title: Text(
              title,
              style: TextStyle(
                color: audioPlayerManager.currentSong != null &&
                        audioPlayerManager.currentPlaylist != null
                    ? audioPlayerManager.loopPlaylist.getPushId ==
                            playlist.getPushId
                        ? audioPlayerManager.currentSong.getSongId ==
                                playlist.getSongs[index].getSongId
                            ? GlobalVariables.pinkColor
                            : Colors.white
                        : Colors.white
                    : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              artist,
              style: TextStyle(
                color: audioPlayerManager.currentSong != null &&
                        audioPlayerManager.currentPlaylist != null
                    ? audioPlayerManager.loopPlaylist.getPushId ==
                            playlist.getPushId
                        ? audioPlayerManager.currentSong.getSongId ==
                                playlist.getSongs[index].getSongId
                            ? GlobalVariables.pinkColor
                            : Colors.grey
                        : Colors.grey
                    : Colors.grey,
                fontSize: 13,
              ),
            ),
            trailing: ManageLocalSongs.isSongDownloading(
                        playlist.getSongs[index]) &&
                    widget.playlistModalSheetMode !=
                        PlaylistModalSheetMode.public
                ? Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: CircularProgressIndicator(
                      value: Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                              .downloadedProgresses[
                                  playlist.getSongs[index].getSongId]
                              .toDouble() /
                          Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                              .downloadedTotals[
                                  playlist.getSongs[index].getSongId]
                              .toDouble(),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(GlobalVariables.pinkColor),
                      backgroundColor: Colors.pink[50],
                      strokeWidth: 4.0,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: audioPlayerManager.currentSong != null &&
                              audioPlayerManager.currentPlaylist != null
                          ? audioPlayerManager.loopPlaylist.getPushId ==
                                  playlist.getPushId
                              ? audioPlayerManager.currentSong.getSongId ==
                                      playlist.getSongs[index].getSongId
                                  ? GlobalVariables.pinkColor
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
              if (audioPlayerManager.isLoaded) {
                if (audioPlayerManager.currentSong != null &&
                    audioPlayerManager.currentPlaylist != null) {
                  if (audioPlayerManager.currentSong.getSongId ==
                          playlist.getSongs[index].getSongId &&
                      audioPlayerManager.currentPlaylist.getPushId ==
                          playlist.getPushId) {
                    Navigator.push(
                      GlobalVariables.homePageContext,
                      MaterialPageRoute(
                          builder: (context) => MusicPlayerPage()),
                    );
                  } else {
                    audioPlayerManager.initSong(
                      song: playlist.getSongs[index],
                      playlist: playlist,
                      playlistMode: PlaylistMode.loop,
                    );
                  }
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

  void showSongOptions(Song song, Playlist currentPlaylist) {
    if (currentUser != null) {
      SongModalSheetMode songModalSheetMode;
      if (currentUser.getPlaylists.contains(currentPlaylist)) {
        songModalSheetMode = SongModalSheetMode.regular;
      } else {
        songModalSheetMode = SongModalSheetMode.download_public_search_artist;
      }
      showModalBottomSheet(
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
      context: GlobalVariables.homePageContext,
      builder: (builder) {
        return PlaylistOptionsModalSheet(
            currentPlaylist, context, widget.playlistModalSheetMode);
      },
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
                      Icons.play_arrow,
                      color: Colors.white,
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
                audioPlayerManager.initSong(
                  song: widget.playlist.getSongs[0],
                  playlist: widget.playlist,
                  playlistMode: PlaylistMode.loop,
                );
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
                      CupertinoIcons.shuffle_medium,
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
                var rnd = Random();
                int randomNum = rnd.nextInt(widget.playlist.getSongs.length);
                audioPlayerManager.initSong(
                  song: widget.playlist.getSongs[randomNum],
                  playlist: widget.playlist,
                  playlistMode: PlaylistMode.shuffle,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
