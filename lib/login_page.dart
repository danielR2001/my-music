import 'package:flutter/material.dart';
import 'app_icon.dart';

class LoginPage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Color(0xE4000000),
              Colors.yellow[900],
            ],
            begin: FractionalOffset.bottomRight,
            stops: [0.7, 1.0],
            end: FractionalOffset.topLeft,
          ),
        ),
        child: new ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                top: 10.0,
              ),
              child: new IconButton(
                alignment: Alignment.topLeft,
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(
                      context,
                      false,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: new AppIcon(),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              child: new Text(
                "My Music",
                style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xff3b5998),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: new ListTile(
                  leading: new Text(
                    "Sign In With FaceBook",
                    style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: new Container(
                    width: 35.0,
                    height: 35.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: ExactAssetImage(
                          "assets/images/facebook_logo.png",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: new ListTile(
                  leading: new Text(
                    "Sign In With Google",
                    style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: new Container(
                    width: 35.0,
                    height: 35.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: ExactAssetImage(
                          "assets/images/google_logo.png",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
