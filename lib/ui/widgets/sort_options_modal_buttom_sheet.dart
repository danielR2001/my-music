import 'package:flutter/material.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';

enum SortType {
  title,
  artist,
  recentlyAdded,
}

class SortOptionsModalSheet extends StatelessWidget {
  final Playlist playlist;
  SortOptionsModalSheet(this.playlist);
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      color: Constants.lightGreyColor,
      height: 180,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              title: Text(
                "Title",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                playlist.setSortedSongs = sortList(SortType.title);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              title: Text(
                "Artist",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                playlist.setSortedSongs = sortList(SortType.artist);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              title: Text(
                "Recently added",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                playlist.setSortedSongs = sortList(SortType.recentlyAdded);
                //TODO refresh playlist_page playlist!
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Song> sortList(SortType sortType) {
    List<Song> sortedPlaylist = List();
    if (sortType == SortType.recentlyAdded) {
      List<int> datesList = List();
      for (int i = 0; i < playlist.getSongs.length; i++) {
        datesList.add(playlist.getSongs[i].getDateAdded);
      }
      datesList.sort();
      datesList.forEach((date) {
        for (int i = 0; i < playlist.getSongs.length; i++) {
          if (playlist.getSongs[i].getDateAdded == date) {
            sortedPlaylist.add(playlist.getSongs[i]);
            break;
          }
        }
      });
    } else if (sortType == SortType.title) {
      List<String> titlesList = List();
      for (int i = 0; i < playlist.getSongs.length; i++) {
        titlesList.add(playlist.getSongs[i].getTitle);
      }
      titlesList.sort((a, b) => a[0].compareTo(b[0]));
      titlesList.forEach((title) {
        for (int i = 0; i < playlist.getSongs.length; i++) {
          if (playlist.getSongs[i].getTitle == title) {
            sortedPlaylist.add(playlist.getSongs[i]);
            break;
          }
        }
      });
    } else if (sortType == SortType.artist) {
      List<String> artistsList = List();
      for (int i = 0; i < playlist.getSongs.length; i++) {
        artistsList.add(playlist.getSongs[i].getArtist);
      }
      artistsList.sort((a, b) => a[0].compareTo(b[0]));
      artistsList.forEach((artist) {
        for (int i = 0; i < playlist.getSongs.length; i++) {
          if (playlist.getSongs[i].getArtist == artist) {
            sortedPlaylist.add(playlist.getSongs[i]);
            break;
          }
        }
      });
    }
    return sortedPlaylist;
  }
}
