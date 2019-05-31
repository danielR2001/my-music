import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/notifications/music_control_notification.dart';
import 'package:myapp/ui/decorations/portrait_mode_mixin.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/ui/pages/root_page.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/models/playlist.dart';

void main() => runApp(MyApp());
AudioPlayerManager audioPlayerManager;
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
    audioPlayerManager = AudioPlayerManager(); //init song status
    MusicControlNotification.startService();
  }
}
