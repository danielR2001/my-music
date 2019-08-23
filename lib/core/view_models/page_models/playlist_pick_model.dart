import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/core/services/api_service.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/services/database_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:myapp/core/services/toast_service.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';

class PlaylistPickModel extends BaseModel {
  final ToastService _toastManager = locator<ToastService>();
  final ApiService _apiService = locator<ApiService>();
  final AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();
  final FirebaseDatabaseService _firebaseDatabaseService =
      locator<FirebaseDatabaseService>();

  bool isSongLocal(String imageUrl) {
    return imageUrl.startsWith("/storage/emulated/0/");
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
      if (song.imageUrl.length == 0) {
        String imageUrl = await _apiService.getSongImageUrl(song);
        if (imageUrl != null) {
          song.setImageUrl = imageUrl;
        }
      }

      updatedsong = Song.fromSong(song);
      updatedsong.setDateAdded = DateTime.now().millisecondsSinceEpoch;
      updatedsong =
          await _firebaseDatabaseService.addSongToPlaylist(playlist, song);
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

  Future<Playlist> createNewPlatlist(Song song, List<Song> songs,  String playlistName, String userName, bool isPublic) async {
    Song updatedsong;
    Playlist playlist = Playlist(playlistName,
        creator: userName, isPublic: isPublic);
    playlist.setPushId =await _firebaseDatabaseService.addPlaylist(playlist);
    if (playlist.isPublic) {
      playlist =
          await _firebaseDatabaseService.addPublicPlaylist(playlist, true);
    }
    if (song != null) {
      if (song.imageUrl.length == 0) {
        String imageUrl =
            await _apiService.getSongImageUrl(song);
        if (imageUrl != null) {
          song.setImageUrl = imageUrl;
        }
      }
      updatedsong = Song.fromSong(song);
      updatedsong.setDateAdded = DateTime.now().millisecondsSinceEpoch;
      updatedsong =
          await _firebaseDatabaseService.addSongToPlaylist(playlist, song);
      playlist.addNewSong(updatedsong);
      return playlist;
    } else {
      songs.forEach((song) async { //! TODO maybe fix it!
        if (song.imageUrl == "") {
          _apiService.getSongImageUrl(song).then((imageUrl) async {
            Song updatedsong;
            if (imageUrl != null) {
              song.setImageUrl = imageUrl;
              updatedsong =
                  await _firebaseDatabaseService.addSongToPlaylist(playlist, song);
              playlist.addNewSong(updatedsong);
            }
          });
        } else {
          updatedsong =
            await  _firebaseDatabaseService.addSongToPlaylist(playlist, song);
          playlist.addNewSong(updatedsong);
        }
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
