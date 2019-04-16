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
  MusicPlayerPage musicPage;
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
    musicPage = MusicPlayerPage();
    accountPage = AccountPage();
    pages = [
      discoverPage,
      musicPage,
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
                    Icons.music_note,
                    size: 30.0,
                  ),
                  title: new Text("Playing"),
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
        persistentFooterButtons: [
          Container(
            child: Row(
              children: <Widget>[
                new Text(
                  "Alone" + " - " + "Alan Walker",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                new IconButton(
                  icon: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                )
              ],
            ),
          ),
        ],
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
