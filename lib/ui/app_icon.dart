import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Stack(
      alignment: Alignment.center,
      children: <Widget>[
        new Container(
          height: 60.0,
          width: 60.0,
          decoration: new BoxDecoration(
              borderRadius: new BorderRadius.circular(50.0),
              color: Colors.black),
          child: new Icon(
            Icons.music_note,
            color: Colors.pink,
            size: 35.0,
          ),
        ),
      ],
    );
  }
}
