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
    return new Container(
      alignment: Alignment.topCenter,
      color: Color(0xFF000000),
      child: new ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextDecoration(
                      song.getSongName,
                      20,
                      Colors.white,
                      20,
                      35,
                    ),
                    TextDecoration(
                      song.getArtist,
                      15,
                      Colors.grey,
                      30,
                      35,
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
              child: new SizedBox(
                height: 1,
              ),
            ),
          ),
          showRemoveFromPlaylist(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: new ListTile(
              leading: new Icon(
                Icons.save_alt,
                color: Colors.grey,
                size: 30,
              ),
              title: new Text(
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
            child: new ListTile(
              leading: new Icon(
                Icons.playlist_add,
                color: Colors.grey,
                size: 30,
              ),
              title: new Text(
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
            child: new ListTile(
              leading: new Icon(
                Icons.account_circle,
                color: Colors.grey,
                size: 30,
              ),
              title: new Text(
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
            child: new ListTile(
              leading: new Icon(
                Icons.share,
                color: Colors.grey,
                size: 30,
              ),
              title: new Text(
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
        child: new ListTile(
          leading: new Icon(
            Icons.remove_circle_outline,
            color: Colors.grey,
            size: 30,
          ),
          title: new Text(
            "Remove From This Playlist",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            FirebaseDatabaseManager.removeSongToPlaylist(playlist, song);
            currentUser.removeSongFromPlaylist(playlist, song);
            if (playingNow.currentPlaylist != null) {
              if (playingNow.currentPlaylist.getName == playlist.getName) {
                playingNow.currentPlaylist.getSongs.remove(song);
              }
            }
            if (playlist.getSongs.length > 0) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                new MyCustomRoute(
                  builder: (context) => new HomePage(1),
                ),
              );
            }
          },
        ),
      );
    } else {
      return new Container();
    }
  }
}
