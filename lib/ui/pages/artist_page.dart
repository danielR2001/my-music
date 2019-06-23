import 'package:flutter/material.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/pages/home_page.dart';
import 'package:myapp/ui/pages/music_player_page.dart';
import 'package:myapp/ui/widgets/song_options_modal_buttom_sheet.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';

class ArtistPage extends StatefulWidget {
  final Artist artist;
  ArtistPage(this.artist);
  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  ScrollController _scrollController;
  Color iconColor = Colors.white;
  int searchLength = 0;
  static List<Song> searchResults = List();
  Playlist topHitsPlaylist;
  _ArtistPageState();
  @override
  void initState() {
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    topHitsPlaylist = Playlist(widget.artist.getName + " Top Hits");
    FetchData.getResultsSitePage1(widget.artist.getName).then((results) {
      setState(() {
        if (results != null) {
          results.forEach((song) {
            if (song.getArtist
                    .toLowerCase()
                    .contains(widget.artist.getName.toLowerCase()) ||
                song.getTitle
                    .toLowerCase()
                    .contains(widget.artist.getName.toLowerCase())) {
              topHitsPlaylist.addNewSong(song);
            }
          });
          searchResults = results;
          searchLength = searchResults.length;
        }
      });
    });
    super.initState();
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
                    widget.artist.getName,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Constants.darkGreyColor, Colors.transparent],
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
                    topHitsPlaylist.getSongs.length > 0
                        ? Padding(
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
                        : Container(),
                  ],
                ),
              ),
              makeSliverList(widget.artist, context)
            ],
          ),
        ),
      ),
    );
  }

  SliverList makeSliverList(Artist artist, BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        List.generate(
            topHitsPlaylist.getSongs.length <= 20
                ? topHitsPlaylist.getSongs.length
                : 20, (int index) {
          String title;
          String artist;
          if (topHitsPlaylist.getSongs[index].getTitle.length > 30) {
            int pos =
                topHitsPlaylist.getSongs[index].getTitle.lastIndexOf("", 30);
            if (pos < 20) {
              pos = 35;
            }
            title = topHitsPlaylist.getSongs[index].getTitle.substring(0, pos) +
                "...";
          } else {
            title = topHitsPlaylist.getSongs[index].getTitle;
          }
          if (topHitsPlaylist.getSongs[index].getArtist.length > 35) {
            int pos =
                topHitsPlaylist.getSongs[index].getArtist.lastIndexOf("", 35);
            if (pos < 20) {
              pos = 35;
            }
            artist =
                topHitsPlaylist.getSongs[index].getArtist.substring(0, pos) +
                    "...";
          } else {
            artist = topHitsPlaylist.getSongs[index].getArtist;
          }
          return ListTile(
            title: Text(
              title,
              style: TextStyle(
                color: audioPlayerManager.currentSong != null &&
                        audioPlayerManager.currentPlaylist != null
                    ? audioPlayerManager.loopPlaylist.getName ==
                            topHitsPlaylist.getName
                        ? audioPlayerManager.currentSong.getSongId ==
                                topHitsPlaylist.getSongs[index].getSongId
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
                            topHitsPlaylist.getName
                        ? audioPlayerManager.currentSong.getSongId ==
                                topHitsPlaylist.getSongs[index].getSongId
                            ? Constants.pinkColor
                            : Colors.grey
                        : Colors.grey
                    : Colors.grey,
                fontSize: 12,
              ),
            ),
            trailing: ManageLocalSongs.isSongDownloading(
                    topHitsPlaylist.getSongs[index])
                ? Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Constants.pinkColor),
                      strokeWidth: 4.0,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: audioPlayerManager.currentSong != null &&
                              audioPlayerManager.currentPlaylist != null
                          ? audioPlayerManager.loopPlaylist.getName ==
                                  topHitsPlaylist.getName
                              ? audioPlayerManager.currentSong.getSongId ==
                                      topHitsPlaylist.getSongs[index].getSongId
                                  ? Constants.pinkColor
                                  : Colors.white
                              : Colors.white
                          : Colors.white,
                    ),
                    iconSize: 30,
                    onPressed: () {
                      setState(() {
                        showSongOptions(
                            topHitsPlaylist.getSongs[index], topHitsPlaylist);
                      });
                    },
                  ),
            onTap: () {
              if (audioPlayerManager.isLoaded) {
                if (audioPlayerManager.currentSong != null &&
                    audioPlayerManager.currentPlaylist != null) {
                  if (audioPlayerManager.currentSong.getSongId ==
                          topHitsPlaylist.getSongs[index].getSongId &&
                      audioPlayerManager.currentPlaylist.getName ==
                          topHitsPlaylist.getName) {
                    Navigator.push(
                      homePageContext,
                      MaterialPageRoute(
                          builder: (homePageContext) => MusicPlayerPage()),
                    );
                  } else {
                    audioPlayerManager.initSong(
                      topHitsPlaylist.getSongs[index],
                      topHitsPlaylist,
                      PlaylistMode.loop,
                    );

                    audioPlayerManager.playSong();
                  }
                } else {
                  audioPlayerManager.initSong(
                    topHitsPlaylist.getSongs[index],
                    topHitsPlaylist,
                    PlaylistMode.loop,
                  );

                  audioPlayerManager.playSong();
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
      context: homePageContext,
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
