import 'package:flutter/material.dart';
import 'package:myapp/api_service/api_service.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/user.dart';

class GlobalVariables{
  static final Color lightGreyColor = Color(0xFF222222);
  static final Color lightDarkGreyColor = Color(0xFF202021);
  static final Color darkGreyColor = Color(0xFF0f0f0f);
  static final Color toastColor = Color(0xCC353638);
  static final Color pinkColor = Colors.pink;

  static BuildContext homePageContext;  //! REMOVE THIS !!!
  static String lastSearch;
  static bool isOfflineMode = false;
  static bool isNetworkAvailable;
  static User currentUser;
  static List<Playlist> publicPlaylists;
  static AudioPlayerManager audioPlayerManager;
  static ManageLocalSongs manageLocalSongs;
  static ApiService apiService;
}