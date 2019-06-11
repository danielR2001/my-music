import 'package:flutter/services.dart';


class UnaccentString {
  static const platform = const MethodChannel('flutter.native/helper');


  static Future<String> unaccent(
      String str) async {
    String response;
    try {
      final String result = await platform.invokeMethod('unaccent', {
        "string": str,
      });
      response = result;
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
      response = "";
    }
    return response;
  }
}
