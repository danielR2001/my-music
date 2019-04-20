import 'package:flutter/material.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/fetch_data_from_internet.dart';
import 'package:myapp/main.dart';
import 'music_player_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int searchLength = 0;
  static List<Song> searchResults = new List();
  TextEditingController textEditingController = new TextEditingController();
  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFA000000),
      appBar: AppBar(
        backgroundColor: Color(0xFA000000),
        automaticallyImplyLeading: false,
        elevation: 1,
        actions: <Widget>[
          Flexible(
            child: Container(
              color: Colors.grey[850],
              child: Row(
                children: <Widget>[
                  new IconButton(
                    iconSize: 20,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(),
                      child: new TextField(
                        controller: textEditingController,
                        autofocus: true,
                        obscureText: false,
                        style: new TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        cursorColor: Colors.pink,
                        decoration: new InputDecoration.collapsed(
                          hintText: "Search",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          filled: true,
                          fillColor: Color(0xE400000),
                        ),
                        onSubmitted: (txt) => {
                              searchResults = null,
                              searchLength = 0,
                              FetchData.fetchPost(txt).then((results) {
                                setState(() {
                                  searchResults = results;
                                  if (searchResults.length > 15) {
                                    searchLength = 15;
                                  } else {
                                    searchLength = searchResults.length;
                                  }
                                  //searchLength = searchResults.length;
                                });
                                // searchResults
                                //     .forEach((item) => print(item.toString()));
                              }),
                            },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: new ListView.builder(
        itemCount: searchLength,
        itemBuilder: (BuildContext context, int index) {
          return songSearchResult(searchResults[index], context);
        },
      ),
    );
  }

  static ListTile songSearchResult(Song song, BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.music_note,
        color: Colors.white,
      ),
      title: new Text(
        song.songName,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      subtitle: new Text(
        song.artist,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      onTap: () {
        print("Current Song: " + song.songName + "-" + song.artist);
        MyApp.songStatus.currentSong = song;
        MyApp.songStatus.playSong();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerPage(),
          ),
        );
      },
    );
  }

  ListTile artistSearchResult(Artist artist) {
    return ListTile(
      leading: Icon(
        Icons.account_circle,
        color: Colors.white,
      ),
      title: new Text(
        artist.name,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      trailing: Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
    );
  }
}
