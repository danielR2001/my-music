import 'package:flutter/material.dart';
import 'package:myapp/core/enums/sort_type.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import '../../core/view_models/modal_sheet_models/sort_model.dart';
import '../pages/base_page.dart';

class SortModalSheet extends StatefulWidget {
  final Playlist playlist;
  final bool regularSort;
  SortModalSheet(this.playlist, this.regularSort);

  @override
  _SortModalSheetState createState() => _SortModalSheetState();
}

class _SortModalSheetState extends State<SortModalSheet> {
  SortModel _model;

  @override
  Widget build(BuildContext context) {
    return BasePage<SortModel>(
      onModelReady: (model) {
        _model = model;
        _model.setPagePlaylist = Playlist.fromPlaylist(widget.playlist);
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
        height: widget.regularSort ? 240 : 180,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
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
      ),
    );
  }

  //* widgets
  Widget drawSortBy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTile(
        selected: _model.pagePlaylist.sortType == SortType.title,
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
        selectedColor: CustomColors.pinkColor,
        textColor: Colors.white,
        child: ListTile(
          selected: _model.pagePlaylist.sortType == SortType.title,
          title: Text(
            "Title",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            if (_model.pagePlaylist.sortType != SortType.title) {
              _model.sortPlaylist(SortType.title);
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
        selectedColor: CustomColors.pinkColor,
        textColor: Colors.white,
        child: ListTile(
          selected: _model.pagePlaylist.sortType == SortType.artist,
          title: Text(
            "Artist",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            if (_model.pagePlaylist.sortType != SortType.artist) {
              _model.sortPlaylist(SortType.artist);
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
        selectedColor: CustomColors.pinkColor,
        textColor: Colors.white,
        child: ListTile(
          selected: _model.pagePlaylist.sortType == SortType.recentlyAdded,
          title: Text(
            "Recently added",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            if (_model.pagePlaylist.sortType != SortType.recentlyAdded) {
              _model.sortPlaylist(SortType.recentlyAdded);
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
      sortedPlaylist = _model.pagePlaylist.songs;
      sortedPlaylist.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
    } else if (sortType == SortType.title) {
      sortedPlaylist = _model.pagePlaylist.songs;
      sortedPlaylist.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortType == SortType.artist) {
      sortedPlaylist = _model.pagePlaylist.songs;
      sortedPlaylist.sort((a, b) => a.artist.compareTo(b.artist));
    }
    return sortedPlaylist;
  }
}
