import 'package:flutter/material.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
import 'package:myapp/main.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/ui/pages/home_page.dart';
import 'package:myapp/ui/widgets/song_options_modal_buttom_sheet.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int searchLength = 0;
  static List<Song> searchResults = List();
  TextEditingController textEditingController = TextEditingController();
  ImageProvider songImage;
  FocusNode focusNode = FocusNode();
  String hintText = "Search";
  Playlist searchResultsPlaylist;
  @override
  void initState() {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        hintText = "";
      } else {
        hintText = "Search";
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    focusNode.removeListener(() {});
    textEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF141414),
              Color(0xFF363636),
            ],
            begin: FractionalOffset.bottomCenter,
            stops: [0.4, 1.0],
            end: FractionalOffset.topCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.grey[700],
                child: Row(
                  children: <Widget>[
                    IconButton(
                      iconSize: 35,
                      icon: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Flexible(
                      child: Container(
                        child: TextField(
                          controller: textEditingController,
                          autofocus: true,
                          focusNode: focusNode,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          cursorColor: Constants.pinkColor,
                          decoration: InputDecoration.collapsed(
                            hintText: hintText,
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          onChanged: (txt) {
                            if (txt != "") {
                              FetchData.searchForResultsSitePage1(txt)
                                  .then((results) {
                                setState(() {
                                  if (results != null) {
                                    searchResults = results;
                                    searchResultsPlaylist =
                                        Playlist("Search Playlist");
                                    searchResultsPlaylist.setSongs =
                                        searchResults;
                                    searchLength = searchResults.length;
                                  }
                                });
                              });
                            }
                          },
                          onSubmitted: (txt) =>
                              FetchData.searchForResultsSitePage1(txt)
                                  .then((results) {
                                setState(() {
                                  if (results != null) {
                                    searchResults = results;
                                    searchResultsPlaylist =
                                        Playlist("Search Playlist");
                                    searchResultsPlaylist.setSongs =
                                        searchResults;
                                    searchLength = searchResults.length;
                                  }
                                });
                              }),
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 25,
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          textEditingController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(accentColor: Colors.grey),
                  child: ListView.builder(
                    itemCount: searchLength,
                    itemExtent: 60,
                    itemBuilder: (BuildContext context, int index) {
                      return songSearchResult(searchResults[index], context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile songSearchResult(Song song, BuildContext context) {
    String title;
    String artist;
    if (song.getTitle.length > 32) {
      int pos = song.getTitle.lastIndexOf("", 32);
      if (pos < 25) {
        pos = 30;
      }
      title = song.getTitle.substring(0, pos) + "...";
    } else {
      title = song.getTitle;
    }
    if (song.getArtist.length > 40) {
      int pos = song.getArtist.lastIndexOf("", 40);
      if (pos < 25) {
        pos = 40;
      }
      artist = song.getArtist.substring(0, pos) + "...";
    } else {
      artist = song.getArtist;
    }
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        artist,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_vert),
        color: Colors.white,
        iconSize: 30,
        onPressed: () {
          showMoreOptions(song);
        },
      ),
      onTap: () async {
        Playlist temp = Playlist(searchResultsPlaylist.getName);
        temp.setSongs = searchResultsPlaylist.getSongs;
        FocusScope.of(context).requestFocus(FocusNode());
        if (song.getImageUrl.length == 0) {
          String imageUrl = await FetchData.getSongImageUrl(song);
          song.setImageUrl = imageUrl;
        }
        audioPlayerManager.initSong(
          song,
          temp,
          PlaylistMode.loop,
        );

        audioPlayerManager.playSong();
      },
    );
  }

  void showMoreOptions(Song song) {
    showModalBottomSheet(
      context: homePageContext,
      builder: (builder) {
        return SongOptionsModalSheet(
          song,
          searchResultsPlaylist,
          false,
        );
      },
    );
  }
}
