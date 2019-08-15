import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/api/api_service.dart';
import 'package:myapp/database/database_manager.dart';
import 'package:myapp/custom_classes/custom_colors.dart';
import 'package:myapp/managers/local_songs_manager.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:myapp/managers/toast_manager.dart';
import 'package:myapp/ui/decorations/portrait_mode_mixin.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:myapp/managers/audio_player_manager.dart';
import 'package:myapp/ui/pages/root_page.dart';
import 'package:provider/provider.dart';

import 'communicate_with_native/native_communication_service.dart';

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
    GlobalVariables.apiService = ApiService();
    GlobalVariables.toastManager = ToastManager();
    GlobalVariables.publicPlaylists = new List();

    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);

    NativeCommunicationService.startService();
    
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
