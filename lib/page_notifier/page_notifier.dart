import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';

class PageNotifier with ChangeNotifier {
  Map<String, int> downloadedProgresses = Map();
  Map<String, int> downloadedTotals = Map();
  Playlist currentPlaylistPagePlaylist;
  Song currentSong;

  void addDownloaded(Song song) {
    downloadedProgresses[song.songId] = 0;
    downloadedTotals[song.songId] = 1;
    notifyListeners();
  }

  void removeDownloaded(Song song) {
    downloadedProgresses.remove(song);
    downloadedTotals.remove(song);
    notifyListeners();
  }

  void updateDownloadedTotals(Song song, int updatedTotal) {
    downloadedTotals[song.songId] = updatedTotal;
    notifyListeners();
  }
  

  void updateDownloadedProgsses(Song song, int updatedProg) {
    downloadedProgresses[song.songId] = updatedProg;
    notifyListeners();
  }

  set setCurrentPlaylistPagePlaylist(Playlist value) {
    currentPlaylistPagePlaylist = value;
    notifyListeners();
  }

    set setCurrentSong(Song value) {
    currentSong = value;
    notifyListeners();
  }
}
