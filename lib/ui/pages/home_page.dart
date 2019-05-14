import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:myapp/ui/pages/playlist_page.dart';
import 'package:myapp/ui/widgets/sound_bar.dart';
import 'discover_page.dart';
import 'account_page.dart';
import 'music_player_page.dart';
import 'package:myapp/main.dart';
import 'package:myapp/ui/widgets/text_style.dart';

BuildContext homePageContext;

class HomePage extends StatefulWidget {
  final int currentPage;
  HomePage(this.currentPage);
  @override
  _HomePageState createState() => _HomePageState(currentPage);
}

class _HomePageState extends State<HomePage> {
  int currentTab;
  DiscoverPage discoverPage;
  AccountPage accountPage;
  PlaylistPage playlistPage;
  List<Widget> pages;
  Widget currentPage;
  Icon musicPlayerIcon;
  StreamSubscription<AudioPlayerState> stream;
  final int currentPageInt;
  _HomePageState(this.currentPageInt);
  Expanded soundBar;

  @override
  void initState() {
    discoverPage = DiscoverPage();
    accountPage = AccountPage();
    pages = [
      discoverPage,
      accountPage,
    ];
    if (currentPageInt == 0) {
      currentTab = 0;
      currentPage = discoverPage;
    } else {
      currentTab = 1;
      currentPage = accountPage;
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
    homePageContext = context;
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: GestureDetector(
          child: currentPage,
          onPanUpdate: (details) {
            if (currentTab == 0) {
              if (details.delta.dx < -20) {
                setState(
                  () {
                    currentTab = 1;
                    currentPage = pages[1];
                  },
                );
              }
            } else {
              if (details.delta.dx > 20) {
                setState(
                  () {
                    currentTab = 0;
                    currentPage = pages[0];
                  },
                );
              }
            }
          }),
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
    );
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
    if (playingNow.currentSong != null) {
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
                            playingNow.currentSong.getTitle,
                            18,
                            Colors.white,
                            20,
                            25,
                          ),
                          TextDecoration(
                            playingNow.currentSong.getArtist.getName,
                            16,
                            Colors.grey,
                            30,
                            25,
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
      return GestureDetector(
        child: new Container(
          height: 0,
        ),
      );
    }
  }
}
