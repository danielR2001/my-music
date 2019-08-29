import 'dart:async';

import 'package:connectivity/connectivity.dart';

class ConnectivityService {
  bool _isNetworkAvailable;
  StreamSubscription _connectivityStreamSubscription;

  bool get isNetworkAvailable => _isNetworkAvailable;

  Stream<ConnectivityResult> get connectivityStream =>
      Connectivity().onConnectivityChanged;

  Future<void> initService() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _isNetworkAvailable = false;
    } else {
      _isNetworkAvailable = true;
    }
    _initNetworkConnectivityStream();
  }

  void _initNetworkConnectivityStream() {
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
