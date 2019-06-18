import 'package:flutter/services.dart';

class InternetConnectioCheck {
  static const platform = const MethodChannel('flutter.native/helper');

  static Future<void> activateReciever() async {
    try {
      await platform.invokeMethod('internetConnectioActivateReceive');
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
    }
  }

  static Future<bool> check() async {
    bool response;
    try {
      final bool result = await platform.invokeMethod('internetConnectioCheck');
      response = result;
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
      response = false;
    }
    return response;
  }
}
