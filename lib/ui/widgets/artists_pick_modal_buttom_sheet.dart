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
  bool canceled = false;
  bool loadingArtists = false;
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
                    image: widget.artists[index].getImageUrl.length > 0
                        ? NetworkImage(widget.artists[index].getImageUrl)
                        : NetworkImage(
                            'https://static.bbc.co.uk/music_clips/3.0.29/img/default_artist_images/pop1.jpg',
                          ),
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
          canceled = false;
          List<Song> songs = List();
          showLoadingBar(context);
          if (widget.artists[index].getId != null) {
            FetchData.getArtistInfoPage(widget.artists[index]).then((artist) {
              if (!canceled && artist != null) {
                FetchData.getSearchResults(artist.getName).then((results) {
                  if (!canceled) {
                    if (results != null && results[artist.getName] != null) {
                      results[artist.getName].forEach((song) {
                        if (song.getArtist
                                .toLowerCase()
                                .contains(artist.getName.toLowerCase()) ||
                            song.getTitle
                                .toLowerCase()
                                .contains(artist.getName.toLowerCase())) {
                          songs.add(song);
                        }
                      });
                      Playlist temp = Playlist(artist.getName + " Top Hits");
                      temp.setSongs = songs;
                      Provider.of<PageNotifier>(context)
                          .setCurrentPlaylistPagePlaylist = temp;
                    }
                    loadingArtists = true;
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    Navigator.push(
                      GlobalVariables.homePageContext,
                      MaterialPageRoute(
                          builder: (context) => ArtistPage(artist)),
                    );
                  }
                });
              } else {
                if (artist == null) {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                }
              }
            });
          } else {
            Provider.of<PageNotifier>(context).currentPlaylistPagePlaylist =
                Playlist(widget.artists[index].getName + " Top Hits");
            FetchData.getSearchResults(widget.artists[index].getName)
                .then((results) {
              if (!canceled) {
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
                loadingArtists = true;
                Navigator.of(context, rootNavigator: true).pop('dialog');
                Navigator.push(
                  GlobalVariables.homePageContext,
                  MaterialPageRoute(
                    builder: (context) => ArtistPage(widget.artists[index]),
                  ),
                );
              }
            });
          }
        },
      ),
    );
  }

  void showLoadingBar(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(0.0),
          backgroundColor: Colors.transparent,
          children: <Widget>[
            Container(
              width: 60.0,
              height: 60.0,
              alignment: AlignmentDirectional.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
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
                ],
              ),
            )
          ],
        );
      },
    ).then((a) {
      if (!loadingArtists) {
        canceled = true;
        Navigator.of(context, rootNavigator: true).pop('dialog');
      } else {
        loadingArtists = false;
      }
    });
  }
}
