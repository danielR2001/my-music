import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class TextDecoration extends StatelessWidget {
  final String txt;
  final double size;
  final Color color;
  final int txtMaxLength;
  final double height;
  TextDecoration(
      this.txt, this.size, this.color, this.txtMaxLength, this.height);
  @override
  Widget build(BuildContext context) {
    if (txt.length < txtMaxLength) {
      return //Container(
          // width: 290,
          //height: 32,
          //child:
          new Text(
        txt,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size,
          color: color,
        ),
        // ),
      );
    } else {
      return new Container(
        width: 290,
        height: height,
        child: new Marquee(
          text: txt,
          scrollAxis: Axis.horizontal,
          style: TextStyle(
            fontSize: size,
            color: color,
          ),
          blankSpace: 30.0,
          velocity: 30.0,
        ),
      );
    }
  }
}
