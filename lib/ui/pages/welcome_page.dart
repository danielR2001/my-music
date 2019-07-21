import 'dart:math';

import 'package:flutter/material.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'sign_up_page.dart';
import 'log_in_page.dart';

class WelcomePage extends StatelessWidget {
  final List<String> quotes = [
    "“One good thing about music, when it hits you, you feel no pain.”",
    "“Music gives a soul to the universe, wings to the mind, flight to the imagination and life to everything.”",
    "“Without music, life would be a mistake.”",
    "“I didn’t have nothin’ going for me… school, home… until I found something I loved, which was music, and that changed everything.”",
    "“It's really interesting how music can knock down a wall and be an open connection between you and someone else where something else can't. When music comes along, it just opens your heart a little more.”",
    "“Music has healing power. It has the ability to take people out of themselves for a few hours.”",
    "“Music is a world within itself, with a language we all understand.”",
    "“To live is to be musical, starting with the blood dancing in your veins. Everything living has a rhythm. Do you feel your music?”",
    "“Music is my religion.”",
    "“I need music. It’s like my heartbeat, so to speak. It keeps me going no matter what’s going on – bad games, press, whatever!”"
  ];
  final List<String> authors = [
    '- Bob Marley',
    '- Plato',
    '- Friedrich Nietzsche',
    '- Eminem',
    '- Philip Sweet',
    '- Elton John',
    '- Stevie Wonder',
    '- Michael Jackson',
    '- Jimi Hendrix',
    '- LeBron James'
  ];
  @override
  Widget build(BuildContext context) {
    int index;
    var rnd = Random();
    index = rnd.nextInt(quotes.length);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple,
              GlobalVariables.pinkColor,
            ],
            begin: FractionalOffset.bottomRight,
            stops: [0.4, 1.0],
            end: FractionalOffset.topLeft,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 70.0,
                bottom: 25,
              ),
              child: drawAppLogo(),
            ),
            drawAppName(),
            drawSeperatingLine(),
            drawFamousQuotes(index),
            drawSeperatingLine(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                drawLoginButton(context),
                drawSignInButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //* widgets
  Widget drawAppLogo() {
    return Container(
      height: 60,
      width: 60,
      child: Image(
        image: AssetImage("assets/images/app_logo.png"),
      ),
    );
  }

  Widget drawAppName() {
    return Text(
      "My Music",
      style: TextStyle(
        fontSize: 30.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget drawFamousQuotes(int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Text(
                quotes[index],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  authors[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget drawLoginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 40.0,
        vertical: 15.0,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LogInPage(),
              ));
        },
        child: Container(
          alignment: Alignment.center,
          height: 60.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40.0),
          ),
          child: Text(
            "Log In",
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget drawSignInButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 40.0,
        right: 40.0,
        bottom: 25.0,
        top: 15,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignUpPage(),
              ));
        },
        child: Container(
          alignment: Alignment.center,
          height: 60.0,
          decoration: BoxDecoration(
            color: GlobalVariables.pinkColor,
            borderRadius: BorderRadius.circular(40.0),
          ),
          child: Text(
            "Sign Up",
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget drawSeperatingLine() {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Container(
        height: 1,
        width: 370,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
