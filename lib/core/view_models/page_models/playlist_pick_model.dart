import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/core/utils/toast.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';

class PlaylistPickModel extends BaseModel {
  final ToastManager _toastManager = locator<ToastManager>();

  void makeToast(String text,
      {Toast toastLength = Toast.LENGTH_SHORT,
      double fontSize = 16,
      Color backgroundColor = CustomColors.pinkColor,
      ToastGravity gravity = ToastGravity.BOTTOM}) {
    _toastManager.makeToast(
      text: text,
      toastLength: toastLength,
      fontSize: fontSize,
      backgroundColor: backgroundColor,
      gravity: gravity,
    );
  }
}
