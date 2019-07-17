import 'package:flutter/material.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
import 'package:myapp/main.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/ui/widgets/song_options_modal_buttom_sheet.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int searchLength = 0;
  List<Song> searchResults = List();
  TextEditingController textEditingController = TextEditingController();
  ImageProvider songImage;
  String hintText = "Search";
  Playlist searchResultsPlaylist;
  int lastSearchId = 0;
  TextDirection textDirection = TextDirection.ltr;
  @override
  void initState() {
    if (GlobalVariables.lastSearch != null) {
      FetchData.getSearchResults(GlobalVariables.lastSearch).then((results) {
        setState(() {
          if (results != null) {
            searchResults = results[GlobalVariables.lastSearch];
            searchResultsPlaylist = Playlist("Search Playlist");
            searchResultsPlaylist.setSongs = searchResults;
            searchLength = searchResults.length;
          }
        });
      });
    }
    super.initState();
  }

  @override
  void dispose() {
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
                          autofocus: true,
                          textDirection: textDirection,
                          controller: textEditingController,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          cursorColor: GlobalVariables.pinkColor,
                          decoration: InputDecoration.collapsed(
                           hintText: hintText,
                           hintStyle: TextStyle(
                             color: Colors.white,
                             fontSize: 18,
                           ),
                         ),
                          onChanged: (txt) {
                            if (RegExp(r"^[א-ת0-9\$!?&\()\[\]/,\-#\+'= ]+$")
                                .hasMatch(txt)) {
                              setState(() {
                                textDirection = TextDirection.rtl;
                              });
                            } else {
                              setState(() {
                                textDirection = TextDirection.ltr;
                              });
                            }
                            if (txt != "") {
                              FetchData.getSearchResults(txt).then((results) {
                                setState(() {
                                  if (results != null && results[txt] != null) {
                                    searchResults = results[txt];
                                    GlobalVariables.lastSearch = txt;
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
                              FetchData.getSearchResults(txt).then((results) {
                            setState(() {
                              if (results != null && results[txt] != null) {
                                searchResults = results[txt];
                                GlobalVariables.lastSearch = txt;
                                searchResultsPlaylist =
                                    Playlist("Search Playlist");
                                searchResultsPlaylist.setSongs = searchResults;
                                searchLength = searchResults.length;
                              }
                            });
                          }),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: IconButton(
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
                    ),
                  ],
                ),
              ),
              Expanded(
                child:  
                  ListView.builder(
                    itemCount: searchLength,
                    itemExtent: 60,
                    itemBuilder: (BuildContext context, int index) {
                      return songSearchResult(searchResults[index], context);
                    },
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
    if (song.getTitle.length > 28) {
      int pos = song.getTitle.lastIndexOf("", 28);
      if (pos < 20) {
        pos = 28;
      }
      title = song.getTitle.substring(0, pos) + "...";
    } else {
      title = song.getTitle;
    }
    if (song.getArtist.length > 36) {
      int pos = song.getArtist.lastIndexOf("", 36);
      if (pos < 26) {
        pos = 36;
      }
      artist = song.getArtist.substring(0, pos) + "...";
    } else {
      artist = song.getArtist;
    }
    return ListTile(
      contentPadding: EdgeInsets.only(left: 20, right: 4),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        artist,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
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
        if (audioPlayerManager.isSongLoaded) {
          Playlist temp = Playlist(searchResultsPlaylist.getName);
          temp.setSongs = searchResultsPlaylist.getSongs;
          FocusScope.of(context).requestFocus(FocusNode());
          audioPlayerManager.initSong(
            song: song,
            playlist: temp,
            playlistMode: PlaylistMode.loop,
          );
        }
      },
    );
  }

  void showMoreOptions(Song song) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: GlobalVariables.homePageContext,
      builder: (builder) {
        return SongOptionsModalSheet(
          song,
          searchResultsPlaylist,
          false,
          SongModalSheetMode.download_public_search_artist,
        );
      },
    );
  }
}
