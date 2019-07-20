import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/global_variables/global_variables.dart';
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
                      AudioPlayerManager.currentPlaylist.getSongs[to]);
                  AudioPlayerManager.currentPlaylist.getSongs[to] =
                      AudioPlayerManager.currentPlaylist.getSongs[from];
                  AudioPlayerManager.currentPlaylist.getSongs[from] = temp;
                  setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widgets
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
        i < AudioPlayerManager.currentPlaylist.getSongs.length;
        i++) {
      Key key = Key("$i");
      songs.add(songItem(
          AudioPlayerManager.currentPlaylist.getSongs[i], i + 1, context, key));
    }
    return songs;
  }

  Widget songItem(Song song, int pos, BuildContext context, Key key) {
    String title;
    String artist;
    if (song.getTitle.length > 25) {
      int pos = song.getTitle.lastIndexOf("", 25);
      if (pos < 20) {
        pos = 25;
      }
      title = song.getTitle.substring(0, pos) + "...";
    } else {
      title = song.getTitle;
    }
    if (song.getArtist.length > 30) {
      int pos = song.getArtist.lastIndexOf("", 30);
      if (pos < 20) {
        pos = 30;
      }
      artist = song.getArtist.substring(0, pos) + "...";
    } else {
      artist = song.getArtist;
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
          color: Provider.of<PageNotifier>(context).currentSong.getSongId ==
                  song.getSongId
              ? GlobalVariables.pinkColor
              : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        artist,
        style: TextStyle(
          color: Provider.of<PageNotifier>(context).currentSong.getSongId ==
                  song.getSongId
              ? GlobalVariables.pinkColor
              : Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: AudioPlayerManager.currentSong.getSongId != song.getSongId
          ? IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  AudioPlayerManager.currentPlaylist.removeSong(song);
                });
              },
            )
          : Container(
              width: 0,
              height: 0,
            ),
      onTap: () {
        if (AudioPlayerManager.currentSong.getSongId != song.getSongId) {
          if (AudioPlayerManager.isSongLoaded &&
              AudioPlayerManager.songPosition != Duration(milliseconds: 0)) {
            AudioPlayerManager.initSong(
              song: song,
              playlist: AudioPlayerManager.currentPlaylist,
              mode: AudioPlayerManager.playlistMode,
            );
            setState(() {});
          }
        }
      },
    );
  }
}
