import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/ui/pages/artist_page.dart';
import 'package:myapp/ui/pages/discover_page.dart';
import 'package:myapp/ui/pages/home_page.dart';
import 'package:myapp/ui/pages/library_page.dart';
import 'package:myapp/ui/pages/login_page.dart';
import 'package:myapp/ui/pages/music_player_page.dart';
import 'package:myapp/ui/pages/playlist_page.dart';
import 'package:myapp/ui/pages/root_page.dart';
import 'package:myapp/ui/pages/search_page.dart';
import 'package:myapp/ui/pages/sign_up_page.dart';
import 'package:myapp/ui/pages/welcome_page.dart';
import 'package:myapp/ui/modal_sheets/playlist_options_modal_buttom_sheet.dart';

import 'decorations/page_slide.dart';
import 'pages/playlists_pick_page.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case "/":
        return MyCustomRoute(builder: (_) => RootPage());
      case "/welcome":
        return MyCustomRoute(builder: (_) => WelcomePage());
      case "/login":
        return MyCustomRoute(builder: (_) => LoginPage());
      case "/signup":
        return MyCustomRoute(builder: (_) => SignUpPage());
      case "/home":
        return MyCustomRoute(builder: (_) => HomePage());
      case "/musicPlayer":
        return MyCustomRoute(builder: (_) => MusicPlayerPage());
      case "/playlistPickPage":
        return MyCustomRoute(builder: (_) {
          Song song;
          List<Song> songs;
          if (args is Map) {
            song = args['song'];
            songs = args['songs'];
          }
          return PlaylistPickPage(
            song: song,
            songs: songs,
          );
        });
      default:
        return MyCustomRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text("No route defined for ${settings.name}"),
            ),
          ),
        );
    }
  }
}

class SubRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case "/": //discover
        return MyCustomRoute(builder: (_) => DiscoverPage());
      case "/library":
        return MyCustomRoute(builder: (_) => LibraryPage());
      case "/search":
        return MyCustomRoute(builder: (_) => SearchPage());
      case "/playlist":
        return MyCustomRoute(builder: (_) {
          Playlist playlist;
          PlaylistModalSheetMode playlistModalSheetMode;
          if (args is Map) {
            playlist = args['playlist'];
            playlistModalSheetMode = args['playlistModalSheetMode'];
          }
          return PlaylistPage(
            playlist: playlist,
            playlistModalSheetMode: playlistModalSheetMode,
          );
        });
      case "/artist":
        return MyCustomRoute(builder: (_) {
          Artist artist;
          if (args is Map) {
            artist = args['artist'];
          }
          return ArtistPage(artist);
        });
      default:
        return MyCustomRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text("No route defined for ${settings.name}"),
            ),
          ),
        );
    }
  }
}
