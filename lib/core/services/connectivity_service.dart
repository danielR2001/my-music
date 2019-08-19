import 'dart:async';

import 'package:connectivity/connectivity.dart';

class ConnectivityService {
  bool _isNetworkAvailable;
  StreamSubscription _connectivityStreamSubscription;

  bool get isNetworkAvailable => _isNetworkAvailable;

  void initNetworkConnectivityStream() {
    _connectivityStreamSubscription =
        Connectivity().onConnectivityChanged.listen((connectivityResult) {
      if (connectivityResult == ConnectivityResult.none) {
        _isNetworkAvailable = false;
      } else {
        _isNetworkAvailable = true;
      }
    });
  }

  Future<void> disposeNetworkConnectivityStream() async {
    await _connectivityStreamSubscription.cancel();
  }
}
