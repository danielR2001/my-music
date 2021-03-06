import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/core/enums/page_state.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/services/database_service.dart';
import 'package:myapp/core/services/image_loader_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/core/services/toast_service.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';

class PlaylistPickModel extends BaseModel {
  final ToastService _toastManager = locator<ToastService>();
  final AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();
  final FirebaseDatabaseService _firebaseDatabaseService =
      locator<FirebaseDatabaseService>();
  final ImageLoaderService _imageLoaderService = locator<ImageLoaderService>();

  final Map<String, ImageProvider> _imageProviders = Map();
  List<Playlist> _playlists;

  Map<String, ImageProvider> get imageProviders => _imageProviders;

  Future<void> initModel(List<Playlist> playlists) async {
    setState(PageState.Busy);
    _playlists = playlists;
    await _loadImages();
    setState(PageState.Idle);
  }

  Future<void> _loadImages() async {
    for (Playlist playlist in _playlists) {
      if (playlist.songs.length > 0) {
        _imageProviders[playlist.publicPlaylistPushId] =
            await _imageLoaderService.loadImage(playlist.songs[0]);
        notifyListeners();
      } else {
        _imageProviders[playlist.publicPlaylistPushId] = null;
      }
    }
  }

  Future<Playlist> addSongToPlaylist(Playlist playlist, Song song) async {
    bool songAlreadyExistsInPlaylist = false;
    Song updatedsong;
    playlist.songs.forEach((playlistSong) {
      if (playlistSong.songId == song.songId) {
        songAlreadyExistsInPlaylist = true;
      }
    });
    if (!songAlreadyExistsInPlaylist) {
      updatedsong = Song.fromSong(song);
      updatedsong.setDateAdded = DateTime.now().millisecondsSinceEpoch;
      updatedsong =
          await _firebaseDatabaseService.addSongToPlaylist(playlist, updatedsong);
      playlist.addNewSong(updatedsong);
      if (_audioPlayerService.currentPlaylist != null
          ? playlist.pushId == _audioPlayerService.currentPlaylist.pushId
          : false) {}
      _audioPlayerService.setCurrentPlaylist = playlist;
      return playlist;
    } else {
      return null;
    }
  }

  Future<void> addAllSongsToPlaylist(
      Playlist playlist, List<Song> songs) async {
    songs.forEach((song) {
      addSongToPlaylist(playlist, song);
    });
  }

  bool checkIfPlaylistNameValid(
      String playlistName, List<Playlist> userPlaylists) {
    bool valid = true;
    if (playlistName != "Search Playlist") {
      userPlaylists.forEach((playlist) {
        if (playlist.name == playlistName) {
          valid = false;
        }
      });
    } else {
      valid = false;
    }
    return valid;
  }

  Future<Playlist> createNewPlatlist(Song song, List<Song> songs,
      String playlistName, String userName, bool isPublic) async {
    Song updatedsong;
    Playlist playlist =
        Playlist(playlistName, creator: userName, isPublic: isPublic);
    playlist.setPushId = await _firebaseDatabaseService.addPlaylist(playlist);
    if (playlist.isPublic) {
      playlist =
          await _firebaseDatabaseService.addPublicPlaylist(playlist, true);
    }
    if (song != null) {
      updatedsong = Song.fromSong(song);
      updatedsong.setDateAdded = DateTime.now().millisecondsSinceEpoch;
      updatedsong =
          await _firebaseDatabaseService.addSongToPlaylist(playlist, song);
      playlist.addNewSong(updatedsong);
      return playlist;
    } else {
      songs.forEach((song) async {
        //! TODO maybe fix it!

        updatedsong =
            await _firebaseDatabaseService.addSongToPlaylist(playlist, song);
        playlist.addNewSong(updatedsong);
      });
      return playlist;
    }
  }

  void makeToast(String text,
      {Toast toastLength = Toast.LENGTH_SHORT,
      double fontSize = 16,
      Color backgroundColor = CustomColors.pinkColor,
      ToastGravity gravity = ToastGravity.BOTTOM}) {
    _toastManager.makeToast(
      text: text,
      toastLength: toastLength,
      fontSize: fontSize,
      backgroundColor: backgroundColor,
      gravity: gravity,
    );
  }
}
