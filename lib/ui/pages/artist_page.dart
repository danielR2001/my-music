import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:myapp/core/view_models/page_models/artist_model.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/pages/base_page.dart';
import 'package:myapp/ui/widgets/song_options_modal_buttom_sheet.dart';

class ArtistPage extends StatefulWidget {
  final Artist artist;
  ArtistPage(this.artist);
  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  final String smallArtistImageUrl =
      "https://ichef.bbci.co.uk/images/ic/160x160/p01bnb07.png";
  final String bigArtistImageUrl =
      "https://www.collegeatlas.org/wp-content/uploads/2014/06/Top-Party-Schools-main-image.jpg";
  ArtistModel _model;
  ScrollController _scrollController;
  Color iconColor = Colors.white;
  _ArtistPageState();
  @override
  void initState() {
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _model.disposeModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage<ArtistModel>(
        onModelReady: (model) {
          _model = model;
          _model.initModel();
          _model.loadArtistPlaylist();
        },
        builder: (context, model, child) => Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  color: CustomColors.darkGreyColor,
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
                                      color: CustomColors.lightGreyColor,
                                    )
                              : BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CustomColors.lightGreyColor,
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
                              ? CustomColors.lightGreyColor
                              : CustomColors.darkGreyColor
                          : CustomColors.darkGreyColor,
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
                                CustomColors.darkGreyColor,
                                Colors.transparent
                              ],
                            ).createShader(
                                Rect.fromLTRB(0, 0, rect.width, rect.height));
                          },
                          blendMode: BlendMode.dstIn,
                          child: widget.artist.imageUrl != smallArtistImageUrl
                              ? Image.network(
                                  widget.artist.imageUrl,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  bigArtistImageUrl,
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
                    makeSliverList(_model.pagePlaylist, context)
                  ],
                ),
              ),
            ));
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
            artist = playlist.songs[index].artist.substring(0, pos) + "...";
          } else {
            artist = playlist.songs[index].artist;
          }
          return ListTile(
            contentPadding: EdgeInsets.only(left: 20, right: 4),
            title: Text(
              title,
              style: TextStyle(
                color: _model.isPagePlaylistIsPlaying() &&
                        _model.isSongPlaying(playlist.songs[index])
                    ? CustomColors.pinkColor
                    : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              artist,
              style: TextStyle(
                color: _model.isPagePlaylistIsPlaying() &&
                        _model.isSongPlaying(playlist.songs[index])
                    ? CustomColors.pinkColor
                    : Colors.grey,
                fontSize: 12,
              ),
            ),
            trailing: _model.isSongDownloading(playlist.songs[index])
                ? Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      child: CircularProgressIndicator(
                        value: _model.progress(playlist.songs[index].songId) /
                            _model.total(playlist.songs[index].songId),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            CustomColors.pinkColor),
                        strokeWidth: 4.0,
                      ),
                      onTap: () {
                        _model.cancelDownLoad(playlist.songs[index]);
                      },
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: _model.isPagePlaylistIsPlaying() &&
                              _model.isSongPlaying(playlist.songs[index])
                          ? CustomColors.pinkColor
                          : Colors.white,
                    ),
                    iconSize: 30,
                    onPressed: () {
                      setState(() {
                        showSongOptions(playlist.songs[index]);
                      });
                    },
                  ),
            onTap: () async {
              if (_model.isPagePlaylistIsPlaying() &&
                  _model.isSongPlaying(playlist.songs[index])) {
                Navigator.pushNamed(
                  context,
                  "/musicPlayer",
                );
              } else {
                await _model.play(index);
              }
            },
          );
        }),
      ),
    );
  }

  //* methods
  void showSongOptions(Song song) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) {
        return SongOptionsModalSheet(
          song,
          _model.pagePlaylist,
          false,
          SongModalSheetMode.download_public_search_artist,
        );
      },
    );
  }
}
