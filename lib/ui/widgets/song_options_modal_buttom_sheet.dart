import 'package:flutter/material.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/pages/playlists_pick_page.dart';
import 'package:myapp/ui/widgets/queue_modal_buttom_sheet.dart';
import 'text_style.dart';

class SongOptionsModalSheet extends StatelessWidget {
  final Playlist playlist;
  final Song song;
  final bool isMusicPlayerMenu;
  SongOptionsModalSheet(this.song, this.playlist, this.isMusicPlayerMenu);
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      color: Colors.grey[850],
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
          Padding(
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
              onTap: () {},
            ),
          ),
          Padding(
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
                    builder: (context) => PlaylistPickPage(song),
                  ),
                );
              },
            ),
          ),
          showQueue(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              leading: Icon(
                Icons.account_circle,
                color: Colors.grey,
                size: 30,
              ),
              title: Text(
                "View Artist",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              leading: Icon(
                Icons.share,
                color: Colors.grey,
                size: 30,
              ),
              title: Text(
                "Share",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget showRemoveFromPlaylist(BuildContext context) {
    if (playlist != null) {
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
            showMoreOptions(context);
          },
        ),
      );
    } else {
      return Container();
    }
  }

  void showMoreOptions(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return QueueModalSheet();
      },
    );
  }
}
