import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/core/services/authentication_service.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/ui/decorations/portrait_mode_mixin.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

import 'package:myapp/ui/router.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget with PortraitModeMixin {
  @override
  Widget build(BuildContext context) {
    init(context);
    super.build(context);
    return StreamProvider<User> (
      initialData: User.initial(),
      builder: (context) => locator<AuthenticationService>().userController.stream,
          child: MaterialApp(
        title: 'My Music',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          accentColor: Colors.grey,
          fontFamily: 'Montserrat',
          textSelectionHandleColor: CustomColors.pinkColor,
          textSelectionColor: Colors.grey,
        ),
        initialRoute: "/",
        onGenerateRoute: Router.generateRoute,
      ),
    );
  }

  void init(BuildContext context) async {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);

    // ConnectivityResult connectivityResult =  //! TODO check conectivity
    //     await Connectivity().checkConnectivity();
    // if (connectivityResult == ConnectivityResult.none) {
    //   CustomColors.isNetworkAvailable = false;
    // } else {
    //   CustomColors.isNetworkAvailable = true;
    // }
    // Connectivity().onConnectivityChanged.listen((connectivityResult) {
    //   if (connectivityResult == ConnectivityResult.none) {
    //     CustomColors.isNetworkAvailable = false;
    //   } else {
    //     CustomColors.isNetworkAvailable = true;
    //     if (CustomColors.isOfflineMode) {
    //       FirebaseDatabaseManager.syncUser(CustomColors.currentUser.firebaseUid)
    //           .then((user) {
    //         CustomColors.currentUser = user;
    //         CustomColors.isOfflineMode = false;
    //       });
    //     }
    //   }
    // });
  }
}
