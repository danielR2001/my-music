import 'package:flutter/material.dart';
import 'package:myapp/firebase/authentication.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/main.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';

import 'welcome_page.dart';
import 'home_page.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

String signUpEmail;
String signUpPassword;
String userName;
bool signIn = true;
String loginInEmail;
String loginInPassword;
enum AuthStatus {
  notSignedIn,
  signedIn,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;
  @override
  void initState() {
    super.initState();
    FirebaseAuthentication.currentUser().then(
      (user) {
        if (user != null) {
          FirebaseDatabaseManager.syncUser(user.uid, true).then(
            (user) {
              if (user != null && user.getName != "") {
                currentUser = user;
                ManageLocalSongs.checkIfStoragePermissionGranted()
                    .then((permissionGranted) {
                  ManageLocalSongs.initDirs().then((a) {
                    ManageLocalSongs.syncDownloaded();
                  });
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomePage(),
                  ),
                );
              }
            },
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomePage(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
