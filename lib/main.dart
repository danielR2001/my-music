import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/ui/decorations/portrait_mode_mixin.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:myapp/playing_now/playing_now.dart';
import 'package:myapp/ui/pages/root_page.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/playlist.dart';

void main() => runApp(MyApp());
PlayingNow playingNow;
User currentUser;
Playlist currentPlayList;

class MyApp extends StatelessWidget with PortraitModeMixin {
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

  void init() async {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    playingNow = new PlayingNow(); //init song status
  }
}
