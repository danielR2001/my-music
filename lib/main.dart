import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ui/welcome_page.dart';
import 'portrait_mode_mixin.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:myapp/song_status.dart';
import 'package:myapp/ui/root_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget with PortraitModeMixin {
  static SongStatus songStatus;
  //static MusicControlNotification musicControlNotification;
  @override
  Widget build(BuildContext context) {
    init();
    super.build(context);
    return MaterialApp(
      title: 'My Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: RootPage(),
    );
  }

  void init() {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    songStatus = new SongStatus(); //init song status
    //musicControlNotification = new MusicControlNotification();
    //musicControlNotification.initListeners();
  }
}
