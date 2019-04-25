import 'package:flutter/material.dart';
import 'package:myapp/firebase/authentication.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'welcome_page.dart';
import 'home_page.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;
  @override
  void initState() {
    super.initState();
    FirebaseAuthentication.currentUser().then((userId) {
      FirebaseDatabaseManager.syncUser(userId.uid);
      //currentUser = new User(_userName, user.uid);
      //FirebaseDatabaseManager.saveUser();
      //print(currentUser.toString());

      setState(() {
        authStatus =
            userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new WelcomePage();
      case AuthStatus.signedIn:
        return new HomePage();
    }
    return null;
  }
}
