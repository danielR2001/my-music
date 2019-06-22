import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';

class PageNotifier with ChangeNotifier {
  Map<String, int> downloadedProgresses = Map();
  Map<String, int> downloadedTotals = Map();
  Playlist currentPlaylistPagePlaylist;

  void addDownloaded(Song song) {
    downloadedProgresses[song.getSongId] = 0;
    downloadedTotals[song.getSongId] = 1;
    notifyListeners();
  }

  void removeDownloaded(Song song) {
    downloadedProgresses.remove(song);
    downloadedTotals.remove(song);
    notifyListeners();
  }

  void updateDownloadedTotals(Song song, int updatedTotal) {
    downloadedTotals[song.getSongId] = updatedTotal;
    notifyListeners();
  }

  void updateDownloadedProgsses(Song song, int updatedProg) {
    downloadedProgresses[song.getSongId] = updatedProg;
    notifyListeners();
  }

  set setCurrentPlaylistPagePlaylist(Playlist value) {
    currentPlaylistPagePlaylist = value;
    notifyListeners();
  }
}
