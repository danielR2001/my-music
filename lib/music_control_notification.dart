import 'dart:async';
import 'package:flutter/services.dart';
import 'package:media_notification/media_notification.dart';

class MusicControlNotification {
  String status = 'hidden';

  void initListeners() {
    MediaNotification.setListener('pause', () {
      status = 'pause';
    });

    MediaNotification.setListener('play', () {
      status = 'play';
    });

    MediaNotification.setListener('next', () {});

    MediaNotification.setListener('prev', () {});

    MediaNotification.setListener('select', () {});
  }

  Future<void> hide() async {
    try {
      await MediaNotification.hide();
      status = 'hidden';
    } on PlatformException {}
  }

  Future<void> show(title, author) async {
    try {
      await MediaNotification.show(title: title, author: author);
      status = 'play';
    } on PlatformException {}
  }
}
