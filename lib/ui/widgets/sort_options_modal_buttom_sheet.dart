import 'package:flutter/material.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/ui/pages/home_page.dart';
import 'package:provider/provider.dart';

enum SortType {
  title,
  artist,
  recentlyAdded,
}

class SortOptionsModalSheet extends StatefulWidget {
  final Playlist playlist;
  SortOptionsModalSheet(this.playlist);

  @override
  _SortOptionsModalSheetState createState() => _SortOptionsModalSheetState();
}

class _SortOptionsModalSheetState extends State<SortOptionsModalSheet> {
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
      height: 240,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              selected: widget.playlist.getSortedType == SortType.title,
              title: Text(
                "Sort by:",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTileTheme(
              selectedColor: Constants.pinkColor,
              textColor: Colors.white,
              child: ListTile(
                selected: widget.playlist.getSortedType == SortType.title,
                title: Text(
                  "Title",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  if (widget.playlist.getSortedType != SortType.title) {
                    widget.playlist.setSongs = sortList(SortType.title);
                    widget.playlist.setSortedType = SortType.title;
                    Provider.of<PageNotifier>(homePageContext)
                        .setCurrentPlaylistPagePlaylist = widget.playlist;
                    setState(() {});
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTileTheme(
              selectedColor: Constants.pinkColor,
              textColor: Colors.white,
              child: ListTile(
                selected: widget.playlist.getSortedType == SortType.artist,
                title: Text(
                  "Artist",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  if (widget.playlist.getSortedType != SortType.artist) {
                    widget.playlist.setSongs = sortList(SortType.artist);
                    widget.playlist.setSortedType = SortType.artist;
                    Provider.of<PageNotifier>(homePageContext)
                        .setCurrentPlaylistPagePlaylist = widget.playlist;
                    setState(() {});
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTileTheme(
              selectedColor: Constants.pinkColor,
              textColor: Colors.white,
              child: ListTile(
                selected:
                    widget.playlist.getSortedType == SortType.recentlyAdded,
                title: Text(
                  "Recently added",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  if (widget.playlist.getSortedType != SortType.recentlyAdded) {
                    widget.playlist.setSongs = sortList(SortType.recentlyAdded);
                    widget.playlist.setSortedType = SortType.recentlyAdded;
                    Provider.of<PageNotifier>(homePageContext)
                        .setCurrentPlaylistPagePlaylist = widget.playlist;
                    setState(() {});
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Song> sortList(SortType sortType) {
    List<Song> sortedPlaylist = List();
    if (sortType == SortType.recentlyAdded) {
      sortedPlaylist = widget.playlist.getSongs;
      sortedPlaylist.sort((a, b) => a.getDateAdded.compareTo(b.getDateAdded));
    } else if (sortType == SortType.title) {
      sortedPlaylist = widget.playlist.getSongs;
      sortedPlaylist.sort((a, b) => a.getTitle.compareTo(b.getTitle));
    } else if (sortType == SortType.artist) {
      sortedPlaylist = widget.playlist.getSongs;
      sortedPlaylist.sort((a, b) => a.getArtist.compareTo(b.getArtist));
    }
    return sortedPlaylist;
  }
}
