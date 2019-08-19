import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';

class ToastManager {
  static final String noNetworkConnection = "No network connection";
  static final String somethingWentWrong = "Something went wrong";
  static final String badNetworkConnection = "Bad network connection";
  static final String songAddedToPlaylist = "Added to ";
  static final String startedDownloadAllSongs = "Started downloading all songs";
  static final String undownloadAllSongs = "undownloaded all songs!";
  static final String undownloadAllError =
      "Can't undownload songs when download is in progress";
  static final String mediaPlayerError = "Media Player error occurred";
  static final String downloadCancelled = "Download cancelled";
  static final String ofllineModeConnection = "Connected in oflline mode";
  static final String enableAccessToStorage = "You need to enable access to storage";
  static final String songUndownloaded = "song Undownloaded";
  static final String undownloadError = "oops song is already undownloaded";

  void makeToast(
      {@required String text,
      Toast toastLength = Toast.LENGTH_SHORT,
      ToastGravity gravity = ToastGravity.BOTTOM,
      Color backgroundColor = CustomColors.pinkColor,
      Color textColor = Colors.white,
      double fontSize = 16}) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }
}
