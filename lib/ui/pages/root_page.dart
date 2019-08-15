import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/database/authentication.dart';
import 'package:myapp/database/database_manager.dart';
import 'package:myapp/custom_classes/custom_colors.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/managers/toast_manager.dart';
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
    authenticateWithFirebae();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  //* methods
  void authenticateWithFirebae() {
    FirebaseAuthentication.currentUser().then(
      (user) {
        if (user != null) {
          if (GlobalVariables.isNetworkAvailable) {
            FirebaseDatabaseManager.syncUser(user.uid).then((user) {
              if (user != null && user.name != "") {
                GlobalVariables.currentUser = user;
                GlobalVariables.manageLocalSongs
                    .checkIfStoragePermissionGranted()
                    .then((permissionGranted) {
                  GlobalVariables.manageLocalSongs.initDirs().then((a) {
                    GlobalVariables.manageLocalSongs.syncDownloaded();
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
            GlobalVariables.currentUser = User(user.email, user.uid);
            GlobalVariables.manageLocalSongs
                .checkIfStoragePermissionGranted()
                .then((permissionGranted) {
              GlobalVariables.manageLocalSongs.initDirs().then((a) {
                GlobalVariables.manageLocalSongs.syncDownloaded();
                GlobalVariables.toastManager.makeToast(
                  text: ToastManager.ofllineModeConnection,
                  toastLength: Toast.LENGTH_LONG,
                  backgroundColor: GlobalVariables.toastColor,
                  gravity: ToastGravity.CENTER,
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
}
