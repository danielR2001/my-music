import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/ui/pages/music_player_page.dart';
import 'package:myapp/ui/widgets/song_options_modal_buttom_sheet.dart';
import 'package:provider/provider.dart';

class ArtistPage extends StatefulWidget {
  final Artist artist;
  ArtistPage(this.artist);
  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  ScrollController _scrollController;
  Color iconColor = Colors.white;
  _ArtistPageState();
  @override
  void initState() {
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    super.initState();
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
                title: AutoSizeText(
                  widget.artist.name,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
                background: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        GlobalVariables.darkGreyColor,
                        Colors.transparent
                      ],
                    ).createShader(
                        Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: widget.artist.imageUrl !=
                          "https://ichef.bbci.co.uk/images/ic/160x160/p01bnb07.png"
                      ? Image.network(
                          widget.artist.imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          "https://www.collegeatlas.org/wp-content/uploads/2014/06/Top-Party-Schools-main-image.jpg",
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Text(
                      "Top Hits:",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
            makeSliverList(
                Provider.of<PageNotifier>(context).currentPlaylistPagePlaylist,
                context)
          ],
        ),
      ),
    );
  }

  //* widgets
  Widget makeSliverList(Playlist playlist, BuildContext context) {
    if (playlist == null) {
      playlist = Playlist("temp");
    }
    return SliverList(
      delegate: SliverChildListDelegate(
        List.generate(playlist.songs.length, (int index) {
          String title;
          String artist;
          if (playlist.songs[index].title.length > 28) {
            int pos = playlist.songs[index].title.lastIndexOf("", 28);
            if (pos < 20) {
              pos = 28;
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
            artist =
                playlist.songs[index].artist.substring(0, pos) + "...";
          } else {
            artist = playlist.songs[index].artist;
          }
          return ListTile(
            contentPadding: EdgeInsets.only(left: 20, right: 4),
            title: Text(
              title,
              style: TextStyle(
                color: GlobalVariables.audioPlayerManager.currentSong != null &&
                        GlobalVariables.audioPlayerManager.currentPlaylist != null
                    ? GlobalVariables.audioPlayerManager.loopPlaylist.name ==
                            playlist.name
                        ? GlobalVariables.audioPlayerManager.currentSong.songId ==
                                playlist.songs[index].songId
                            ? GlobalVariables.pinkColor
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
                color: GlobalVariables.audioPlayerManager.currentSong != null &&
                        GlobalVariables.audioPlayerManager.currentPlaylist != null
                    ? GlobalVariables.audioPlayerManager.loopPlaylist.name ==
                            playlist.name
                        ? Provider.of<PageNotifier>(context)
                                    .currentSong
                                    .songId ==
                                playlist.songs[index].songId
                            ? GlobalVariables.pinkColor
                            : Colors.grey
                        : Colors.grey
                    : Colors.grey,
                fontSize: 12,
              ),
            ),
            trailing:
                GlobalVariables.manageLocalSongs.isSongDownloading(playlist.songs[index])
                    ? Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              GlobalVariables.pinkColor),
                          strokeWidth: 4.0,
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: GlobalVariables.audioPlayerManager.currentSong != null &&
                                  GlobalVariables.audioPlayerManager.currentPlaylist != null
                              ? GlobalVariables.audioPlayerManager.loopPlaylist.name ==
                                      playlist.name
                                  ? GlobalVariables.audioPlayerManager.currentSong.songId ==
                                          playlist.songs[index].songId
                                      ? GlobalVariables.pinkColor
                                      : Colors.white
                                  : Colors.white
                              : Colors.white,
                        ),
                        iconSize: 30,
                        onPressed: () {
                          setState(() {
                            showSongOptions(playlist.songs[index], playlist);
                          });
                        },
                      ),
            onTap: () {
              if (GlobalVariables.audioPlayerManager.isSongLoaded) {
                if (GlobalVariables.audioPlayerManager.currentSong != null &&
                    GlobalVariables.audioPlayerManager.currentPlaylist != null) {
                  if (GlobalVariables.audioPlayerManager.currentSong.songId ==
                          playlist.songs[index].songId &&
                      GlobalVariables.audioPlayerManager.currentPlaylist.name ==
                          playlist.name) {
                    Navigator.push(
                      GlobalVariables.homePageContext,
                      MaterialPageRoute(
                          builder: (context) => MusicPlayerPage()),
                    );
                  } else {
                    GlobalVariables.audioPlayerManager.initSong(
                      song: playlist.songs[index],
                      playlist: playlist,
                      mode: PlaylistMode.loop,
                    );
                  }
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

  //* methods
  void showSongOptions(Song song, Playlist currentPlaylist) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: GlobalVariables.homePageContext,
      builder: (builder) {
        return SongOptionsModalSheet(
          song,
          currentPlaylist,
          false,
          SongModalSheetMode.download_public_search_artist,
        );
      },
    );
  }
}
