// import 'dart:async';
// import 'package:flutter/services.dart';
// import 'package:media_notification/media_notification.dart';
// import 'main.dart';

// class MusicControlNotification {
//   String status = 'hidden';

//   void initListeners() {
//     MediaNotification.setListener('pause', () {
//       status = 'pause';
//       MyApp.songStatus.pauseSong();
//     });

//     MediaNotification.setListener('play', () {
//       status = 'play';
//       MyApp.songStatus.resumeSong();
//     });

//     MediaNotification.setListener('next', () {});

//     MediaNotification.setListener('prev', () {});

//     MediaNotification.setListener('select', () {});
//   }

//   Future<void> hide() async {
//     try {
//       await MediaNotification.hide();
//       status = 'hidden';
//     } on PlatformException {}
//   }

//   Future<void> show(title, author) async {
//     try {
//       await MediaNotification.show(title: title, author: author);
//       status = 'play';
//     } on PlatformException {}
//   }
// }
