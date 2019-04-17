import 'package:flutter/material.dart';
import 'discover_page.dart';
import 'account_page.dart';
import 'music_player_page.dart';
import 'playlist_page.dart';
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
  void dispose() {
    super.dispose();
  }

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

  void goToAlbum(String genre, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayListPage(
              albumOrArtistOrPlaylist: genre,
              imagePath: imagePath,
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
    if (MyApp.songStatus.currentSong != null) {
      return GestureDetector(
          child: new Container(
            height: 40,
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
                            MyApp.songStatus.currentSong.songName,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          new Text(
                            MyApp.songStatus.currentSong.artist,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
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
}
