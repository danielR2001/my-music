import 'package:flutter/material.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/pages/artist_page.dart';
import 'package:myapp/ui/pages/home_page.dart';

class ArtistsPickModalSheet extends StatefulWidget {
  final Song song;
  final List<Artist> artists;
  ArtistsPickModalSheet(this.song, this.artists);

  @override
  _ArtistsPickModalSheetState createState() =>
      _ArtistsPickModalSheetState(song, artists);
}

class _ArtistsPickModalSheetState extends State<ArtistsPickModalSheet> {
  final Song song;
  final List<Artist> artists;
  _ArtistsPickModalSheetState(this.song, this.artists);
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      color: Constants.lightGreyColor,
      height: (70 * artists.length).toDouble(),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(accentColor: Colors.grey),
              child: ListView.builder(
                itemCount: artists.length,
                itemExtent: 70,
                itemBuilder: (BuildContext context, int index) {
                  return artistListTile(index, context);
                },
              ),
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
                    image: artists[index].getImageUrl.length > 0
                        ? NetworkImage(artists[index].getImageUrl)
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
          artists[index].getName,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onTap: () {
          showLoadingBar(context);
          if (artists[index].getId != null) {
            FetchData.getArtistInfoPage(artists[index]).then(
              (artist) {
                Navigator.of(context, rootNavigator: true).pop('dialog');
                Navigator.push(
                  homePageContext,
                  MaterialPageRoute(
                      builder: (context) => ArtistPage(artists[index])),
                );
              },
            );
          } else {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            Navigator.push(
              homePageContext,
              MaterialPageRoute(
                builder: (context) => ArtistPage(artists[index]),
              ),
            );
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
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Center(
                    child: new SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: new CircularProgressIndicator(
                        value: null,
                        strokeWidth: 3.0,
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Constants.pinkColor),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
