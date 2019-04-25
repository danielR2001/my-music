import 'package:flutter/material.dart';
import 'discover_page.dart';
import 'account_page.dart';
import 'music_player_page.dart';
import 'package:myapp/main.dart';

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
  Icon playOrPause;

  @override
  void initState() {
    changeIconState();
    discoverPage = DiscoverPage();
    accountPage = AccountPage();
    pages = [
      discoverPage,
      accountPage,
    ];
    currentPage = discoverPage;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: disableBackButton,
      child: new Scaffold(
        backgroundColor: Colors.grey[850],
        body: currentPage,
        bottomSheet: musicPlayerControl(),
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
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
            child: BottomNavigationBar(
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
          ),
        ),
      ),
    );
  }

  Future<bool> disableBackButton() {
    return Future.value(false);
  }

  void changePlayingMusicState() {
    if (songStatus != null) {
      if (songStatus.isPlaying) {
        setState(() {
          songStatus.pauseSong();
          changeIconState();
        });
      } else {
        setState(() {
          songStatus.resumeSong();
          changeIconState();
        });
      }
    }
  }

  void changeIconState() {
    if (songStatus.isPlaying) {
      setState(
        () {
          playOrPause = Icon(
            Icons.pause,
            color: Colors.white,
          );
        },
      );
    } else {
      setState(
        () {
          playOrPause = Icon(
            Icons.play_arrow,
            color: Colors.white,
          );
        },
      );
    }
  }

  GestureDetector musicPlayerControl() {
    if (songStatus.currentSong != null) {
      return GestureDetector(
          child: new Container(
            height: 55,
            color: Colors.grey[850],
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
                          new Text(
                            songStatus.currentSong.getSongName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          new Text(
                            songStatus.currentSong.getArtist,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: new IconButton(
                    icon: playOrPause,
                    iconSize: 30,
                    onPressed: () {
                      changePlayingMusicState();
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

  // Text text(String txt) {
  //   //if (txt.length < 20) {
  //   return new Text(
  //     txt,
  //     textAlign: TextAlign.center,
  //     style: TextStyle(
  //       fontSize: 16,
  //       color: Colors.white,
  //     ),
  //   );
  //   } else {
  //   return new Marquee(
  //     text: txt,
  //     style: TextStyle(
  //       fontSize: 16,
  //       color: Colors.white,
  //     ),
  //     // blankSpace: 20,
  //     // velocity: 100,
  //     // pauseAfterRound: Duration(seconds: 1),
  //     // startPadding: 10,
  //     // accelerationDuration: Duration(seconds: 1),
  //     // accelerationCurve: Curves.linear,
  //     // decelerationDuration: Duration(microseconds: 500),
  //     // decelerationCurve: Curves.easeOut,
  //   );
  //   }
  // }
}
