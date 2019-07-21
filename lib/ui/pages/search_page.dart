import 'package:flutter/material.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
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
  String hintText = "Search";
  Playlist searchResultsPlaylist;
  TextDirection textDirection = TextDirection.ltr;
  bool loadingResults = false;
  bool noResultsFound = false;

  @override
  void initState() {
    if (GlobalVariables.lastSearch != null) {
      loadingResults = true;
      noResultsFound = false;
      GlobalVariables.apiService
          .getSearchResults(GlobalVariables.lastSearch)
          .then((results) {
        setState(() {
          if (results != null) {
            loadingResults = false;
            searchResults = results;
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
                    drawBackButton(),
                    drawSearchBar(),
                    drawClearButton(),
                  ],
                ),
              ),
              !loadingResults
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: searchLength,
                        itemExtent: 60,
                        itemBuilder: (BuildContext context, int index) {
                          return drawSongSearchResult(
                              searchResults[index], context);
                        },
                      ),
                    )
                  : noResultsFound
                      ? Expanded(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              Text(
                                "No results found!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "please check your spelling, or try different key words.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ]))
                      : Expanded(
                          child: Center(
                            child: SizedBox(
                              height: 50.0,
                              width: 50.0,
                              child: CircularProgressIndicator(
                                value: null,
                                strokeWidth: 3.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    GlobalVariables.pinkColor),
                              ),
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  //* widgets
  Widget drawBackButton() {
    return IconButton(
      iconSize: 35,
      icon: Icon(
        Icons.chevron_left,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget drawSearchBar() {
    //! TODO fix bug
    return Flexible(
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
              searchLength = 0;
              searchResults = List();
              loadingResults = true;
              noResultsFound = false;
              if (RegExp(r"^[א-ת0-9\$!?&\()\[\]/,\-#\+'= ]+$").hasMatch(txt)) {
                setState(() {
                  textDirection = TextDirection.rtl;
                });
              } else {
                setState(() {
                  textDirection = TextDirection.ltr;
                });
              }
              if (txt != "") {
                GlobalVariables.apiService
                    .getSearchResults(txt)
                    .then((results) {
                  setState(() {
                    if (results != null) {
                      if (results.length > 0) {
                        loadingResults = false;
                        searchResults = results;
                        GlobalVariables.lastSearch = txt;
                        searchResultsPlaylist = Playlist("Search Playlist");
                        searchResultsPlaylist.setSongs = searchResults;
                        searchLength = searchResults.length;
                      }
                    } else {
                      noResultsFound = true;
                    }
                  });
                });
              }
            },
            onSubmitted: (txt) {
              loadingResults = true;
              noResultsFound = false;
              GlobalVariables.apiService.getSearchResults(txt).then((results) {
                setState(() {
                  if (results != null) {
                    if (results.length > 0) {
                      loadingResults = false;
                      searchResults = results;
                      GlobalVariables.lastSearch = txt;
                      searchResultsPlaylist = Playlist("Search Playlist");
                      searchResultsPlaylist.setSongs = searchResults;
                      searchLength = searchResults.length;
                    }
                  } else {
                    noResultsFound = true;
                  }
                });
              });
            }),
      ),
    );
  }

  Widget drawClearButton() {
    return Padding(
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
    );
  }

  Widget drawSongSearchResult(Song song, BuildContext context) {
    String title;
    String artist;
    if (song.title.length > 33) {
      int pos = song.title.lastIndexOf("", 33);
      if (pos < 25) {
        pos = 33;
      }
      title = song.title.substring(0, pos) + "...";
    } else {
      title = song.title;
    }
    if (song.artist.length > 36) {
      int pos = song.artist.lastIndexOf("", 36);
      if (pos < 26) {
        pos = 36;
      }
      artist = song.artist.substring(0, pos) + "...";
    } else {
      artist = song.artist;
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
        if (GlobalVariables.audioPlayerManager.isSongLoaded) {
          Playlist temp = Playlist(searchResultsPlaylist.name);
          temp.setSongs = searchResultsPlaylist.songs;
          FocusScope.of(context).requestFocus(FocusNode());
          GlobalVariables.audioPlayerManager.initSong(
            song: song,
            playlist: temp,
            mode: PlaylistMode.loop,
          );
        }
      },
    );
  }

  //*methods
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
