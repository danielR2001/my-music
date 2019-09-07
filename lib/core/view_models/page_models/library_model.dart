import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:myapp/core/enums/page_state.dart';
import 'package:myapp/core/services/authentication_service.dart';
import 'package:myapp/core/services/connectivity_service.dart';
import 'package:myapp/core/services/image_loader_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/modal_sheets/playlist_options_modal_buttom_sheet.dart';

class LibraryModel extends BaseModel {
  final ConnectivityService _connectivityService =
      locator<ConnectivityService>();
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final ImageLoaderService _imageLoaderService = locator<ImageLoaderService>();

  List<Playlist> _playlists = List();
  bool _needToReloadImages = false;
  final Map<String, ImageProvider> _imageProviders = Map();
  User _currentUser;

  List<Playlist> get playlists => _playlists;

  bool get needToReloadImages => _needToReloadImages;

  Map<String, ImageProvider> get imageProviders => _imageProviders;

  Future<void> initModel(User user) async {
    setState(PageState.Busy);
    _currentUser = user;
    _playlists = List.from(user.playlists);
    await _loadImages();
    _connectivityService.connectivityStream.listen((connectivityResult) {
      if (connectivityResult == ConnectivityResult.none) {
        if (_needToReloadImages) {
          _loadImages();
          _needToReloadImages = false;
        }
      }
    });
    setState(PageState.Idle);
  }

  Future<void> _loadImages() async {
    if (!_currentUser.isOfflineMode) {
      for (Playlist playlist in _playlists) {
        if (playlist.songs.length > 0) {
          _imageProviders[playlist.publicPlaylistPushId] =
              await _imageLoaderService.loadImage(playlist.songs[0]);
          notifyListeners();
        }else{
          _imageProviders[playlist.publicPlaylistPushId] = null;
        }
      }
    } else {
      _needToReloadImages = true;
    }
  }

  Future<void> logOut() async {
    await _authenticationService.logout();
  }

  Map createMap(Playlist playlist, bool isDownloadedPlaylist) {
    Map<String, dynamic> playlistValues = Map();
    playlistValues['playlist'] = playlist;
    if (isDownloadedPlaylist) {
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
