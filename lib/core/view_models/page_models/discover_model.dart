import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:myapp/core/services/connectivity_service.dart';
import 'package:myapp/core/services/database_service.dart';
import 'package:myapp/core/services/local_database_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/widgets/playlist_options_modal_buttom_sheet.dart';

class DiscoverModel extends BaseModel {
  final FirebaseDatabaseService _firebaseDatabaseService =
      locator<FirebaseDatabaseService>();
  final ConnectivityService _connectivityService =
      locator<ConnectivityService>();
  final LocalDatabaseService _localDatabaseService =
      locator<LocalDatabaseService>();

  List<Playlist> _publicPlaylists = List();
  bool _needToReloadImages = false;
  final Map<String, ImageProvider> _imageProviders = Map();
  bool _isNetworkAvailable;
  User _currentUser;

  List<Playlist> get publicPlaylists => _publicPlaylists;

  bool get needToReloadImages => _needToReloadImages;

  Map<String, ImageProvider> get imageProviders => _imageProviders;

  Future<void> initModel(User user) async {
    _currentUser = User.fromUser(user);
    _connectivityService.initService();
    _isNetworkAvailable = _connectivityService.isNetworkAvailable;
    await _syncAllPublicPlaylists();
    loadImages();
    _connectivityService.connectivityStream.listen((connectivityResult) {
      if (connectivityResult == ConnectivityResult.none) {
        _isNetworkAvailable = false;
      } else {
        _isNetworkAvailable = true;
        if (_needToReloadImages) {
          loadImages();
          _needToReloadImages = false;
        }
      }
    });
  }

  Future<void> _syncAllPublicPlaylists() async {
    _publicPlaylists = await _firebaseDatabaseService.buildPublicPlaylists();
    notifyListeners();
  }

  Map createMap(Playlist playlist) {
    Map<String, dynamic> playlistValues = Map();
    if (playlist.songs.length > 0) {
      playlistValues['playlist'] = playlist;
    } else {
      playlistValues['playlist'] = playlist;
    }
    playlistValues['playlistModalSheetMode'] = PlaylistModalSheetMode.public;
    return playlistValues;
  }

  void loadImages() {
    if (!_currentUser.isOfflineMode) {
      _publicPlaylists.forEach((playlist) {
        if (playlist.songs.length > 0) {
          if (playlist.songs[0].imageUrl != "") {
            _localDatabaseService
                .checkIfImageFileExists(playlist.songs[0])
                .then((exists) {
              if (exists) {
                File file = File(
                    "${_localDatabaseService.fullSongDownloadDir.path}/${playlist.songs[0].songId}/${playlist.songs[0].songId}.png");
                _imageProviders[playlist.songs[0].songId] = (FileImage(file));
                notifyListeners();
              } else {
                if (_isNetworkAvailable) {
                  imageProviders[playlist.songs[0].songId] = NetworkImage(
                    playlist.songs[0].imageUrl,
                  );
                  notifyListeners();
                }
              }
            });
          } else {
            imageProviders[playlist.songs[0].songId] = null;
            notifyListeners();
          }
        }
      });
    } else {
      _needToReloadImages = true;
    }
  }
}//! TODO add stream
