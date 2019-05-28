import 'package:flutter/material.dart';
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
                          cursorColor: Colors.pink,
                          decoration: InputDecoration.collapsed(
                            hintText: hintText,
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          onChanged: (txt) {
                            if (txt != "") {
                              FetchData.fetchPost(txt).then((results) {
                                setState(() {
                                  searchResults = results;
                                  if (searchResults != null) {
                                    searchLength = searchResults.length;
                                  } else {
                                    searchLength = 0;
                                  }
                                });
                              });
                            }
                          },
                          onSubmitted: (txt) =>
                              FetchData.fetchPost(txt).then((results) {
                                setState(() {
                                  searchResults = results;
                                  searchLength = searchResults.length;
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
    setSongImage(song);
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
      leading: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: songImage,
            )),
      ),
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
        onPressed: () {
          showMoreOptions(song);
        },
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        FetchData.getRealSongUrl(song).then((streamUrl) {
          song.setStreamUrl = streamUrl;
        });
        audioPlayerManager.playSong(song, null, PlaylistMode.loop);
      },
    );
  }

  void setSongImage(Song song) {
    if (song.getImageUrl.length > 0) {
      songImage = NetworkImage(
        song.getImageUrl,
      );
    } else {
      songImage = AssetImage('assets/images/default_song_pic.png');
    }
  }

  void showMoreOptions(Song song) {
    FetchData.getRealSongUrl(song).then((streamUrl) {
      song.setStreamUrl = streamUrl;
      showModalBottomSheet(
        context: homePageContext,
        builder: (builder) {
          return SongOptionsModalSheet(song, null);
        },
      );
    });
  }
}
