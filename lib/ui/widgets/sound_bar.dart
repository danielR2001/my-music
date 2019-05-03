import 'package:flutter/material.dart';

class SpritePainter extends CustomPainter {
  final Animation<double> _animation;

  SpritePainter(this._animation) : super(repaint: _animation);

  void drawRectangle(Canvas canvas, Size size, double value) {
    Color color = Colors.white;

    Rect rect2 =
        new Rect.fromLTRB(0.0, size.height * value, size.width, size.height);
    final Paint paint = new Paint()..color = color;
    canvas.drawRect(rect2, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawRectangle(canvas, size, _animation.value);
  }

  @override
  bool shouldRepaint(SpritePainter oldDelegate) {
    return true;
  }
}

class SoundBar extends StatefulWidget {
  final Duration dur;
  final double height;
  final double width;
  SoundBar(this.dur, this.height, this.width);
  @override
  SoundBarState createState() => new SoundBarState(dur, height, width);
}

class SoundBarState extends State<SoundBar>
    with SingleTickerProviderStateMixin {
  SoundBarState(this.dur, this.height, this.width);
  final Duration dur;
  final double height;
  final double width;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: dur,
    );
    _startAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: new CustomPaint(
          painter: new SpritePainter(_controller),
          child: new SizedBox(
            width: width,
            height: height,
          ),
        ),
      ),
    );
  }
}
