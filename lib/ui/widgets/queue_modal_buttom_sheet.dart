import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/custom_classes/custom_colors.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:provider/provider.dart';

class QueueModalSheet extends StatefulWidget {
  @override
  _QueueModalSheetState createState() => _QueueModalSheetState();
}

class _QueueModalSheetState extends State<QueueModalSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0)),
        color: GlobalVariables.lightGreyColor,
      ),
      child: Column(
        children: <Widget>[
          drawTitle(),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Container(
              height: 1,
              //width: 350,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(canvasColor: GlobalVariables.lightGreyColor),
              child: ReorderableListView(
                children: drawPlaylistQueueSongs(),
                onReorder: (from, to) {
                  if (to > from) {
                    to--;
                  }
                  Song temp = Song.fromSong(
                      GlobalVariables.audioPlayerManager.currentPlaylist.songs[to]);
                  GlobalVariables.audioPlayerManager.currentPlaylist.songs[to] =
                      GlobalVariables.audioPlayerManager.currentPlaylist.songs[from];
                  GlobalVariables.audioPlayerManager.currentPlaylist.songs[from] = temp;
                  setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  //* Widgets
  Widget drawTitle() {
    return ListTile(
      title: Text(
        "Queue",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<Widget> drawPlaylistQueueSongs() {
    List<Widget> songs = List();
    for (int i = 0;
        i < GlobalVariables.audioPlayerManager.currentPlaylist.songs.length;
        i++) {
      Key key = Key("$i");
      songs.add(songItem(
          GlobalVariables.audioPlayerManager.currentPlaylist.songs[i], i + 1, context, key));
    }
    return songs;
  }

  Widget songItem(Song song, int pos, BuildContext context, Key key) {
    String title;
    String artist;
    if (song.title.length > 25) {
      int pos = song.title.lastIndexOf("", 25);
      if (pos < 20) {
        pos = 25;
      }
      title = song.title.substring(0, pos) + "...";
    } else {
      title = song.title;
    }
    if (song.artist.length > 30) {
      int pos = song.artist.lastIndexOf("", 30);
      if (pos < 20) {
        pos = 30;
      }
      artist = song.artist.substring(0, pos) + "...";
    } else {
      artist = song.artist;
    }
    return ListTile(
      key: key,
      leading: Text(
        "$pos",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Provider.of<PageNotifier>(context).currentSong.songId ==
                  song.songId
              ? GlobalVariables.pinkColor
              : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        artist,
        style: TextStyle(
          color: Provider.of<PageNotifier>(context).currentSong.songId ==
                  song.songId
              ? GlobalVariables.pinkColor
              : Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: GlobalVariables.audioPlayerManager.currentSong.songId != song.songId
          ? IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  GlobalVariables.audioPlayerManager.currentPlaylist.removeSong(song);
                });
              },
            )
          : Container(
              width: 0,
              height: 0,
            ),
      onTap: () {
        if (GlobalVariables.audioPlayerManager.currentSong.songId != song.songId) {
          if (GlobalVariables.audioPlayerManager.isSongLoaded &&
              GlobalVariables.audioPlayerManager.songPosition != Duration(milliseconds: 0)) {
            GlobalVariables.audioPlayerManager.initSong(
              song: song,
              playlist: GlobalVariables.audioPlayerManager.currentPlaylist,
              mode: GlobalVariables.audioPlayerManager.playlistMode,
            );
            setState(() {});
          }
        }
      },
    );
  }
}
