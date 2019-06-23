import 'package:flutter/material.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/song.dart';

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
        color: Constants.lightGreyColor,
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              leading: Icon(
                audioPlayerManager.playlistMode == PlaylistMode.loop
                    ? Icons.repeat
                    : Icons.shuffle,
                color: Colors.grey,
                size: 30,
              ),
              title: Text(
                "Queue",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {},
            ),
          ),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(accentColor: Colors.grey),
              child: ListView.builder(
                itemCount: audioPlayerManager.currentPlaylist.getSongs.length,
                itemExtent: 60,
                itemBuilder: (BuildContext context, int index) {
                  return songItem(
                      audioPlayerManager.currentPlaylist.getSongs[index],
                      index + 1,
                      context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget songItem(Song song, int pos, BuildContext context) {
    String title;
    String artist;
    if (song.getTitle.length > 30) {
      int pos = song.getTitle.lastIndexOf("", 30);
      if (pos < 20) {
        pos = 35;
      }
      title = song.getTitle.substring(0, pos) + "...";
    } else {
      title = song.getTitle;
    }
    if (song.getArtist.length > 35) {
      int pos = song.getArtist.lastIndexOf("", 35);
      if (pos < 20) {
        pos = 35;
      }
      artist = song.getArtist.substring(0, pos) + "...";
    } else {
      artist = song.getArtist;
    }
    return ListTile(
      leading: Text(
        "$pos",
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: audioPlayerManager.currentSong.getSongId == song.getSongId
              ? Constants.pinkColor
              : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold
        ),
      ),
      subtitle: Text(
        artist,
        style: TextStyle(
          color: audioPlayerManager.currentSong.getSongId == song.getSongId
              ? Constants.pinkColor
              : Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: audioPlayerManager.currentSong.getSongId != song.getSongId
          ? IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  audioPlayerManager.currentPlaylist.removeSong(song);
                });
              },
            )
          : Container(
              width: 0,
              height: 0,
            ),
      onTap: () {
        if (audioPlayerManager.currentSong.getSongId != song.getSongId) {
          if (audioPlayerManager.isLoaded &&
              audioPlayerManager.songPosition != Duration(milliseconds: 0)) {
            audioPlayerManager.initSong(
              song,
              audioPlayerManager.currentPlaylist,
              audioPlayerManager.playlistMode,
            );
            audioPlayerManager.playSong();
            setState(() {});
          }
        }
      },
    );
  }
}
