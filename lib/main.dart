import 'package:flutter/material.dart';
import 'ui/welcome_page.dart';
import 'portrait_mode_mixin.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:myapp/song_status.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget with PortraitModeMixin {
  static SongStatus songStatus;
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    songStatus = new SongStatus(); //init song status
    super.build(context);
    return MaterialApp(
      title: 'My Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: WelcomePage(),
    );
  }
}
