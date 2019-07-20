import 'package:flutter/material.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
import 'package:myapp/global_variables/global_variables.dart';
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
                return artistListTile(index, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> getArtists() {
    if (widget.song.getArtist.contains(", ") ||
        widget.song.getArtist.contains("&") ||
        widget.song.getArtist.contains("feat.")) {
      return widget.song.getArtist.split(RegExp(" feat. |\, |& |/"));
    } else {
      List<String> artist = new List();
      artist.add(widget.song.getArtist);
      return artist;
    }
  }

  Padding artistListTile(int index, BuildContext context) {
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
                    image: NetworkImage(widget.artists[index].getImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
        title: Text(
          widget.artists[index].getName,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onTap: () {
          List<Song> songs = List();
          Provider.of<PageNotifier>(context).setCurrentPlaylistPagePlaylist =
              null;
          FetchData.getSearchResults(widget.artists[index].getName)
              .then((results) {
            if (results != null &&
                results[widget.artists[index].getName] != null) {
              results[widget.artists[index].getName].forEach((song) {
                if (song.getArtist.toLowerCase().contains(
                        widget.artists[index].getName.toLowerCase()) ||
                    song.getTitle.toLowerCase().contains(
                        widget.artists[index].getName.toLowerCase())) {
                  songs.add(song);
                }
              });
              Playlist temp =
                  Playlist(widget.artists[index].getName + " Top Hits");
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
}
