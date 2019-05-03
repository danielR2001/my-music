import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/ui/pages/settings_page.dart';
import 'playlist_page.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Color(0xE4000000),
              Colors.pink,
            ],
            begin: FractionalOffset.bottomRight,
            stops: [0.7, 1.0],
            end: FractionalOffset.topLeft,
          ),
        ),
        child: SafeArea(
          child: new Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        currentUser.getName,
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: IconButton(
                        icon: Icon(
                          Icons.settings,
                          size: 30,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsPage(),
                              ));
                        },
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 0,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              new ListTile(
                leading: Icon(
                  Icons.save_alt,
                  color: Colors.white,
                  size: 30,
                ),
                title: Text(
                  "Downloaded",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white,
                ),
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => PlayListPage(
                  //             playlistName: "Downloaded",
                  //             imagePath: "",
                  //           ),
                  //     ));
                },
              ),
              createSpace(25),
              new ListTile(
                leading: Icon(
                  Icons.queue_music,
                  color: Colors.white,
                  size: 30,
                ),
                title: Text(
                  "My Playlists",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                trailing: Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                ),
                onTap: () {},
              ),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(accentColor: Colors.grey),
                  child: new ListView.builder(
                    itemCount: currentUser.getMyPlaylists.length,
                    itemBuilder: (BuildContext context, int index) {
                      return userPlaylists(
                          currentUser.getMyPlaylists[index], context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox createSpace(double space) {
    return new SizedBox(
      height: space,
    );
  }

  Padding userPlaylists(Playlist playlist, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 40,
        bottom: 20,
      ),
      child: new ListTile(
        leading: new Container(
          width: 70.0,
          height: 70.0,
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              new BoxShadow(
                color: Colors.black,
                blurRadius: 20.0,
              ),
            ],
            image: new DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(
                playlist.getSongs[0].getImageUrl,
              ),
            ),
          ),
        ),
        title: Text(
          playlist.getName,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          color: Colors.white,
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayListPage(
                      playlist: playlist,
                      imagePath: playlist.getSongs[0].getImageUrl,
                    ),
              ));
        },
      ),
    );
  }
}
