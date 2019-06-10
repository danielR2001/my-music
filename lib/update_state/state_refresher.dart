import 'package:flutter/material.dart';

class StateRefresher with ChangeNotifier {
  int _downloadedProg = 0;
  int _downloadedTotal = 0;

  int get getDownloadedPos => _downloadedProg;

  int get getDownloadedTotal => _downloadedTotal;

  set setDownloadedProg(int value) {
    _downloadedProg = value;
    notifyListeners();
  }

  set setDownloadedTotal(int value) {
    _downloadedTotal = value;
    notifyListeners();
  }
}
