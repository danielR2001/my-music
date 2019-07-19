import 'package:flutter/services.dart';

class GetImageDominantColor {
  static const platform = const MethodChannel('flutter.native/dominantColor');

  static Future<dynamic> getDominantColor({String imagePath, bool isLocal}) async {
    String response;
    try {
      String result = await platform.invokeMethod('getDominantColor', {
        "imagePath": imagePath,
        "isLocal": isLocal,
      });
      response = result;
      platform.setMethodCallHandler(_myUtilsHandler);
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
      response = null;
    }
    return response;
  }

    static Future<dynamic> _myUtilsHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'playOrPause':
        break;
      default:
    }
  }
}
