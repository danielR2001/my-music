import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:myapp/main.dart';
import 'package:myapp/ui/playlists_pick_page.dart';
import 'home_page.dart';

class MusicPlayerPage extends StatefulWidget {
  @override
  MusicPageState createState() => MusicPageState();
}

class MusicPageState extends State<MusicPlayerPage> {
  Icon playOrPause;

  @override
  void initState() {
    super.initState();
    initSong();
    changePlayingIconState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: backButtonHandle,
      child: Scaffold(
        body: new Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors: [
                Color(0xE4000000),
                Colors.pink,
              ],
              begin: FractionalOffset.bottomCenter,
              stops: [0.5, 1.0],
              end: FractionalOffset.topCenter,
            ),
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 15, right: 15),
                child: Row(
                  children: <Widget>[
                    new IconButton(
                      iconSize: 40,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                      onPressed: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()),
                            )
                          },
                    ),
                    Expanded(
                      child: new Container(),
                    ),
                    new IconButton(
                        iconSize: 30,
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          showMoreOptions();
                        }),
                  ],
                ),
              ),
              new Expanded(
                child: new Container(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                        width: 300,
                        height: 300,
                        decoration: new BoxDecoration(
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.black,
                              blurRadius: 20.0,
                            ),
                          ],
                          image: new DecorationImage(
                            image: songImage(),
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  text(songStatus.currentSong.getSongName, 25, Colors.white),
                  text(songStatus.currentSong.getArtist, 14, Colors.grey)
                ],
              ),
              new Slider(
                  value: songStatus.songPosition.inSeconds.toDouble(),
                  min: 0.0,
                  max: songStatus.songDuration.inSeconds.toDouble(),
                  inactiveColor: Colors.grey[700],
                  activeColor: Colors.white,
                  onChanged: (double value) {
                    setState(() {
                      value = value;
                      seekToSecond(value.toInt());
                    });
                  }),
              new Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: new Text(
                          songStatus.songPosition
                              .toString()
                              .substring(checkSongLength(), 7),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                      Expanded(
                        child: new Text(
                          songStatus.songDuration
                              .toString()
                              .substring(checkSongLength(), 7),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              new Container(
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    new Row(
                      children: <Widget>[
                        IconButton(
                          splashColor: Colors.grey,
                          alignment: Alignment.center,
                          iconSize: 45,
                          icon: new Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                        new IconButton(
                          splashColor: Colors.grey,
                          alignment: Alignment.center,
                          iconSize: 80,
                          icon: playOrPause,
                          onPressed: () {
                            changePlayingMusicState();
                          },
                        ),
                        IconButton(
                          splashColor: Colors.grey,
                          alignment: Alignment.center,
                          iconSize: 45,
                          icon: new Icon(
                            Icons.skip_next,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              new Container(
                child: Padding(
                  padding: new EdgeInsets.only(
                    bottom: 50,
                  ),
                  child: new Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: IconButton(
                          splashColor: Colors.grey,
                          icon: new Icon(
                            Icons.favorite_border,
                            size: 25,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      Expanded(
                        child: new Container(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: IconButton(
                          splashColor: Colors.grey,
                          icon: new Icon(
                            Icons.share,
                            size: 25,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return new Container(
          alignment: Alignment.topCenter,
          color: Color(0xFF000000),
          child: new ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        text(
                          songStatus.currentSong.getSongName,
                          20,
                          Colors.white,
                        ),
                        text(
                          songStatus.currentSong.getArtist,
                          15,
                          Colors.grey,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: new ListTile(
                  leading: new Icon(
                    Icons.favorite_border,
                    color: Colors.grey,
                    size: 30,
                  ),
                  title: new Text(
                    "Like",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: new ListTile(
                  leading: new Icon(
                    Icons.shuffle,
                    color: Colors.grey,
                    size: 30,
                  ),
                  title: new Text(
                    "Shuffle",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  child: new SizedBox(
                    height: 1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: new ListTile(
                  leading: new Icon(
                    Icons.file_download,
                    color: Colors.grey,
                    size: 30,
                  ),
                  title: new Text(
                    "Download",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: new ListTile(
                  leading: new Icon(
                    Icons.playlist_add,
                    color: Colors.grey,
                    size: 30,
                  ),
                  title: new Text(
                    "Add To Playlist",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistPickPage(),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: new ListTile(
                  leading: new Icon(
                    Icons.account_circle,
                    color: Colors.grey,
                    size: 30,
                  ),
                  title: new Text(
                    "View Artist",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: new ListTile(
                  leading: new Icon(
                    Icons.share,
                    color: Colors.grey,
                    size: 30,
                  ),
                  title: new Text(
                    "Share",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void changePlayingMusicState() {
    if (songStatus.isPlaying) {
      setState(() {
        songStatus.pauseSong();
        changePlayingIconState();
      });
    } else {
      setState(() {
        songStatus.resumeSong();
        changePlayingIconState();
      });
    }
  }

  void changePlayingIconState() {
    if (songStatus.isPlaying) {
      setState(
        () {
          playOrPause = Icon(
            Icons.pause_circle_filled,
            color: Colors.white,
          );
        },
      );
    } else {
      setState(
        () {
          playOrPause = Icon(
            Icons.play_circle_filled,
            color: Colors.white,
          );
        },
      );
    }
  }

  void initSong() {
    songStatus.advancedPlayer.durationHandler = (d) => setState(
          () {
            songStatus.songDuration = d;
          },
        );

    songStatus.advancedPlayer.positionHandler = (p) => setState(
          () {
            songStatus.songPosition = p;
          },
        );
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    songStatus.seekTime(newDuration);
  }

  Future<bool> backButtonHandle() {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  int checkSongLength() {
    if (songStatus.songDuration.inMinutes < 59) {
      return 2;
    } else {
      return 0;
    }
  }

  NetworkImage songImage() {
    if (songStatus.currentSong.getImageUrl.length > 0) {
      return new NetworkImage(
        songStatus.currentSong.getImageUrl,
      );
    } else {
      return new NetworkImage(
        'http://musicneedsyou.com/wp-content/uploads/2016/11/audio-engineer-300x200.jpg',
      );
    }
  }

  Widget text(String txt, double size, Color color) {
    if (txt.length < 20) {
      return new Text(
        txt,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size,
          color: color,
        ),
      );
    } else {
      return new Container(
        width: 320,
        height: 29,
        child: new Marquee(
          text: txt,
          scrollAxis: Axis.horizontal,
          style: TextStyle(
            fontSize: size,
            color: color,
          ),
          blankSpace: 30.0,
          velocity: 30.0,
        ),
      );
    }
  }
}
