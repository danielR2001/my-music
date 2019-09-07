import 'package:flutter/material.dart';
import 'package:myapp/core/enums/page_state.dart';
import 'package:myapp/core/view_models/page_models/search_model.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/pages/base_page.dart';
import 'package:myapp/ui/modal_sheets/song_options_modal_buttom_sheet.dart';
import 'package:myapp/ui/pages/home_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController textEditingController = TextEditingController();
  String hintText = "Search";
  TextDirection textDirection = TextDirection.ltr;

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage<SearchModel>(
      onModelReady: (model) => model.initModel(),
      builder: (context, model, child) => Scaffold(
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
                      drawSearchBar(model),
                      drawClearButton(),
                    ],
                  ),
                ),
                model.state == PageState.Idle
                    ? !model.noResultsFound
                        ? Expanded(
                            child: ListView.builder(
                              itemCount: model.searchResultsPlaylist != null
                                  ? model.searchResultsPlaylist.songs.length
                                  : 0,
                              itemExtent: 60,
                              itemBuilder: (BuildContext context, int index) {
                                return drawSongSearchResult(
                                    model.searchResultsPlaylist.songs[index],
                                    index, model);
                              },
                            ),
                          )
                        : Expanded(
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
                                  CustomColors.pinkColor),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
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

  Widget drawSearchBar(SearchModel model) {
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
          cursorColor: CustomColors.pinkColor,
          decoration: InputDecoration.collapsed(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          onChanged: (txt) async {
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
              await model.getSearchResults(txt);
            }
          },
          onSubmitted: (txt) async {
            if (txt != "") {
              await model.getSearchResults(txt);
            }
          },
        ),
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

  Widget drawSongSearchResult(Song song, int index, SearchModel model) {
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
          showMoreOptions(song, model);
        },
      ),
      onTap: () async {
        await model.play(index);
      },
    );
  }

  void showMoreOptions(Song song, SearchModel model) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: model.tabNavigatorKey.currentContext,
      builder: (builder) {
        return SongOptionsModalSheet(
          song,
          model.searchResultsPlaylist,
          false,
          SongModalSheetMode.download_public_search_artist,
        );
      },
    );
  }
}
