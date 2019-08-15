import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:myapp/database/database_manager.dart';
import 'package:myapp/custom_classes/custom_colors.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/managers/toast_manager.dart';
import 'package:myapp/custom_classes/custom_icons.dart';
import 'package:myapp/ui/pages/playlists_pick_page.dart';
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
  ImageProvider imageProvider;
  bool canceled = false;
  bool loadingArtists = false;
  @override
  void initState() {
    super.initState();
    if (GlobalVariables.isNetworkAvailable) {
      if (widget.song.imageUrl != "") {
        checkForIntenetConnetionForNetworkImage();
      } else {
        GlobalVariables.apiService
            .getSongImageUrl(widget.song, false)
            .then((imageUrl) {
          if (mounted) {
            if (imageUrl != null) {
              setState(() {
                widget.song.setImageUrl = imageUrl;
                checkForIntenetConnetionForNetworkImage();
              });
            }
          }
        });
      }
    }
  }

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
    return Container(
      alignment: Alignment.topCenter,
      height: 190 + 50 * widgetsCount,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0)),
        color: GlobalVariables.lightGreyColor,
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
            GlobalVariables.lightGreyColor,
            GlobalVariables.darkGreyColor,
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
      child: widget.song.imageUrl.length == 0 || imageProvider == null
          ? Icon(
              Icons.music_note,
              color: GlobalVariables.pinkColor,
              size: 40,
            )
          : Image(
              image: imageProvider,
              fit: BoxFit.contain,
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
            onTap: () {
              FirebaseDatabaseManager.removeSongFromPlaylist(
                  widget.playlist, widget.song);
              widget.playlist.removeSong(widget.song);
              Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                  .setCurrentPlaylistPagePlaylist = widget.playlist;
              GlobalVariables.currentUser.updatePlaylist(widget.playlist);
              if (GlobalVariables.audioPlayerManager.currentPlaylist != null) {
                if (GlobalVariables.audioPlayerManager.currentPlaylist.pushId ==
                    widget.playlist.pushId) {
                  if (widget.playlist.songs.length == 0) {
                    GlobalVariables.audioPlayerManager.loopPlaylist = null;
                    GlobalVariables.audioPlayerManager.shuffledPlaylist = null;
                    GlobalVariables.audioPlayerManager.currentPlaylist = null;
                  } else {
                    if (GlobalVariables.audioPlayerManager.currentSong.songId ==
                        widget.song.songId) {
                      GlobalVariables.audioPlayerManager.loopPlaylist = null;
                      GlobalVariables.audioPlayerManager.shuffledPlaylist =
                          null;
                      GlobalVariables.audioPlayerManager.currentPlaylist = null;
                    } else {
                      GlobalVariables.audioPlayerManager.loopPlaylist =
                          widget.playlist;
                      GlobalVariables.audioPlayerManager.shuffledPlaylist =
                          null;
                      GlobalVariables.audioPlayerManager.setCurrentPlaylist();
                    }
                  }
                }
              }
              if (widget.playlist.songs.length == 0) {
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget drawDownloadSong(BuildContext context) {
    if (!GlobalVariables.currentUser
            .songExistsInDownloadedPlaylist(widget.song) &&
        !GlobalVariables.manageLocalSongs.isSongDownloading(widget.song)) {
      return downloadWidget(context);
    } else {
      if (GlobalVariables.manageLocalSongs.isSongDownloading(widget.song)) {
        return Container();
      } else {
        return unDownloadWidget(context);
      }
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
          onTap: () {
            GlobalVariables.manageLocalSongs
                .checkIfStoragePermissionGranted()
                .then((permissonGranted) async {
              if (permissonGranted) {
                if (Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                        .currentPlaylistPagePlaylist !=
                    null) {
                  if (Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                          .currentPlaylistPagePlaylist
                          .name ==
                      GlobalVariables
                          .currentUser.downloadedSongsPlaylist.name) {
                    Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                            .setCurrentPlaylistPagePlaylist =
                        GlobalVariables.currentUser.downloadedSongsPlaylist;
                  }
                }
                if (widget.song.imageUrl == "") {
                  String imageUrl = await GlobalVariables.apiService
                      .getSongImageUrl(widget.song, false);
                  if (imageUrl != null) {
                    widget.song.setImageUrl = imageUrl;
                  }
                }
                GlobalVariables.manageLocalSongs.downloadSong(widget.song);
                Navigator.of(context, rootNavigator: true).pop('dialog');
              } else {
                GlobalVariables.toastManager
                    .makeToast(text: ToastManager.enableAccessToStorage);
              }
            });
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
          onTap: () {
            GlobalVariables.manageLocalSongs
                .checkIfSongFileExists(widget.song)
                .then((exists) {
              if (exists) {
                GlobalVariables.manageLocalSongs
                    .deleteSongDirectory(widget.song);
                GlobalVariables.currentUser
                    .removeSongFromDownloadedPlaylist(widget.song);
                if (Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                        .currentPlaylistPagePlaylist
                        .name ==
                    GlobalVariables.currentUser.downloadedSongsPlaylist.name) {
                  Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                          .setCurrentPlaylistPagePlaylist =
                      GlobalVariables.currentUser.downloadedSongsPlaylist;
                }
                if (GlobalVariables.audioPlayerManager.currentSong != null) {
                  if (widget.song.songId ==
                          GlobalVariables
                              .audioPlayerManager.currentSong.songId &&
                      widget.playlist.name ==
                          GlobalVariables
                              .currentUser.downloadedSongsPlaylist.name) {
                    GlobalVariables.audioPlayerManager.currentPlaylist = null;
                    GlobalVariables.audioPlayerManager.shuffledPlaylist = null;
                    GlobalVariables.audioPlayerManager.loopPlaylist = null;
                  }
                }
                GlobalVariables.toastManager
                    .makeToast(text: ToastManager.songUndownloaded);
              } else {
                GlobalVariables.toastManager
                    .makeToast(text: ToastManager.undownloadError);
              }
            });
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistPickPage(
                  song: widget.song,
                  songs: null,
                ),
              ),
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
            buildArtistsList(getArtists()).then((artists) {
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

  Future<List<Artist>> buildArtistsList(List<String> artistsList) async {
    List<Artist> artists = List();
    for (int i = 0; i < artistsList.length; i++) {
      Artist artist = await builArtist(artistsList[i]);
      if (artist != null) {
        artists.add(artist);
      }
    }
    return artists;
  }

  Future<Artist> builArtist(String artistName) async {
    return await GlobalVariables.apiService.getArtistImageUrl(artistName);
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
                            GlobalVariables.pinkColor),
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

  void checkForIntenetConnetionForNetworkImage() {
    GlobalVariables.manageLocalSongs
        .checkIfImageFileExists(widget.song)
        .then((exists) {
      if (exists) {
        if (mounted) {
          File file = File(
              "${GlobalVariables.manageLocalSongs.fullSongDownloadDir.path}/${widget.song.songId}/${widget.song.songId}.png");
          setState(() {
            imageProvider = FileImage(file);
          });
        }
      } else {
        if (GlobalVariables.isNetworkAvailable) {
          if (mounted) {
            setState(() {
              imageProvider = NetworkImage(
                widget.song.imageUrl,
              );
            });
          }
        }
      }
    });
  }
}
