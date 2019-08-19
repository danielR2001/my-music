import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeCommunicationService {
     final MethodChannel _channel =
      const MethodChannel('com.daniel/myMusic');
   BuildContext context;

   Future<String> getDominantColor(
      {String imagePath, bool isLocal}) async {
    String response;
    print("getting dominantColor");
    try {
      String result = await _channel.invokeMethod('getDominantColor', {
        "imagePath": imagePath,
        "isLocal": isLocal,
      });
      response = result;
    } on PlatformException catch (e) {
      print("error invoking method from native: $e");
      response = null;
    }
    return response;
  }
}