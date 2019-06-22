import 'package:flutter/material.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/firebase/authentication.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/main.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';
import 'package:myapp/ui/pages/welcome_page.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Constants.darkGreyColor,
              Constants.pinkColor,
            ],
            begin: FractionalOffset.bottomRight,
            stops: [0.7, 1.0],
            end: FractionalOffset.topLeft,
          ),
        ),
        child: SafeArea(
          child: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Container(),
                        flex: 3,
                      ),
                      Text(
                        "   Settings",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Expanded(
                        child: Container(),
                        flex: 5,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    "1.3.2",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      FlatButton(
                        color: Constants.pinkColor,
                        child: Text(
                          "Sign Out",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          showAlertDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "Hii " + currentUser.getName + "!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "If you will proceed with your action all your local songs will be erased.",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        height: 50.0,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Constants.pinkColor,
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        height: 50.0,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Constants.pinkColor,
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Text(
                          "Got it",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        publicPlaylists = List();
                        FirebaseDatabaseManager.cancelStreams().then((a) {
                          ManageLocalSongs.deleteDownloadedDirectory();
                          FirebaseDatabaseManager.changeUserSignInState(false)
                              .then((a) {
                            FirebaseAuthentication.signOut().then((a) {
                              audioPlayerManager.closeSong();
                              currentUser = null;
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WelcomePage(),
                                  ));
                            });
                          });
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          backgroundColor: Colors.grey[850],
        );
      },
    );
  }
}
