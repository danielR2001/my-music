import 'package:flutter/material.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/main.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/ui/pages/account_page.dart';
import 'package:myapp/ui/pages/playlists_pick_page.dart';
import 'package:myapp/ui/widgets/artists_pick_modal_buttom_sheet.dart';
import 'package:myapp/ui/widgets/queue_modal_buttom_sheet.dart';
import 'package:provider/provider.dart';
import 'text_style.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum SongModalSheetMode {
  regular,
  download_public_search_artist,
}

class SongOptionsModalSheet extends StatelessWidget {
  final Playlist playlist;
  final Song song;
  final bool isMusicPlayerMenu;
  final SongModalSheetMode songModalSheetMode;
  SongOptionsModalSheet(this.song, this.playlist, this.isMusicPlayerMenu,
      this.songModalSheetMode);
  @override
  Widget build(BuildContext context) {
    double widgetsCount = 4;
    if (songModalSheetMode != null) {
      if (songModalSheetMode ==
          SongModalSheetMode.download_public_search_artist) {
        widgetsCount = 3;
      }
    } else {
      widgetsCount = 3;
    }
    if (isMusicPlayerMenu) {
      widgetsCount++;
    }
    return Container(
      color: Constants.darkGreyColor,
      child: Container(
        alignment: Alignment.topCenter,
        height: 120 + 57 * widgetsCount,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10.0),
              topRight: const Radius.circular(10.0)),
          color: Constants.lightGreyColor,
        ),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextDecoration(
                        song.getTitle,
                        20,
                        Colors.white,
                        20,
                        30,
                      ),
                      TextDecoration(
                        song.getArtist,
                        15,
                        Colors.grey,
                        40,
                        30,
                      ),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                child: SizedBox(
                  height: 1,
                ),
              ),
            ),
            showRemoveFromPlaylist(context),
            showDownloadSong(context),
            showAddToPlaylist(context),
            showQueue(context),
            showViewArtist(context),
          ],
        ),
      ),
    );
  }

  Widget showRemoveFromPlaylist(BuildContext context) {
    if (!isMusicPlayerMenu &&
        songModalSheetMode == SongModalSheetMode.regular &&
        playlist != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListTile(
          leading: Icon(
            Icons.remove_circle_outline,
            color: Colors.grey,
            size: 30,
          ),
          title: Text(
            "Remove From This Playlist",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            FirebaseDatabaseManager.removeSongFromPlaylist(playlist, song);
            playlist.removeSong(song);
            Provider.of<PageNotifier>(accountPageContext).setCurrentPlaylistPagePlaylist = playlist;
            currentUser.updatePlaylist(playlist);
            if (audioPlayerManager.currentPlaylist != null) {
              if (audioPlayerManager.currentPlaylist.getName ==
                  playlist.getName) {
                if (playlist.getSongs.length == 0) {
                  audioPlayerManager.loopPlaylist = null;
                  audioPlayerManager.currentPlaylist = null;
                } else {
                  if (audioPlayerManager.currentSong.getSongId ==
                      song.getSongId) {
                    audioPlayerManager.loopPlaylist = null;
                    audioPlayerManager.currentPlaylist = null;
                  } else {
                    audioPlayerManager.loopPlaylist = playlist;
                    audioPlayerManager.setCurrentPlaylist();
                  }
                }
              }
            }
            if (playlist.getSongs.length == 0) {
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      );
    } else {
      return Container();
    }
  }

  Widget showDownloadSong(BuildContext context) {
    if (!currentUser.songExistsInDownloadedPlaylist(song) &&
        !ManageLocalSongs.isSongDownloading(song)) {
      return downloadWidget(context);
    } else {
      if (ManageLocalSongs.isSongDownloading(song)) {
        return Container();
      } else {
        return unDownloadWidget(context);
      }
    }
  }

  Widget downloadWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          ManageLocalSongs.checkIfStoragePermissionGranted()
              .then((permissonGranted) {
            if (permissonGranted) {
              ManageLocalSongs.checkIfFileExists(song).then((exists) async {
                if (!exists) {
                  Fluttertoast.showToast(
                    msg: "Download started",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIos: 1,
                    backgroundColor: Constants.pinkColor,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  if (song.getImageUrl == "") {
                    String imageUrl =
                        await FetchData.getSongImageUrl(song, false);
                    song.setImageUrl = imageUrl;
                  }
                  ManageLocalSongs.downloadSong(song);
                  Navigator.pop(context);
                } else {
                  Fluttertoast.showToast(
                    msg: "Song is already exists!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIos: 1,
                    backgroundColor: Constants.pinkColor,
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
                backgroundColor: Constants.pinkColor,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          });
        },
      ),
    );
  }

  Widget unDownloadWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTile(
        leading: Icon(
          Icons.undo,
          color: Colors.grey,
          size: 30,
        ),
        title: Text(
          "UnDownload",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          ManageLocalSongs.checkIfFileExists(song).then((exists) {
            if (exists) {
              ManageLocalSongs.deleteSongDirectory(song);
              currentUser.removeSongToDownloadedPlaylist(song);
              Fluttertoast.showToast(
                msg: "song Undownloaded",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIos: 1,
                backgroundColor: Constants.pinkColor,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            } else {
              Fluttertoast.showToast(
                msg: "oops song is already undownloaded",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIos: 1,
                backgroundColor: Constants.pinkColor,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget showAddToPlaylist(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTile(
        leading: Icon(
          Icons.playlist_add,
          color: Colors.grey,
          size: 30,
        ),
        title: Text(
          "Add To Playlist",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistPickPage(
                    song: song,
                    songs: null,
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget showQueue(BuildContext context) {
    if (isMusicPlayerMenu && playlist != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListTile(
          leading: Icon(
            Icons.queue_music,
            color: Colors.grey,
            size: 30,
          ),
          title: Text(
            "View Queue",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            showQueueModalBottomSheet(context);
          },
        ),
      );
    } else {
      return Container();
    }
  }

  Widget showViewArtist(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTile(
        leading: Icon(
          Icons.account_circle,
          color: Colors.grey,
          size: 30,
        ),
        title: Text(
          "View Artists",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          showLoadingBar(context);
          buildArtistsList(getArtists()).then((artists) {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            showArtists(context, artists);
          });
        },
      ),
    );
  }

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
        return ArtistsPickModalSheet(song, artists);
      },
    );
  }

  List<String> getArtists() {
    if (song.getArtist.contains(", ") ||
        song.getArtist.contains("&") ||
        song.getArtist.contains("feat.")) {
      return song.getArtist.split(RegExp(" feat. |\, |& |/"));
    } else {
      List<String> artist = new List();
      artist.add(song.getArtist);
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
                      height: 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(
                        value: null,
                        strokeWidth: 3.0,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Constants.pinkColor),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
