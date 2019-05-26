import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:myapp/ui/widgets/buttom_navigation_bar.dart';
import 'package:myapp/ui/widgets/sound_bar.dart';
import 'package:myapp/ui/widgets/tab_navigator.dart';
import 'music_player_page.dart';
import 'package:myapp/main.dart';
import 'package:myapp/ui/widgets/text_style.dart';

BuildContext homePageContext;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Icon musicPlayerIcon;
  StreamSubscription<AudioPlayerState> stream;
  Expanded soundBar;
  TabItem currentTab = TabItem.discover;
  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.discover: GlobalKey<NavigatorState>(),
    TabItem.account: GlobalKey<NavigatorState>(),
  };

  void selectTab(TabItem tabItem) {
    setState(() {
      currentTab = tabItem;
    });
  }

  @override
  void initState() {
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
    homePageContext = context;
    return WillPopScope(
      onWillPop: () async {
        if (navigatorKeys[currentTab].currentState.canPop())
          await navigatorKeys[currentTab].currentState.maybePop();
      },
      child: Scaffold(
        body: Stack(children: <Widget>[
          buildOffstageNavigator(TabItem.discover),
          buildOffstageNavigator(TabItem.account),
        ]),
        bottomNavigationBar: new Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.grey[850],
            textTheme: Theme.of(context).textTheme.copyWith(
                  caption: new TextStyle(
                    color: Colors.grey,
                  ),
                ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              musicPlayerControl(),
              BottomNavigation(
                currentTab: currentTab,
                onSelectTab: selectTab,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOffstageNavigator(TabItem tabItem) {
    return Offstage(
      offstage: currentTab != tabItem,
      child: TabNavigator(
        navigatorKey: navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }

  void initSong() {
    checkSongStatus(audioPlayerManager.advancedPlayer.state);
    stream = audioPlayerManager.advancedPlayer.onPlayerStateChanged.listen(
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
          soundBar = Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 8,
                  height: 50,
                  child: SoundBar(Duration(milliseconds: 400), 15.0, 5.0),
                ),
                Container(
                  width: 8,
                  height: 50,
                  child: SoundBar(Duration(milliseconds: 450), 15.0, 5.0),
                ),
                Container(
                  width: 8,
                  height: 50,
                  child: SoundBar(Duration(milliseconds: 350), 15.0, 5.0),
                ),
              ],
            ),
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
          soundBar = Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  color: Colors.white,
                  width: 5,
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    color: Colors.white,
                    width: 5,
                    height: 15,
                  ),
                ),
                Container(
                  color: Colors.white,
                  width: 5,
                  height: 5,
                ),
              ],
            ),
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
    if (audioPlayerManager.currentSong != null) {
      return GestureDetector(
          child: new Container(
            decoration: BoxDecoration(
              color: Colors.grey[850],
              border: Border(
                bottom: BorderSide(color: Colors.black),
              ),
            ),
            height: 45,
            child: Row(
              children: <Widget>[
                soundBar,
                Expanded(
                  flex: 5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextDecoration(
                            audioPlayerManager.currentSong.getTitle,
                            15,
                            Colors.white,
                            20,
                            20,
                          ),
                          TextDecoration(
                            audioPlayerManager.currentSong.getArtist,
                            15,
                            Colors.grey,
                            30,
                            20,
                          ),
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
                      audioPlayerManager.advancedPlayer.state ==
                              AudioPlayerState.PLAYING
                          ? audioPlayerManager.pauseSong()
                          : audioPlayerManager.resumeSong();
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
      return GestureDetector(
        child: new Container(
          height: 0,
        ),
      );
    }
  }
}
