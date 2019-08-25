import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:myapp/core/view_models/modal_sheet_models/song_options_model.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/core/services/toast_service.dart';
import 'package:myapp/ui/custom_classes/custom_icons.dart';
import 'package:myapp/ui/pages/base_page.dart';
import 'package:myapp/ui/widgets/artists_pick_modal_buttom_sheet.dart';
import 'package:myapp/ui/widgets/queue_modal_buttom_sheet.dart';
import 'package:provider/provider.dart';

enum SongModalSheetMode {
  regular,
  download_public_search_artist,
}

class SongOptionsModalSheet extends StatefulWidget {
  final Playlist playlist;
  final Song song;
  final bool isMusicPlayerMenu;
  final SongModalSheetMode songModalSheetMode;
  SongOptionsModalSheet(this.song, this.playlist, this.isMusicPlayerMenu,
      this.songModalSheetMode);

  @override
  _SongOptionsModalSheetState createState() => _SongOptionsModalSheetState();
}

class _SongOptionsModalSheetState extends State<SongOptionsModalSheet> {
  SongOptionsModel _model;
  bool canceled = false;
  bool loadingArtists = false;

  @override
  Widget build(BuildContext context) {
    double widgetsCount = 4;
    if (widget.songModalSheetMode != null) {
      if (widget.songModalSheetMode ==
          SongModalSheetMode.download_public_search_artist) {
        widgetsCount = 3;
      }
    } else {
      widgetsCount = 3;
    }
    if (widget.isMusicPlayerMenu) {
      widgetsCount++;
    }
    return BasePage<SongOptionsModel>(
      onModelReady: (model) async {
        _model = model;
        await _model.loadImage(widget.song);
        await _model.checkIfSongDirExists(widget.song);
      },
      builder: (context, model, child) => Container(
        alignment: Alignment.topCenter,
        height: 190 + 50 * widgetsCount,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0)),
          color: CustomColors.lightGreyColor,
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: drawSongImageWidget(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  drawSongTitleArtist(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Container(
                height: 1,
                width: 350,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            drawRemoveFromPlaylist(context),
            drawDownloadSong(context),
            drawAddToPlaylist(context),
            drawQueue(context),
            drawViewArtist(context),
          ],
        ),
      ),
    );
  }

  //* widgets
  Widget drawSongTitleArtist() {
    return Container(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AutoSizeText(
            widget.song.title,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
          AutoSizeText(
            widget.song.artist,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16.0,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget drawSongImageWidget() {
    return Container(
      width: 90,
      height: 90,
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey[850],
            blurRadius: 1.0,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: _model.imageProvider != null
          ? Image(
              image: _model.imageProvider,
              fit: BoxFit.contain,
            )
          : Icon(
              Icons.music_note,
              color: CustomColors.pinkColor,
              size: 40,
            ),
    );
  }

  Widget drawRemoveFromPlaylist(BuildContext context) {
    if (widget.songModalSheetMode == SongModalSheetMode.regular &&
        widget.playlist != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          height: 50,
          child: ListTile(
            leading: Icon(
              Icons.remove_circle_outline,
              color: Colors.grey,
              size: 30,
            ),
            title: Text(
              "Remove from playlist",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              await _model.removeSongFromPlaylist(
                  Provider.of<User>(context), widget.playlist, widget.song);
              widget.playlist.removeSong(widget.song);
              Provider.of<User>(context).updatePlaylist(widget.playlist);

              Navigator.pop(context);
            },
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget drawDownloadSong(BuildContext context) {
    if (_model.songExists) {
      if (_model.isSongDownloading(widget.song)) {
        return Container();
      } else {
        return unDownloadWidget(context);
      }
    } else {
      return downloadWidget(context);
    }
  }

  Widget downloadWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 50,
        child: ListTile(
          leading: Icon(
            Icons.save_alt,
            color: Colors.grey,
            size: 30,
          ),
          title: Text(
            "Download",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async {
            if (!await _model.downloadSong(widget.song)) {
              _model.makeToast(ToastService.enableAccessToStorage);
            }
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget unDownloadWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 50,
        child: ListTile(
          leading: Icon(
            Icons.cancel,
            color: Colors.grey,
            size: 30,
          ),
          title: Text(
            "Undownload",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async {
            if (await _model.unDownloadSong(widget.song)) {
              _model.makeToast(ToastService.songUndownloaded);
            } else {
              _model.makeToast(ToastService.undownloadError);
            }
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget drawAddToPlaylist(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 50,
        child: ListTile(
          leading: Icon(
            Icons.playlist_add,
            color: Colors.grey,
            size: 30,
          ),
          title: Text(
            "Add to playlist",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              "/playlistPickPage",
              arguments: {
                'song': widget.song,
                'songs': null,
              },
            );
          },
        ),
      ),
    );
  }

  Widget drawQueue(BuildContext context) {
    if (widget.isMusicPlayerMenu && widget.playlist != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          height: 50,
          child: ListTile(
            leading: Icon(
              Icons.playlist_play,
              color: Colors.grey,
              size: 30,
            ),
            title: Text(
              "View queue",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              showQueueModalBottomSheet(context);
            },
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget drawViewArtist(BuildContext context) {
    String text = "View artist";
    IconData iconData = MyCustomIcons.artist_icon;
    if (widget.song.artist.contains(",") ||
        widget.song.artist.contains("&") ||
        widget.song.artist.contains("vs") ||
        widget.song.artist.contains("ft.") ||
        widget.song.artist.contains("feat.")) {
      text += "s";
      iconData = MyCustomIcons.artists_icon;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 50,
        child: ListTile(
          leading: Icon(
            iconData,
            color: Colors.grey,
            size: 30,
          ),
          title: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            canceled = false;
            showLoadingBar(context);
            _model.buildArtistsList(getArtists()).then((artists) {
              if (!canceled && artists.length > 0) {
                loadingArtists = true;
                Navigator.of(context, rootNavigator: true).pop('dialog');
                showArtists(context, artists);
              } else {
                if (artists.length == 0) {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                }
              }
            });
          },
        ),
      ),
    );
  }

  //* methods
  void showQueueModalBottomSheet(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) {
        return QueueModalSheet();
      },
    );
  }

  void showArtists(BuildContext context, List<Artist> artists) {
    Navigator.pop(context);
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) {
        return ArtistsPickModalSheet(widget.song, artists);
      },
    );
  }

  List<String> getArtists() {
    if (widget.song.artist.contains(", ") ||
        widget.song.artist.contains("&") ||
        widget.song.artist.contains("feat.")) {
      return widget.song.artist.split(RegExp(" feat. |\, |& |/"));
    } else {
      List<String> artist = List();
      artist.add(widget.song.artist);
      return artist;
    }
  }

  void showLoadingBar(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(0.0),
          backgroundColor: Colors.transparent,
          children: <Widget>[
            Container(
              width: 60.0,
              height: 60.0,
              alignment: AlignmentDirectional.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(
                        value: null,
                        strokeWidth: 3.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            CustomColors.pinkColor),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    ).then((a) {
      if (!loadingArtists) {
        canceled = true;
        Navigator.of(context, rootNavigator: true).pop('dialog');
      }
    });
  }
}
