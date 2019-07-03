import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class TextDecoration extends StatelessWidget {
  final String txt;
  final double size;
  final Color color;
  final int txtMaxLength;
  final double height;
  final bool makeBold;
  TextDecoration(
      {this.txt,
      this.size,
      this.color,
      this.txtMaxLength,
      this.height,
      this.makeBold});
  @override
  Widget build(BuildContext context) {
    if (txt.length < txtMaxLength) {
      return Container(
        width: 280,
        height: height,
        child: Text(
          txt,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size,
            color: color,
            fontWeight: makeBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    } else {
      return Container(
        width: 280,
        height: height,
        child: Marquee(
          text: txt,
          scrollAxis: Axis.horizontal,
          style: TextStyle(
            fontSize: size,
            color: color,
            fontWeight: makeBold ? FontWeight.bold : FontWeight.normal,
          ),
          blankSpace: 30.0,
          velocity: 30.0,
        ),
      );
    }
  }
}
