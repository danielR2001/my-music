import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/core/view_models/page_models/root_model.dart';
import 'package:myapp/ui/pages/base_page.dart';

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
  RootModel _model;

  @override
  Widget build(BuildContext context) {
    return BasePage<RootModel>(
        onModelReady: (model) {
          _model = model;
          authenticateWithFirebase();
        },
        builder: (context, model, child) => Container());
  }

  //* methods
  Future<void> authenticateWithFirebase() async {
    FirebaseUser firebaseUser = await _model.checkIfLoggedIn();
    if (firebaseUser != null && await _model.login(firebaseUser)) {
      Navigator.pushNamed(
        context,
        "/home",
      );
    } else {
      Navigator.pushNamed(
        context,
        "/welcome",
      );
    }
  }
}
