import 'package:flutter/material.dart';
import 'discover_page.dart';
import 'account_page.dart';
import 'music_player_page.dart';
import 'playlist_page.dart';

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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
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
        bottomSheet: GestureDetector(
          child: Container(
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
                            "Alone",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          new Text(
                            "Alan Walker",
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
                    icon: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                )
              ],
            ),
          ),
          onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MusicPlayerPage()),
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
}
