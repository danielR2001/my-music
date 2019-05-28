import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          height: 60.0,
          width: 60.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0), color: Colors.black),
          child: Icon(
            Icons.music_note,
            color: Colors.pink,
            size: 35.0,
          ),
        ),
      ],
    );
  }
}
