import 'package:flutter/material.dart';
import 'package:myapp/custom_classes/custom_colors.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:provider/provider.dart';

enum SortType {
  title,
  artist,
  recentlyAdded,
}

class SortModalSheet extends StatefulWidget {
  final Playlist playlist;
  final bool regularSort;
  SortModalSheet(this.playlist, this.regularSort);

  @override
  _SortModalSheetState createState() => _SortModalSheetState();
}

class _SortModalSheetState extends State<SortModalSheet> {
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
      height: widget.regularSort ? 240 : 180,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              selected: widget.playlist.sortType == SortType.title,
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
          drawSortByTitle(),
          drawSortByArtist(),
          widget.regularSort ? drawSortByRecentlyAdded() : Container(),
        ],
      ),
    );
  }

  //* widgets
  Widget drawSortBy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTile(
        selected: widget.playlist.sortType == SortType.title,
        title: Text(
          "Sort by:",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget drawSortByTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTileTheme(
        selectedColor: GlobalVariables.pinkColor,
        textColor: Colors.white,
        child: ListTile(
          selected: widget.playlist.sortType == SortType.title,
          title: Text(
            "Title",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            if (widget.playlist.sortType != SortType.title) {
              widget.playlist.setSongs = sortList(SortType.title);
              widget.playlist.setSortedType = SortType.title;
              Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                  .setCurrentPlaylistPagePlaylist = widget.playlist;
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget drawSortByArtist() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTileTheme(
        selectedColor: GlobalVariables.pinkColor,
        textColor: Colors.white,
        child: ListTile(
          selected: widget.playlist.sortType == SortType.artist,
          title: Text(
            "Artist",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            if (widget.playlist.sortType != SortType.artist) {
              widget.playlist.setSongs = sortList(SortType.artist);
              widget.playlist.setSortedType = SortType.artist;
              Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                  .setCurrentPlaylistPagePlaylist = widget.playlist;
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget drawSortByRecentlyAdded() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTileTheme(
        selectedColor: GlobalVariables.pinkColor,
        textColor: Colors.white,
        child: ListTile(
          selected: widget.playlist.sortType == SortType.recentlyAdded,
          title: Text(
            "Recently added",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            if (widget.playlist.sortType != SortType.recentlyAdded) {
              widget.playlist.setSongs = sortList(SortType.recentlyAdded);
              widget.playlist.setSortedType = SortType.recentlyAdded;
              Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                  .setCurrentPlaylistPagePlaylist = widget.playlist;
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  //* methods
  List<Song> sortList(SortType sortType) {
    List<Song> sortedPlaylist = List();
    if (sortType == SortType.recentlyAdded) {
      sortedPlaylist = widget.playlist.songs;
      sortedPlaylist.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
    } else if (sortType == SortType.title) {
      sortedPlaylist = widget.playlist.songs;
      sortedPlaylist.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortType == SortType.artist) {
      sortedPlaylist = widget.playlist.songs;
      sortedPlaylist.sort((a, b) => a.artist.compareTo(b.artist));
    }
    return sortedPlaylist;
  }
}
