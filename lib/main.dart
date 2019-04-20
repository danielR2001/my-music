import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ui/welcome_page.dart';
import 'portrait_mode_mixin.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:myapp/song_status.dart';
import 'music_control_notification.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget with PortraitModeMixin {
  BuildContext context;
  static SongStatus songStatus;
  static MusicControlNotification musicControlNotification;
  @override
  Widget build(BuildContext context) {
    this.context = context;
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    songStatus = new SongStatus(); // init song status
    musicControlNotification = new MusicControlNotification();
    musicControlNotification.initListeners();
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
