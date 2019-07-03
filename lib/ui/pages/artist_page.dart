import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/ui/pages/music_player_page.dart';
import 'package:myapp/ui/widgets/song_options_modal_buttom_sheet.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';
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
        child: Theme(
          data: Theme.of(context).copyWith(accentColor: Colors.grey),
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
                    widget.artist.getName,
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
                        colors: [GlobalVariables.darkGreyColor, Colors.transparent],
                      ).createShader(
                          Rect.fromLTRB(0, 0, rect.width, rect.height));
                    },
                    blendMode: BlendMode.dstIn,
                    child: widget.artist.getImageUrl !=
                            "https://ichef.bbci.co.uk/images/ic/160x160/p01bnb07.png"
                        ? Image.network(
                            widget.artist.getImageUrl,
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
                    widget.artist.getInfo != ""
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Text(
                              "About:",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      child: Text(
                        widget.artist.getInfo,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Text(
                        "Top Hits:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              makeSliverList(
                  Provider.of<PageNotifier>(context)
                      .currentPlaylistPagePlaylist,
                  context)
            ],
          ),
        ),
      ),
    );
  }

  Widget makeSliverList(Playlist playlist, BuildContext context) {
    if (playlist == null) {
      playlist = Playlist("temp");
    }
    return SliverList(
      delegate: SliverChildListDelegate(
        List.generate(playlist.getSongs.length, (int index) {
          String title;
          String artist;
          if (playlist.getSongs[index].getTitle.length > 28) {
            int pos = playlist.getSongs[index].getTitle.lastIndexOf("", 28);
            if (pos < 20) {
              pos = 28;
            }
            title = playlist.getSongs[index].getTitle.substring(0, pos) + "...";
          } else {
            title = playlist.getSongs[index].getTitle;
          }
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
          return ListTile(
            title: Text(
              title,
              style: TextStyle(
                color: audioPlayerManager.currentSong != null &&
                        audioPlayerManager.currentPlaylist != null
                    ? audioPlayerManager.loopPlaylist.getName ==
                            playlist.getName
                        ? audioPlayerManager.currentSong.getSongId ==
                                playlist.getSongs[index].getSongId
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
                color: audioPlayerManager.currentSong != null &&
                        audioPlayerManager.currentPlaylist != null
                    ? audioPlayerManager.loopPlaylist.getName ==
                            playlist.getName
                        ? Provider.of<PageNotifier>(context).currentSong.getSongId ==
                                playlist.getSongs[index].getSongId
                            ? GlobalVariables.pinkColor
                            : Colors.grey
                        : Colors.grey
                    : Colors.grey,
                fontSize: 12,
              ),
            ),
            trailing: ManageLocalSongs.isSongDownloading(
                    playlist.getSongs[index])
                ? Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(GlobalVariables.pinkColor),
                      strokeWidth: 4.0,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: audioPlayerManager.currentSong != null &&
                              audioPlayerManager.currentPlaylist != null
                          ? audioPlayerManager.loopPlaylist.getName ==
                                  playlist.getName
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
                      audioPlayerManager.currentPlaylist.getName ==
                          playlist.getName) {
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
    showModalBottomSheet(
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
