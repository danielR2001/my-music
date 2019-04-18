import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'home_page.dart';
import 'dart:math';

class MusicPlayerPage extends StatefulWidget {
  @override
  MusicPageState createState() => MusicPageState();
}

class MusicPageState extends State<MusicPlayerPage> {
  Icon playOrPause;
  //String songDuration;

  @override
  void initState() {
    super.initState();
    initSong();
    changeIconState();
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
                Colors.blue[900],
              ],
              begin: FractionalOffset.bottomRight,
              stops: [0.7, 1.0],
              end: FractionalOffset.topLeft,
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
                      onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          ),
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
                        onPressed: () {}),
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
                            image: new AssetImage(
                              "assets/images/music_player_pic.png",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Column(children: <Widget>[
                new Text(
                  MyApp.songStatus.currentSong.songName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                new Text(
                  MyApp.songStatus.currentSong.artist,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ]),
              new Slider(
                  value: MyApp.songStatus.songPosition.inSeconds.toDouble(),
                  min: 0.0,
                  max: MyApp.songStatus.songDuration.inSeconds.toDouble(),
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
                          MyApp.songStatus.songPosition
                              .toString()
                              .substring(2, 7),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                      Expanded(
                        child: new Text(
                          MyApp.songStatus.songDuration
                              .toString()
                              .substring(2, 7),
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

  void changePlayingMusicState() {
    if (MyApp.songStatus.isPlaying) {
      setState(() {
        MyApp.songStatus.pauseSong();
        changeIconState();
      });
    } else {
      setState(() {
        MyApp.songStatus.resumeSong();
        changeIconState();
      });
    }
  }

  void changeIconState() {
    if (MyApp.songStatus.isPlaying) {
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
    MyApp.songStatus.advancedPlayer.durationHandler = (d) => setState(
          () {
            MyApp.songStatus.songDuration = d;
          },
        );

    MyApp.songStatus.advancedPlayer.positionHandler = (p) => setState(
          () {
            MyApp.songStatus.songPosition = p;
          },
        );
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    MyApp.songStatus.seekTime(newDuration);
  }

  Future<bool> backButtonHandle() {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }
}
