import 'package:flutter/services.dart';

class GetImageDominantColor {
  static const platform = const MethodChannel('flutter.native/dominantColor');

  static Future<dynamic> getDominantColor(String imageUrl) async {
    String response;
    try {
      String result = await platform.invokeMethod('getDominantColor', {
        "imageUrl": imageUrl,
      });
      response = result;
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
      response = null;
    }
    return response;
  }
}
