import 'package:flutter/material.dart';
import 'package:myapp/api/api_service.dart';
import 'package:myapp/managers/audio_player_manager.dart';
import 'package:myapp/managers/local_songs_manager.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/managers/toast_manager.dart';

class GlobalVariables{
  static const Color lightGreyColor = Color(0xFF222222);
  static const Color lightDarkGreyColor = Color(0xFF202021);
  static const Color darkGreyColor = Color(0xFF0f0f0f);
  static const Color toastColor = Color(0xCC353638);
  static const Color pinkColor = Colors.pink;

  static BuildContext homePageContext;  //! REMOVE THIS !!!
  static String lastSearch;
  static bool isOfflineMode = false;
  static bool isNetworkAvailable;
  static User currentUser;
  static List<Playlist> publicPlaylists;
  static AudioPlayerManager audioPlayerManager;
  static ManageLocalSongs manageLocalSongs;
  static ApiService apiService;
  static ToastManager toastManager;
}