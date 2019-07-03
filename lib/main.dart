import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/communicate_with_native/music_control_notification.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/ui/decorations/portrait_mode_mixin.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/ui/pages/root_page.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/communicate_with_native/internet_connection_check.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());
AudioPlayerManager audioPlayerManager;
User currentUser;
List<Playlist> publicPlaylists;

class MyApp extends StatelessWidget with PortraitModeMixin {
  @override
  Widget build(BuildContext context) {
    init(context);
    super.build(context);
    return ChangeNotifierProvider<PageNotifier>(
      builder: (BuildContext context) {
        return PageNotifier();
      },
      child: MaterialApp(
      title: 'My Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        canvasColor: Colors.transparent,
      ),
      home: RootPage(),
      ),
    );
  }

  void init(BuildContext context) async {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    audioPlayerManager = AudioPlayerManager();
    publicPlaylists = new List();
    MusicControlNotification.startService(context);
    InternetConnectionCheck.activateReciever();
  }
}
