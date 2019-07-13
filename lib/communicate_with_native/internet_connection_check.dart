import 'package:flutter/services.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/main.dart';

class InternetConnectionCheck {
  static const platform = const MethodChannel('flutter.native/internet');

  static Future<void> activateReciever() async {
    try {
      await platform.invokeMethod('ActivateInternetConnectionReceiver');
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
    }
  }

  static Future<void> disposeReciever() async {
    try {
      await platform.invokeMethod('DisposeInternetConnectionReceiver');
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
    }
  }

  static Future<bool> check() async {
    bool response;
    try {
      final bool result =
          await platform.invokeMethod('internetConnectionCheck');
                platform.setMethodCallHandler(_myUtilsHandler);
      response = result;
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
      response = false;
    }
    return response;
  }

  static Future<dynamic> _myUtilsHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'comebackToOnlineMode':
        {
          GlobalVariables.isOfflineMode = false;
          FirebaseDatabaseManager.syncUser(currentUser.getFirebaseUId)
              .then((user) {
            currentUser = user;
          });
        }
        break;

      default:
    }
  }
}
