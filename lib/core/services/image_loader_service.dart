import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:myapp/core/services/connectivity_service.dart';
import 'package:myapp/core/services/local_database_service.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/song.dart';

class ImageLoaderService {
  final ConnectivityService _connectivityService =
      locator<ConnectivityService>();
  final LocalDatabaseService _localDatabaseService =
      locator<LocalDatabaseService>();

  Future<ImageProvider> loadImage(Song song) async {
    bool exists = await _localDatabaseService.checkIfImageFileExists(song);
    if (exists) {
      File file = File(
          "${_localDatabaseService.fullSongDownloadDir.path}/${song.songId}/${song.songId}.png");
      return FileImage(file);
    } else {
      if (_connectivityService.isNetworkAvailable) {
        return NetworkImage(
          song.imageUrl,
        );
      }else {
        return null;
      }
    }
  }
}
