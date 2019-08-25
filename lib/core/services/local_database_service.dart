import 'dart:async';
import 'dart:io';
import 'package:myapp/core/database/local/local_database_manager.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/song.dart';

class LocalDatabaseService {
  final LocalDatabaseManager _localDatabaseManager =
      locator<LocalDatabaseManager>();

  Stream<Map<String, int>> get onDownloadProgresses =>
      _localDatabaseManager.downloadProgressesController.stream;

  Stream<Map<String, int>> get onDownloadTotals =>
      _localDatabaseManager.downloadTotalsController.stream;

  Stream<Map<String, bool>> get onDownloadStops =>
      _localDatabaseManager.downloadStopsController.stream;

  Stream<Map<String, DownloadError>> get onDownloadErors =>
      _localDatabaseManager.downloadErorController.stream;

  List<Song> get currentDownloading => _localDatabaseManager.currentDownloading;

  Directory get fullSongDownloadDir => _localDatabaseManager.fullSongDownloadDir;

  Future<void> initDirs() async {
    await _localDatabaseManager.initDirs();
  }

  Future<bool> checkIfStoragePermissionGranted() async {
    return await _localDatabaseManager.checkIfStoragePermissionGranted();
  }

  Future<bool> checkIfSongFileExists(Song song) async {
    return await _localDatabaseManager.checkIfSongFileExists(song);
  }

  Future<bool> checkIfImageFileExists(Song song) async {
    return await _localDatabaseManager.checkIfImageFileExists(song);
  }

  Future<void> downloadSong(Song song) async {
    await _localDatabaseManager.downloadSong(song);
  }

  Future<void> cancelDownLoad(Song song) async {
    await _localDatabaseManager.cancelDownLoad(song);
  }

  Future<void> deleteSongDirectory(Song song) async {
    await _localDatabaseManager.deleteSongDirectory(song);
  }

  bool isSongDownloading(Song song) {
    return _localDatabaseManager.isSongDownloading(song);
  }

  Future<List<Song>> syncDownloaded() async {
    List<Song> songs = await _localDatabaseManager.syncDownloaded();
    songs.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
    return songs;
    //! TODO sync current user!
    // Provider.of<User>(context)
    // CustomColors.currentUser.downloadedSongsPlaylist.setSongs = songs;
    // CustomColors.currentUser.downloadedSongsPlaylist.setSortedType =
    //    SortType.recentlyAdded;
  }

  Future<void> deleteDownloadedDirectory() async {
    await _localDatabaseManager.deleteDownloadedDirectory();
  }

}
