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
      color: Constants.lightGreyColor,
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
                  color: Colors.white,
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
          fontSize: 15,
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
      trailing: IconButton(
        icon: Icon(
          Icons.clear,
          color: Colors.white,
        ),
        onPressed: () {},
      ),
      onTap: () {
        if (audioPlayerManager.currentSong.getSongId != song.getSongId) {
          audioPlayerManager.initSong(
            song,
            audioPlayerManager.currentPlaylist,
            audioPlayerManager.playlistMode,
          );

            audioPlayerManager.playSong(
            
            );
          
          Navigator.pop(context);
        }
      },
    );
  }
}
