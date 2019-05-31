import 'package:flutter/material.dart';
import 'package:myapp/ui/decorations/page_slide.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/pages/home_page.dart';
import 'package:myapp/ui/pages/playlists_pick_page.dart';
import 'text_style.dart';

class SongOptionsModalSheet extends StatelessWidget {
  final Playlist playlist;
  final Song song;
  SongOptionsModalSheet(this.song, this.playlist);
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      color: Color(0xFF000000),
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
                      30,
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
            FirebaseDatabaseManager.removeSongToPlaylist(playlist, song);
            playlist.removeSong(song);
            currentUser.updatePlaylist(playlist);
            audioPlayerManager.loopPlaylist = playlist;
            audioPlayerManager.setCurrentPlaylist();
            if (audioPlayerManager.currentPlaylist != null) {
              if (audioPlayerManager.currentPlaylist.getName ==
                  playlist.getName) {
                audioPlayerManager.currentPlaylist.getSongs.remove(song);
              }
            }
            if (playlist.getSongs.length > 0) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MyCustomRoute(
                  builder: (context) => HomePage(),
                ),
              );
            }
          },
        ),
      );
    } else {
      return Container();
    }
  }
}
