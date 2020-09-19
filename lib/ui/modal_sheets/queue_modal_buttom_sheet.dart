import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/core/view_models/modal_sheet_models/queue_model.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/pages/base_page.dart';

class QueueModalSheet extends StatefulWidget {
  @override
  _QueueModalSheetState createState() => _QueueModalSheetState();
}

class _QueueModalSheetState extends State<QueueModalSheet> {

  @override
  Widget build(BuildContext context) {
    return BasePage<QueueModel>(
      onModelReady: (model) async {
        await model.getCurrentSong();
        model.getCurrentPlaylist();
      },
      builder: (context, model, child) => Container(
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0)),
          color: CustomColors.lightGreyColor,
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
                data: Theme.of(context)
                    .copyWith(canvasColor: CustomColors.lightGreyColor),
                child: ReorderableListView(
                  children: drawPlaylistQueueSongs(model),
                  onReorder: (from, to) {
                    model.onReorder(to, from);
                  },
                ),
              ),
            ),
          ],
        ),
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

  List<Widget> drawPlaylistQueueSongs(QueueModel model) {
    List<Widget> songs = List();
    if(model.currentPlaylist == null) return songs;
    for (int i = 0; i < model.currentPlaylist.songs.length; i++) {
      Key key = Key("$i");
      songs.add(songItem(
          model.currentPlaylist.songs[i], i + 1, context, key, model));
    }
    return songs;
  }

  Widget songItem(
      Song song, int pos, BuildContext context, Key key, QueueModel model) {
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
          color: model.currentSong.songId == song.songId
              ? CustomColors.pinkColor
              : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        artist,
        style: TextStyle(
          color: model.currentSong.songId == song.songId
              ? CustomColors.pinkColor
              : Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: model.currentSong.songId != song.songId
          ? IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                  model.removeSongFromPlaylist(song);
              },
            )
          : Container(
              width: 0,
              height: 0,
            ),
      onTap: () {
        model.seekIndex(model.currentPlaylist.songs.indexOf(song));
      },
    );
  }
}
