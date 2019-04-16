import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

//import 'dart:async';
//import 'package:audioplayer/audioplayer.dart';

class MusicPlayerPage extends StatefulWidget {
  @override
  MusicPageState createState() => MusicPageState();
}

enum PlayerState { stopped, playing, paused }

class MusicPageState extends State<MusicPlayerPage> {
  static AudioPlayer advancedPlayer;
  AudioCache audioCache;
  String localFilePath;
  Duration songDuration = new Duration();
  Duration songPosition = new Duration();

  double musicValue = 0;
  Icon playOrPause = Icon(
    Icons.play_circle_filled,
    color: Colors.white,
  );
  bool playingMusic = false;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: const EdgeInsets.only(
                top: 40,
              ),
              child: Card(
                shape: Border(
                    bottom: BorderSide(
                  color: Colors.grey,
                )),
                elevation: 0,
                color: Colors.transparent,
                child: ListTile(
                  title: new Text(
                    "Alone",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: new Text(
                    "Alan Walker",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
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
            new Slider(
                value: songPosition.inSeconds.toDouble(),
                min: 0.0,
                max: songDuration.inSeconds.toDouble(),
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
                        "00:00",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    Expanded(
                      child: new Text(
                        "00:00",
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
              child: Padding(
                padding: new EdgeInsets.only(
                  bottom: 10,
                ),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: IconButton(
                        splashColor: Colors.grey,
                        icon: new Icon(
                          Icons.favorite_border,
                          size: 30,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                    new Row(
                      children: <Widget>[
                        IconButton(
                          splashColor: Colors.grey,
                          alignment: Alignment.center,
                          iconSize: 60,
                          icon: new Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                        new IconButton(
                          splashColor: Colors.grey,
                          alignment: Alignment.center,
                          iconSize: 60,
                          icon: playOrPause,
                          onPressed: () {
                            setState(() {
                              playingMusic = !playingMusic;
                            });
                            changePlayingMusicState();
                          },
                        ),
                        IconButton(
                          splashColor: Colors.grey,
                          alignment: Alignment.center,
                          iconSize: 60,
                          icon: new Icon(
                            Icons.skip_next,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    Expanded(
                      child: IconButton(
                        splashColor: Colors.grey,
                        icon: new Icon(
                          Icons.playlist_add,
                          size: 30,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void changePlayingMusicState() {
    if (playingMusic) {
      setState(() {
        audioCache.play('songs/alan_walker_alone.mp3');
        advancedPlayer.pause();
        playOrPause = Icon(
          Icons.pause_circle_filled,
          color: Colors.white,
        );
      });
    } else {
      setState(() {
        advancedPlayer.pause();
        playOrPause = Icon(
          Icons.play_circle_filled,
          color: Colors.white,
        );
      });
    }
  }

  void initPlayer() {
    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);

    advancedPlayer.durationHandler = (d) => setState(() {
          songDuration = d;
        });

    advancedPlayer.positionHandler = (p) => setState(() {
          songPosition = p;
        });
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);

    advancedPlayer.seek(newDuration);
  }
}
