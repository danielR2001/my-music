import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:myapp/communicate_with_native/internet_connection_check.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/main.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/ui/pages/playlists_pick_page.dart';
import 'package:myapp/ui/widgets/artists_pick_modal_buttom_sheet.dart';
import 'package:myapp/ui/widgets/queue_modal_buttom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    InternetConnectionCheck.check().then((isNetworkAvailable) {
      if (isNetworkAvailable) {
        FetchData.getSongImageUrl(widget.song, false).then((imageUrl) {
          if (mounted) {
            setState(() {
              widget.song.setImageUrl = imageUrl;
              checkForIntenetConnetionForNetworkImage();
            });
          }
        });
      }
    });
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

  //Widgets
  Widget drawSongTitleArtist() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AutoSizeText(
          widget.song.getTitle,
          style: TextStyle(
              color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
        AutoSizeText(
          widget.song.getArtist,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16.0,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ],
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
      child: widget.song.getImageUrl.length == 0 || imageProvider == null
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
              currentUser.updatePlaylist(widget.playlist);
              if (audioPlayerManager.currentPlaylist != null) {
                if (audioPlayerManager.currentPlaylist.getPushId ==
                    widget.playlist.getPushId) {
                  if (widget.playlist.getSongs.length == 0) {
                    audioPlayerManager.loopPlaylist = null;
                    audioPlayerManager.shuffledPlaylist = null;
                    audioPlayerManager.currentPlaylist = null;
                  } else {
                    if (audioPlayerManager.currentSong.getSongId ==
                        widget.song.getSongId) {
                      audioPlayerManager.loopPlaylist = null;
                      audioPlayerManager.shuffledPlaylist = null;
                      audioPlayerManager.currentPlaylist = null;
                    } else {
                      audioPlayerManager.loopPlaylist = widget.playlist;
                      audioPlayerManager.shuffledPlaylist = null;
                      audioPlayerManager.setCurrentPlaylist();
                    }
                  }
                }
              }
              if (widget.playlist.getSongs.length == 0) {
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
    if (!currentUser.songExistsInDownloadedPlaylist(widget.song) &&
        !ManageLocalSongs.isSongDownloading(widget.song)) {
      return downloadWidget(context);
    } else {
      if (ManageLocalSongs.isSongDownloading(widget.song)) {
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
            ManageLocalSongs.checkIfStoragePermissionGranted()
                .then((permissonGranted) {
              if (permissonGranted) {
                ManageLocalSongs.checkIfFileExists(widget.song)
                    .then((exists) async {
                  if (!exists) {
                    if (Provider.of<PageNotifier>(
                                GlobalVariables.homePageContext)
                            .currentPlaylistPagePlaylist !=
                        null) {
                      if (Provider.of<PageNotifier>(
                                  GlobalVariables.homePageContext)
                              .currentPlaylistPagePlaylist
                              .getName ==
                          currentUser.getDownloadedSongsPlaylist.getName) {
                        Provider.of<PageNotifier>(
                                    GlobalVariables.homePageContext)
                                .setCurrentPlaylistPagePlaylist =
                            currentUser.getDownloadedSongsPlaylist;
                      }
                    }
                    if (widget.song.getImageUrl == "") {
                      String imageUrl =
                          await FetchData.getSongImageUrl(widget.song, false);
                      widget.song.setImageUrl = imageUrl;
                    }
                    ManageLocalSongs.downloadSong(widget.song);
                    Fluttertoast.showToast(
                      msg: "Download started",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIos: 1,
                      backgroundColor: GlobalVariables.pinkColor,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  } else {
                    Fluttertoast.showToast(
                      msg: "Song is already exists!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIos: 1,
                      backgroundColor: GlobalVariables.pinkColor,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                });
              } else {
                Fluttertoast.showToast(
                  msg: "You need to enable access to storage!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIos: 1,
                  backgroundColor: GlobalVariables.pinkColor,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
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
            Icons.undo,
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
            ManageLocalSongs.checkIfFileExists(widget.song).then((exists) {
              if (exists) {
                ManageLocalSongs.deleteSongDirectory(widget.song);
                currentUser.removeSongFromDownloadedPlaylist(widget.song);
                if (Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                        .currentPlaylistPagePlaylist
                        .getName ==
                    currentUser.getDownloadedSongsPlaylist.getName) {
                  Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                          .setCurrentPlaylistPagePlaylist =
                      currentUser.getDownloadedSongsPlaylist;
                }
                if (audioPlayerManager.currentSong != null) {
                  if (widget.song.getSongId ==
                          audioPlayerManager.currentSong.getSongId &&
                      widget.playlist.getName ==
                          currentUser.getDownloadedSongsPlaylist.getName) {
                    audioPlayerManager.currentPlaylist = null;
                    audioPlayerManager.shuffledPlaylist = null;
                    audioPlayerManager.loopPlaylist = null;
                  }
                }
                Fluttertoast.showToast(
                  msg: "song Undownloaded",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIos: 1,
                  backgroundColor: GlobalVariables.pinkColor,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              } else {
                Fluttertoast.showToast(
                  msg: "oops song is already undownloaded",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIos: 1,
                  backgroundColor: GlobalVariables.pinkColor,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
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
              Icons.queue_music,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 50,
        child: ListTile(
          leading: Icon(
            Icons.account_circle,
            color: Colors.grey,
            size: 30,
          ),
          title: Text(
            "View artists",
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
              if (!canceled) {
                loadingArtists = true;
                Navigator.of(context, rootNavigator: true).pop('dialog');
                showArtists(context, artists);
              }
            });
          },
        ),
      ),
    );
  }
  
  //Methods
  void showQueueModalBottomSheet(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return QueueModalSheet();
      },
    );
  }

  void showArtists(BuildContext context, List<Artist> artists) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return ArtistsPickModalSheet(widget.song, artists);
      },
    );
  }

  List<String> getArtists() {
    if (widget.song.getArtist.contains(", ") ||
        widget.song.getArtist.contains("&") ||
        widget.song.getArtist.contains("feat.")) {
      return widget.song.getArtist.split(RegExp(" feat. |\, |& |/"));
    } else {
      List<String> artist = new List();
      artist.add(widget.song.getArtist);
      return artist;
    }
  }

  Future<List<Artist>> buildArtistsList(List<String> artistsList) async {
    List<Artist> artists = List();
    for (int i = 0; i < artistsList.length; i++) {
      artists.add(await builArtist(artistsList[i]));
    }
    return artists;
  }

  Future<Artist> builArtist(String artistName) async {
    return await FetchData.getArtistPageIdAndImageUrl(artistName);
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
                      height: 40.0,
                      width: 50.0,
                      child: CircularProgressIndicator(
                        value: null,
                        strokeWidth: 2.0,
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
    InternetConnectionCheck.check().then((available) {
      ManageLocalSongs.checkIfFileExists(widget.song).then((exists) {
        if (exists) {
          if (mounted) {
            File file = File(
                "${ManageLocalSongs.fullSongDownloadDir.path}/${widget.song.getSongId}/${widget.song.getSongId}.png");
            setState(() {
              imageProvider = FileImage(file);
            });
          }
        } else {
          if (available) {
            if (mounted) {
              setState(() {
                imageProvider = NetworkImage(
                  widget.song.getImageUrl,
                );
              });
            }
          }
        }
      });
    });
  }
}
