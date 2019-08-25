import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/view_models/page_models/playlist_model.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/custom_classes/custom_icons.dart';
import 'package:myapp/ui/pages/base_page.dart';
import 'package:myapp/ui/widgets/playlist_options_modal_buttom_sheet.dart';
import 'package:myapp/ui/widgets/song_options_modal_buttom_sheet.dart';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';

class PlaylistPage extends StatefulWidget {
  final Playlist playlist;
  final PlaylistModalSheetMode playlistModalSheetMode;
  PlaylistPage(
      {this.playlist, this.playlistModalSheetMode});

  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  PlaylistModel _model;
  Color iconColor = Colors.white;
  ScrollController _scrollController;
  @override
  void initState() {
    _scrollController = ScrollController()..addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage<PlaylistModel>(
      onModelReady: (model) {
        _model = model;
        _model.initModel(widget.playlist);
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
                actions: <Widget>[
                  Padding(
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
                  titlePadding: EdgeInsets.only(),
                  title: drawPlaylistAndCreatorName(),
                  background: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: FractionalOffset.topCenter,
                        stops: [0, 1],
                        end: FractionalOffset.bottomCenter,
                        colors: [
                          CustomColors.darkGreyColor,
                          Colors.transparent
                        ],
                      ).createShader(
                          Rect.fromLTRB(0, 0, rect.width, rect.height));
                    },
                    blendMode: BlendMode.dstIn,
                    child: _model.imageProvider != null
                        ? Image(
                            image: _model.imageProvider,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.music_note,
                            color: CustomColors.pinkColor,
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
              makeSliverList(widget.playlist, context)
            ],
          ),
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
          title = _model.editSongTitle(playlist.songs[index].title);
          artist = _model.editSongArtist(playlist.songs[index].artist);
          return ListTile(
            contentPadding: EdgeInsets.only(left: 20, right: 4),
            title: Text(
              title,
              style: TextStyle(
                color: _model.isPagePlaylistIsPlaying() &&
                        _model.isSongPlaying(playlist.songs[index])
                    ? CustomColors.pinkColor
                    : Colors.white,
                fontSize: 14,
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
                fontSize: 13,
              ),
            ),
            trailing: _model.isSongDownloading(playlist.songs[index]) &&
                    widget.playlistModalSheetMode !=
                        PlaylistModalSheetMode.public
                ? Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      child: CircularProgressIndicator(
                        value: _model.progress(playlist.songs[index].songId) /
                            _model.total(playlist.songs[index].songId),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            CustomColors.pinkColor),
                        backgroundColor: Colors.pink[50],
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
                        showSongOptions(playlist.songs[index], playlist);
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
                await _model.play(index, PlaylistMode.loop);
              }
            },
          );
        }),
      ),
    );
  }

  Widget drawSongImage(Song song) {
    //!TODO change to one method
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: CustomColors.lightGreyColor,
        shape: BoxShape.rectangle,
        border: Border.all(
          color: CustomColors.lightGreyColor,
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
            CustomColors.lightGreyColor,
            CustomColors.darkGreyColor,
          ],
          begin: FractionalOffset.bottomLeft,
          stops: [0.3, 0.8],
          end: FractionalOffset.topRight,
        ),
        border: Border.all(
          color: CustomColors.lightGreyColor,
          width: 0.4,
        ),
      ),
      child: Icon(
        Icons.music_note,
        color: CustomColors.pinkColor,
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
        color: CustomColors.pinkColor,
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
        onPressed: () async {
          if (widget.playlist.songs.length > 0) {
            await _model.play(0, PlaylistMode.loop);
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
        color: CustomColors.pinkColor,
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
            _model.play(randomNum, PlaylistMode.shuffle);
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
            widget.playlistModalSheetMode != PlaylistModalSheetMode.download
                ? "by: " + widget.playlist.creator
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
  void showSongOptions(Song song, Playlist currentPlaylist) {
    SongModalSheetMode songModalSheetMode;
    if (Provider.of<User>(context).playlists.contains(currentPlaylist)) {
      songModalSheetMode = SongModalSheetMode.regular;
    } else {
      songModalSheetMode = SongModalSheetMode.download_public_search_artist;
    }
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
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

  void showPlaylistOptions(Playlist currentPlaylist) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) {
        return PlaylistOptionsModalSheet(
            currentPlaylist, context, widget.playlistModalSheetMode);
      },
    );
  }
//!TODO load image
}
