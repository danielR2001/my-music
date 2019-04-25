import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/playlist.dart';
import 'playlist_page.dart';
import 'package:myapp/firebase/authentication.dart';
import 'welcome_page.dart';

class AccountPage extends StatelessWidget {
  final Playlist playlist = new Playlist("My First Playlist");
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
        child: new Column(
          children: <Widget>[
            new ListTile(
              trailing: new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new IconButton(
                    icon: Icon(
                      Icons.notifications,
                      size: 30,
                      color: Colors.grey,
                    ),
                    onPressed: () {},
                  ),
                  new SizedBox(
                    width: 20,
                  ),
                  new IconButton(
                    icon: Icon(
                      Icons.settings,
                      size: 30,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      FirebaseAuthentication.signOut().then((user) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WelcomePage(),
                            ));
                      });
                    },
                  )
                ],
              ),
            ),
            createSpace(15),
            new ListTile(
              leading: new Container(
                width: 30.0,
                height: 30.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: ExactAssetImage(
                      "assets/images/profile_pic.png",
                    ),
                  ),
                ),
              ),
              title: Text(
                "Daniel Rachlin",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                "View Your Profile",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
              ),
            ),
            createSpace(50),
            new ListTile(
              leading: Icon(
                Icons.file_download,
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
                Icons.favorite_border,
                color: Colors.white,
                size: 30,
              ),
              title: Text(
                "Favourites",
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
                //             playlist: "Favourites",
                //             imagePath: "",
                //           ),
                //     ));
              },
            ),
            createSpace(25),
            new ListTile(
              leading: Icon(
                Icons.library_music,
                color: Colors.white,
                size: 30,
              ),
              title: Text(
                "Playlists",
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
            createSpace(25),
            Expanded(
              child: new ListView.builder(
                itemCount: currentUser.getMyPlaylists.length,
                itemBuilder: (BuildContext context, int index) {
                  return userPlaylists(
                      currentUser.getMyPlaylists[index], context);
                },
              ),
            ),
          ],
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
        left: 40,
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
