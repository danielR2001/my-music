import 'package:flutter/material.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
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
      color: Colors.grey[850],
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
    return ListTile(
      leading: Text(
        "$pos",
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
      title: Text(
        song.getTitle,
        style: TextStyle(
          color: audioPlayerManager.currentSong.getSongId == song.getSongId
              ? Colors.pink
              : Colors.white,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        song.getArtist,
        style: TextStyle(
          color: audioPlayerManager.currentSong.getSongId == song.getSongId
              ? Colors.pink
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
          FetchData.getSongPlayUrlDefault(song).then((streamUrl) {
            audioPlayerManager.playSong(
              streamUrl,
            );
          });
          Navigator.pop(context);
        }
      },
    );
  }
}
