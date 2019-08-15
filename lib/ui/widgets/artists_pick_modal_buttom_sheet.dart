import 'package:flutter/material.dart';
import 'package:myapp/custom_classes/custom_colors.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/ui/pages/artist_page.dart';
import 'package:provider/provider.dart';

class ArtistsPickModalSheet extends StatefulWidget {
  final Song song;
  final List<Artist> artists;
  ArtistsPickModalSheet(this.song, this.artists);

  @override
  _ArtistsPickModalSheetState createState() => _ArtistsPickModalSheetState();
}

class _ArtistsPickModalSheetState extends State<ArtistsPickModalSheet> {
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
      height: (70 * widget.artists.length).toDouble(),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: widget.artists.length,
              itemExtent: 70,
              itemBuilder: (BuildContext context, int index) {
                return drawArtistListTile(index, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  //* widgets
  Widget drawArtistListTile(int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: ListTile(
        leading: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(
                    color: Colors.black,
                    width: 0.2,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(widget.artists[index].imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
        title: Text(
          widget.artists[index].name,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onTap: () {
          List<Song> songs = List();
          Provider.of<PageNotifier>(context).setCurrentPlaylistPagePlaylist =
              null;
          GlobalVariables.apiService
              .getSearchResults(widget.artists[index].name)
              .then((results) {
            if (results != null && results != null) {
              results.forEach((song) {
                if (song.artist
                        .toLowerCase()
                        .contains(widget.artists[index].name.toLowerCase()) ||
                    song.title
                        .toLowerCase()
                        .contains(widget.artists[index].name.toLowerCase())) {
                  songs.add(song);
                }
              });
              Playlist temp =
                  Playlist(widget.artists[index].name + " Top Hits");
              temp.setSongs = songs;
              Provider.of<PageNotifier>(context)
                  .setCurrentPlaylistPagePlaylist = temp;
            }
          });
          Navigator.push(
            GlobalVariables.homePageContext,
            MaterialPageRoute(
                builder: (context) => ArtistPage(widget.artists[index])),
          );
        },
      ),
    );
  }

  //* methods
  List<String> getArtists() {
    if (widget.song.artist.contains(", ") ||
        widget.song.artist.contains("&") ||
        widget.song.artist.contains("feat.")) {
      return widget.song.artist.split(RegExp(" feat. |\, |& |/"));
    } else {
      List<String> artist = List();
      artist.add(widget.song.artist);
      return artist;
    }
  }
}
