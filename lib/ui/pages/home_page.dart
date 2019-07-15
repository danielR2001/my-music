import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/ui/decorations/my_custom_icons.dart';
import 'package:myapp/ui/widgets/buttom_navigation_bar.dart';
import 'package:myapp/ui/widgets/sound_bar.dart';
import 'package:myapp/tab_navigation/tab_navigator.dart';
import 'package:provider/provider.dart';
import 'music_player_page.dart';
import 'package:myapp/main.dart';
import 'package:myapp/ui/widgets/text_style.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Icon musicPlayerIcon = Icon(
    MyCustomIcons.pause_icon,
    color: Colors.white,
  );
  StreamSubscription<AudioPlayerState> stateStream;
  Expanded soundBar;
  TabItem currentTab = TabItem.discover;
  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.discover: GlobalKey<NavigatorState>(),
    TabItem.library: GlobalKey<NavigatorState>(),
  };
  //GlobalKey homePagekey = GlobalKey();

  void selectTab(TabItem tabItem) {
    setState(() {
      currentTab = tabItem;
    });
  }

  @override
  void initState() {
    soundBar = drawPausedSoundBar();
    initSong();
    super.initState();
  }

  @override
  void dispose() {
    stateStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GlobalVariables.homePageContext = context;
    return ChangeNotifierProvider<PageNotifier>(
      builder: (BuildContext context) {
        return PageNotifier();
      },
      child: WillPopScope(
        onWillPop: () async {
          if (navigatorKeys[currentTab].currentState.canPop()) {
            await navigatorKeys[currentTab].currentState.maybePop();
          }
          return Future.value(false);
        },
        child: Scaffold(
          body: Stack(children: <Widget>[
            buildOffstageNavigator(TabItem.discover),
            buildOffstageNavigator(TabItem.library),
          ]),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: GlobalVariables.lightGreyColor,
              textTheme: Theme.of(context).textTheme.copyWith(
                    caption: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                musicPlayerControl(),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black),
                    ),
                  ),
                  child: BottomNavigation(
                    currentTab: currentTab,
                    onSelectTab: selectTab,
                  ),
                ),
              ],
            ),
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
    stateStream = audioPlayerManager.audioPlayer.onPlayerStateChanged.listen(
      (AudioPlayerState state) {
        setState(() {
          checkSongStatus(state);
        });
      },
    );
  }

  void changeIconState(bool isPlaying) {
    if (isPlaying) {
      setState(
        () {
          musicPlayerIcon = Icon(
            MyCustomIcons.pause_icon,
            color: Colors.white,
          );
          soundBar = drawPlayingSoundBar();
        },
      );
    } else {
      setState(
        () {
          musicPlayerIcon = Icon(
            MyCustomIcons.play_icon,
            color: Colors.white,
          );
          soundBar = drawPausedSoundBar();
        },
      );
    }
  }

  void checkSongStatus(AudioPlayerState state) {
    if (state == AudioPlayerState.PLAYING) {
      changeIconState(true);
    } else if (state == AudioPlayerState.PAUSED) {
      changeIconState(false);
    } else if (state == AudioPlayerState.STOPPED) {
      changeIconState(false);
    } else if (state == null) {
      changeIconState(false);
    }
  }

  Widget musicPlayerControl() {
    if (audioPlayerManager.currentSong != null) {
      return GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: GlobalVariables.lightGreyColor,
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
                            txt: audioPlayerManager.currentSong.getTitle,
                            size: 14,
                            color: Colors.white,
                            txtMaxLength: 20,
                            height: 20,
                            makeBold: true,
                          ),
                          TextDecoration(
                            txt: audioPlayerManager.currentSong.getArtist,
                            size: 14,
                            color: Colors.grey,
                            txtMaxLength: 30,
                            height: 20,
                            makeBold: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: musicPlayerIcon,
                    iconSize: 20,
                    onPressed: () {
                      if (audioPlayerManager.isLoaded &&
                          audioPlayerManager.songPosition !=
                              Duration(milliseconds: 0)) {
                        audioPlayerManager.audioPlayer.state ==
                                AudioPlayerState.PLAYING
                            ? audioPlayerManager.pauseSong(
                                calledFromNative: false)
                            : audioPlayerManager.audioPlayer.state ==
                                    AudioPlayerState.PAUSED
                                ? audioPlayerManager.resumeSong(
                                    calledFromNative: false)
                                : playSong();
                      }
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
      return Container();
    }
  }

  void playSong() {
    audioPlayerManager.initSong(
      song: audioPlayerManager.currentSong,
      playlist: audioPlayerManager.currentPlaylist,
      playlistMode: audioPlayerManager.playlistMode,
    );
  }

  Widget drawPausedSoundBar() {
    return Expanded(
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
  }

  Widget drawPlayingSoundBar() {
    return Expanded(
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
  }
}
