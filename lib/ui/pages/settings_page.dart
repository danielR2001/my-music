import 'package:flutter/material.dart';
import 'package:myapp/firebase/authentication.dart';
import 'package:myapp/main.dart';
import 'package:myapp/ui/pages/welcome_page.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xEA000000),
              Colors.pink,
            ],
            begin: FractionalOffset.bottomRight,
            stops: [0.7, 1.0],
            end: FractionalOffset.topLeft,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FlatButton(
              color: Colors.pink,
              child: Text(
                "Sign Out",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                FirebaseAuthentication.signOut().then((user) {
                  audioPlayerManager.closeSong();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WelcomePage(),
                      ));
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
