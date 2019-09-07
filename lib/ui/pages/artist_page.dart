import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:myapp/core/view_models/page_models/artist_model.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/pages/base_page.dart';
import 'package:myapp/ui/modal_sheets/song_options_modal_buttom_sheet.dart';

class ArtistPage extends StatefulWidget {
  final Artist artist;
  ArtistPage(this.artist);
  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  ScrollController _scrollController;
  Color iconColor = Colors.white;

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage<ArtistModel>(
        onModelReady: (model) => model.initModel(widget.artist),
        onModelDisposed: (model)  => model.disposeModel(),
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
                          child: widget.artist.imageUrl != model.smallArtistImageUrl
                              ? Image.network(
                                  widget.artist.imageUrl,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  model.bigArtistImageUrl,
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
                    makeSliverList(model.pagePlaylist, context, model)
                  ],
                ),
              ),
            ));
  }

  //* widgets
  Widget makeSliverList(Playlist playlist, BuildContext context, ArtistModel model) {
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
                color: model.isPagePlaylistIsPlaying() &&
                        model.isSongPlaying(playlist.songs[index])
                    ? CustomColors.pinkColor
                    : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              artist,
              style: TextStyle(
                color: model.isPagePlaylistIsPlaying() &&
                        model.isSongPlaying(playlist.songs[index])
                    ? CustomColors.pinkColor
                    : Colors.grey,
                fontSize: 12,
              ),
            ),
            trailing: model.isSongDownloading(playlist.songs[index])
                ? Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      child: CircularProgressIndicator(
                        value: model.progress(playlist.songs[index].songId) /
                            model.total(playlist.songs[index].songId),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            CustomColors.pinkColor),
                        strokeWidth: 4.0,
                      ),
                      onTap: () {
                        model.cancelDownLoad(playlist.songs[index]);
                      },
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: model.isPagePlaylistIsPlaying() &&
                              model.isSongPlaying(playlist.songs[index])
                          ? CustomColors.pinkColor
                          : Colors.white,
                    ),
                    iconSize: 30,
                    onPressed: () {
                      setState(() {
                        showSongOptions(playlist.songs[index], model);
                      });
                    },
                  ),
            onTap: () async {
              if (model.isPagePlaylistIsPlaying() &&
                  model.isSongPlaying(playlist.songs[index])) {
                Navigator.pushNamed(
                  context,
                  "/musicPlayer",
                );
              } else {
                await model.play(index);
              }
            },
          );
        }),
      ),
    );
  }

  //* methods
  void showSongOptions(Song song, ArtistModel model) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) {
        return SongOptionsModalSheet(
          song,
          model.pagePlaylist,
          false,
          SongModalSheetMode.download_public_search_artist,
        );
      },
    );
  }
}
