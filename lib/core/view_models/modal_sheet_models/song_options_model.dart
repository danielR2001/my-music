import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/core/services/api_service.dart';
import 'package:myapp/core/services/database_service.dart';
import 'package:myapp/core/services/image_loader_service.dart';
import 'package:myapp/core/services/local_database_service.dart';
import 'package:myapp/core/services/toast_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';

class SongOptionsModel extends BaseModel {
  final ApiService _apiService = locator<ApiService>();
  final ImageLoaderService _imageLoaderService = locator<ImageLoaderService>();
  final FirebaseDatabaseService _firebaseDatabaseService =
      locator<FirebaseDatabaseService>();
  final LocalDatabaseService _localDatabaseService =
      locator<LocalDatabaseService>();
  final ToastService _toastManager = locator<ToastService>();

  ImageProvider _imageProvider;

  bool _songExists = false;

  ImageProvider get imageProvider => _imageProvider;

  bool get songExists => _songExists;

  Future<void> checkIfSongDirExists(Song song) async{
    _songExists = await _localDatabaseService.checkIfSongFileExists(song);
    notifyListeners();
  }

  Future<void> loadImage(Song song) async {
    _imageProvider = await _imageLoaderService.loadImage(song);
    notifyListeners();
  }

  Future<Playlist> removeSongFromPlaylist(User user, Playlist playlist, Song song) async {
    //! TODO remove live from pagePlaylist
    await _firebaseDatabaseService.removeSongFromPlaylist(user, playlist, song);
    playlist.removeSong(song);
    return playlist;
  }

  Future<bool> downloadSong(Song song) async {
    if (await _localDatabaseService.checkIfStoragePermissionGranted()) {
      await _localDatabaseService.downloadSong(song);
      return true;
    }
    return false;
  }

  Future<bool> unDownloadSong(Song song) async {
    if (await _localDatabaseService.checkIfStoragePermissionGranted()) {
      await _localDatabaseService.deleteSongDirectory(song);
      return true;
    }
    return false;
  }

  Future<List<Artist>> buildArtistsList(List<String> artistsList) async {
    List<Artist> artists = List();
    for (int i = 0; i < artistsList.length; i++) {
      Artist artist = await _builArtist(artistsList[i]);
      if (artist != null) {
        artists.add(artist);
      }
    }
    return artists;
  }

  bool isSongDownloading(Song song) {
    return _localDatabaseService.isSongDownloading(song);
  }

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

  Future<Artist> _builArtist(String artistName) async {
    return await _getArtistImageUrl(artistName);
  }

  Future<Artist> _getArtistImageUrl(String artistName) async {
    return await _apiService.getArtistImageUrl(artistName);
  }
}
