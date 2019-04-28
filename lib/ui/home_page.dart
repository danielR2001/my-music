import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'discover_page.dart';
import 'account_page.dart';
import 'music_player_page.dart';
import 'package:myapp/main.dart';
import 'package:marquee/marquee.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentTab = 0;
  DiscoverPage discoverPage;
  AccountPage accountPage;
  List<Widget> pages;
  Widget currentPage;
  Icon musicPlayerIcon;
  double _height;
  StreamSubscription<AudioPlayerState> stream;

  @override
  void initState() {
    discoverPage = DiscoverPage();
    accountPage = AccountPage();
    pages = [
      discoverPage,
      accountPage,
    ];
    currentPage = discoverPage;
    if (playingNow.currentSong == null) {
      setState(() {
        _height = 65;
      });
    } else {
      setState(() {
        _height = 118;
      });
    }
    initSong();
    super.initState();
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: disableBackButton,
      child: new Scaffold(
        backgroundColor: Colors.grey[850],
        body: currentPage,
        bottomNavigationBar: new Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.grey[850],
            textTheme: Theme.of(context).textTheme.copyWith(
                  caption: new TextStyle(
                    color: Colors.grey,
                  ),
                ),
          ),
          child: Container(
            height: _height,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            child: Column(
              children: <Widget>[
                musicPlayerControl(),
                BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  fixedColor: Colors.white,
                  currentIndex: currentTab,
                  iconSize: 26.0,
                  onTap: (int index) {
                    setState(
                      () {
                        currentTab = index;
                        currentPage = pages[index];
                      },
                    );
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: new Icon(
                        Icons.explore,
                        size: 30.0,
                      ),
                      title: new Text("Discover"),
                    ),
                    BottomNavigationBarItem(
                      icon: new Icon(
                        Icons.account_circle,
                        size: 30.0,
                      ),
                      title: new Text("Account"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> disableBackButton() {
    return Future.value(false);
  }

  void initSong() {
    checkSongStatus(playingNow.advancedPlayer.state);
    stream = playingNow.advancedPlayer.onPlayerStateChanged.listen(
      (AudioPlayerState state) {
        checkSongStatus(state);
      },
    );
  }

  void changeIconState(bool isPlaying) {
    if (isPlaying) {
      setState(
        () {
          musicPlayerIcon = Icon(
            Icons.pause,
            color: Colors.white,
          );
        },
      );
    } else {
      setState(
        () {
          musicPlayerIcon = Icon(
            Icons.play_arrow,
            color: Colors.white,
          );
        },
      );
    }
  }

  void checkSongStatus(AudioPlayerState state) {
    if (state == AudioPlayerState.PLAYING) {
      changeIconState(true);
    } else if (state == AudioPlayerState.PAUSED) {
      changeIconState(false);
    } else if (state == null) {
      changeIconState(false);
    }
  }

  GestureDetector musicPlayerControl() {
    if (playingNow.currentSong != null) {
      setState(() {
        _height = 118;
      });
      return GestureDetector(
          child: new Container(
            decoration: BoxDecoration(
              color: Colors.grey[850],
              border: Border(
                bottom: BorderSide(color: Colors.black),
              ),
            ),
            height: 55,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          text(
                            playingNow.currentSong.getSongName,
                            18,
                            Colors.white,
                            20,
                          ),
                          text(
                            playingNow.currentSong.getArtist,
                            16,
                            Colors.grey,
                            30,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: new IconButton(
                    icon: musicPlayerIcon,
                    iconSize: 30,
                    onPressed: () {
                      playingNow.advancedPlayer.state ==
                              AudioPlayerState.PLAYING
                          ? playingNow.pauseSong()
                          : playingNow.resumeSong();
                    },
                  ),
                )
              ],
            ),
          ),
          onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MusicPlayerPage()),
              ));
    } else {
      setState(() {
        _height = 65;
      });
      return GestureDetector(
        child: new Container(
          height: 0,
        ),
      );
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
        width: 230,
        height: 23,
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
