import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/firebase/authentication.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/main.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';
import 'package:myapp/models/user.dart';
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
            if (GlobalVariables.isNetworkAvailable) {
              FirebaseDatabaseManager.syncUser(user.uid).then((user) {
                if (user != null && user.getName != "") {
                  currentUser = user;
                  ManageLocalSongs.checkIfStoragePermissionGranted()
                      .then((permissionGranted) {
                    ManageLocalSongs.initDirs().then((a) {
                      ManageLocalSongs.syncDownloaded();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    });
                  });
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WelcomePage(),
                    ),
                  );
                }
              });
            } else {
              GlobalVariables.isOfflineMode = true;
              currentUser = User(user.email, user.uid);
              ManageLocalSongs.checkIfStoragePermissionGranted()
                  .then((permissionGranted) {
                ManageLocalSongs.initDirs().then((a) {
                  ManageLocalSongs.syncDownloaded();
                  Fluttertoast.showToast(
                    msg: "Connected in oflline mode",
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIos: 1,
                    fontSize: 16.0,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: GlobalVariables.toastColor,
                    textColor: Colors.white,
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                });
              });
            }
          
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
