import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'portrait_mode_mixin.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:myapp/song_status.dart';
import 'package:myapp/ui/root_page.dart';
import 'package:myapp/models/user.dart';

void main() => runApp(MyApp());
SongStatus songStatus;
User currentUser;

class MyApp extends StatelessWidget with PortraitModeMixin {
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
