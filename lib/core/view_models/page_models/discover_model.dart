import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:myapp/core/enums/page_state.dart';
import 'package:myapp/core/services/connectivity_service.dart';
import 'package:myapp/core/services/database_service.dart';
import 'package:myapp/core/services/image_loader_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/ui/modal_sheets/playlist_options_modal_buttom_sheet.dart';

class DiscoverModel extends BaseModel {
  final FirebaseDatabaseService _firebaseDatabaseService =
      locator<FirebaseDatabaseService>();
  final ConnectivityService _connectivityService =
      locator<ConnectivityService>();
  final ImageLoaderService _imageLoaderService = locator<ImageLoaderService>();

  List<Playlist> _publicPlaylists = List();
  bool _needToReloadImages = false;
  final Map<String, ImageProvider> _imageProviders = Map();
  User _currentUser;

  List<Playlist> get publicPlaylists => _publicPlaylists;

  bool get needToReloadImages => _needToReloadImages;

  Map<String, ImageProvider> get imageProviders => _imageProviders;

  Future<void> initModel(User user) async {
    setState(PageState.Busy);
    _currentUser = User.fromUser(user);
    await _syncAllPublicPlaylists();
    await _loadImages();
    _connectivityService.connectivityStream.listen((connectivityResult) {
      if (connectivityResult != ConnectivityResult.none) {
        if (_needToReloadImages) {
          _loadImages();
          _needToReloadImages = false;
        }
      }
    });
    setState(PageState.Idle);
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

  Future<void> _loadImages() async {
    if (!_currentUser.isOfflineMode) {
      for (Playlist playlist in _publicPlaylists) {
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
  
}//! TODO add stream
