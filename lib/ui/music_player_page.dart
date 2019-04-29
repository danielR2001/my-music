import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:myapp/main.dart';
import 'package:myapp/ui/playlists_pick_page.dart';

class MusicPlayerPage extends StatefulWidget {
  @override
  MusicPageState createState() => MusicPageState();
}

class MusicPageState extends State<MusicPlayerPage> {
  Duration _position;
  Duration _duration;
  Icon musicPlayerIcon;
  StreamSubscription<AudioPlayerState> stream;
  StreamSubscription<Duration> posStream;
  StreamSubscription<Duration> durStream;
  ImageProvider songImage;

  @override
  void initState() {
    super.initState();
    initSong();
  }

  @override
  void dispose() {
    super.dispose();
    posStream.cancel();
    durStream.cancel();
    stream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    setSongImage();
    return Scaffold(
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
                    onPressed: () => {Navigator.pop(context)},
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
                      width: 280,
                      height: 280,
                      decoration: new BoxDecoration(
                        boxShadow: [
                          new BoxShadow(
                            color: Colors.black,
                            blurRadius: 20.0,
                          ),
                        ],
                        image: new DecorationImage(
                          image: songImage,
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
                text(playingNow.currentSong.getSongName, 25, Colors.white, 20),
                text(playingNow.currentSong.getArtist, 14, Colors.grey, 30)
              ],
            ),
            new Slider(
                value: _position != null
                    ? _position.inSeconds <= _duration.inSeconds
                        ? _position.inSeconds.toDouble()
                        : 0.0
                    : 0.0,
                min: 0.0,
                max: _duration != null ? _duration.inSeconds.toDouble() : 0.0,
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
                        _position != null
                            ? _position.inSeconds <= _duration.inSeconds
                                ? _position
                                    .toString()
                                    .substring(checkSongLength(), 7)
                                : "00:00"
                            : "00:00",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    Expanded(
                      child: new Text(
                        _duration != null
                            ? _duration
                                .toString()
                                .substring(checkSongLength(), 7)
                            : "00:00",
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
                        icon: musicPlayerIcon,
                        onPressed: () {
                          playingNow.advancedPlayer.state ==
                                  AudioPlayerState.PLAYING
                              ? playingNow.pauseSong()
                              : playingNow.resumeSong();
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
                          Icons.repeat,
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
                          playingNow.currentSong.getSongName,
                          20,
                          Colors.white,
                          20,
                        ),
                        text(
                          playingNow.currentSong.getArtist,
                          15,
                          Colors.grey,
                          30,
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
                    Icons.repeat,
                    color: Colors.grey,
                    size: 30,
                  ),
                  title: new Text(
                    "Repeat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {},
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
                    Icons.save_alt,
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

  void changePlayingIconState(bool isPlaying) {
    if (isPlaying) {
      setState(
        () {
          musicPlayerIcon = Icon(
            Icons.pause_circle_filled,
            color: Colors.white,
          );
        },
      );
    } else {
      setState(
        () {
          musicPlayerIcon = Icon(
            Icons.play_circle_filled,
            color: Colors.white,
          );
        },
      );
    }
  }

  void checkSongStatus(AudioPlayerState state) {
    if (state == AudioPlayerState.PLAYING) {
      changePlayingIconState(true);
    } else if (state == AudioPlayerState.PAUSED) {
      changePlayingIconState(false);
    } else {
      changePlayingIconState(false);
    }
  }

  void initSong() {
    posStream = playingNow.advancedPlayer.onAudioPositionChanged
        .listen((Duration p) => {setState(() => _position = p)});

    durStream = playingNow.advancedPlayer.onDurationChanged.listen(
      (Duration d) {
        setState(() => _duration = d);
      },
    );
    checkSongStatus(playingNow.advancedPlayer.state);
    stream = playingNow.advancedPlayer.onPlayerStateChanged.listen(
      (AudioPlayerState state) {
        checkSongStatus(state);
      },
    );
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    playingNow.seekTime(newDuration);
  }

  int checkSongLength() {
    if (playingNow.songDuration.inMinutes < 59) {
      return 2;
    } else {
      return 0;
    }
  }

  void setSongImage() {
    if (playingNow.currentSong.getImageUrl.length > 0) {
      songImage = new NetworkImage(
        playingNow.currentSong.getImageUrl,
      );
    } else {
      songImage = new AssetImage('assets/images/default_song_pic_big.png');
    }
  }

  Widget text(String txt, double size, Color color, int txtMaxLength) {
    if (txt.length < txtMaxLength) {
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
        height: 32,
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
