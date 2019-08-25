import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:myapp/core/services/authentication_service.dart';
import 'package:myapp/core/services/connectivity_service.dart';
import 'package:myapp/core/services/local_database_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/widgets/playlist_options_modal_buttom_sheet.dart';

class LibraryModel extends BaseModel {
  final ConnectivityService _connectivityService =
      locator<ConnectivityService>();
  final LocalDatabaseService _localDatabaseService =
      locator<LocalDatabaseService>();
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();

  List<Playlist> _playlists = List();
  bool _needToReloadImages = false;
  final Map<String, ImageProvider> _imageProviders = Map();
  bool _isNetworkAvailable;
  User _currentUser;

  List<Playlist> get playlists => _playlists;

  bool get needToReloadImages => _needToReloadImages;

  Map<String, ImageProvider> get imageProviders => _imageProviders;

  void initModel(User user) {
    _currentUser = user;
    _playlists = List.from(user.playlists);
    _connectivityService.initService();
    _isNetworkAvailable = _connectivityService.isNetworkAvailable;
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

  void loadImages() {
    if (!_currentUser.isOfflineMode) {
      _playlists.forEach((playlist) {
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

  Future<void> logOut() async {
    await _authenticationService.logout();
  }

  Map createMap(Playlist playlist) {
    Map<String, dynamic> playlistValues = Map();
    playlistValues['playlist'] = playlist;
    if (playlist == null) {
      playlistValues['playlistModalSheetMode'] =
          PlaylistModalSheetMode.download;
    } else {
      playlistValues['playlistModalSheetMode'] = PlaylistModalSheetMode.regular;
    }
    return playlistValues;
  }

  String cutPlaylistName(Playlist playlist) {
    String name;
    if (playlist.name.length > 18) {
      int pos = playlist.name.lastIndexOf("", 18);
      if (pos < 10) {
        pos = 18;
      }
      name = playlist.name.substring(0, pos) + "...";
    } else {
      name = playlist.name;
    }
    return name;
  }
}
