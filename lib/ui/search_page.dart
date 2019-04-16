import 'package:flutter/material.dart';
import 'package:myapp/modules/artist.dart';
import 'package:myapp/modules/song.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Artist artist = new Artist("Marshmello");
  Song song = new Song("Friends", "Marshmello");
  TextEditingController textEditingController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        alignment: Alignment.centerLeft,
        color: Color(0xFA000000),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                right: 20,
              ),
              child: Container(
                color: Colors.grey[850],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            songSearchResult(song),
            artistSearchResult(artist)
          ],
        ),
      ),
    );
  }

  ListTile songSearchResult(Song song) {
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
