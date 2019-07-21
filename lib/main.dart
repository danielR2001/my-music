import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/communicate_with_native/music_control_notification.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/ui/decorations/portrait_mode_mixin.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/ui/pages/root_page.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

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
          accentColor: Colors.grey,
          fontFamily: 'Montserrat',
          textSelectionHandleColor: GlobalVariables.pinkColor,
          textSelectionColor: Colors.grey,
        ),
        home: RootPage(),
      ),
    );
  }

  void init(BuildContext context) async {
    GlobalVariables.audioPlayerManager = AudioPlayerManager();
    GlobalVariables.manageLocalSongs = ManageLocalSongs();
    GlobalVariables.publicPlaylists = new List();

    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);

    MusicControlNotification.startService(context);
    
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      GlobalVariables.isNetworkAvailable = false;
    } else {
      GlobalVariables.isNetworkAvailable = true;
    }
    Connectivity().onConnectivityChanged.listen((connectivityResult) {
      if (connectivityResult == ConnectivityResult.none) {
        GlobalVariables.isNetworkAvailable = false;
      } else {
        GlobalVariables.isNetworkAvailable = true;
        if (GlobalVariables.isOfflineMode) {
          FirebaseDatabaseManager.syncUser(GlobalVariables.currentUser.firebaseUid)
              .then((user) {
            GlobalVariables.currentUser = user;
            GlobalVariables.isOfflineMode = false;
          });
        }
      }
    });
  }
}
