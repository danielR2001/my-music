import 'package:flutter/material.dart';
import 'package:marquee_widget/marquee_widget.dart';

//import 'package:myapp/ui/widgets/marquee_widget.dart';
//import 'package:marquee_flutter/marquee_flutter.dart';
class TextDecoration extends StatelessWidget {
  final String txt;
  final double size;
  final Color color;
  final int txtMaxLength;
  final double height;
  final bool makeBold;
  final double width;
  TextDecoration({
    @required this.txt,
    @required this.size,
    @required this.color,
    @required this.txtMaxLength,
    @required this.height,
    @required this.makeBold,
    @required this.width,
  });
  @override
  Widget build(BuildContext context) {
    if (txt.length < txtMaxLength) {
      return Container(
        width: width,
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
        width: width,
        height: height,
        child: Marquee(
          child: Text(
            txt,
            style: TextStyle(
              fontSize: size,
              color: color,
              fontWeight: makeBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          animationDuration: Duration(seconds: width ~/80),
          backDuration: Duration(seconds: width ~/80),
          pauseDuration: Duration.zero,
          textDirection: TextDirection.ltr,
        ),
      );
    }
  }
}
