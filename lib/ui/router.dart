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
import 'package:myapp/ui/widgets/playlist_options_modal_buttom_sheet.dart';

import 'pages/playlists_pick_page.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => RootPage());
      case "/welcome":
        return MaterialPageRoute(builder: (_) => WelcomePage());
      case "/login":
        return MaterialPageRoute(builder: (_) => LoginPage());
      case "/signup":
        return MaterialPageRoute(builder: (_) => SignUpPage());
      case "/home":
        return MaterialPageRoute(builder: (_) => HomePage());
      case "/musicPlayer":
        return MaterialPageRoute(builder: (_) => MusicPlayerPage());
      case "/artist":
        return MaterialPageRoute(builder: (_) {
          Artist artist;
          if (args is Map) {
            artist = args['artist'];
          }
          return ArtistPage(artist);
        });
      case "/playlistPickPage":
        return MaterialPageRoute(builder: (_) {
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
        return MaterialPageRoute(
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
      case "/discover":
        return MaterialPageRoute(builder: (_) => DiscoverPage());
      case "/search":
        return MaterialPageRoute(builder: (_) => SearchPage());
      case "/playlist":
        return MaterialPageRoute(builder: (_) {
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
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text("No route defined for ${settings.name}"),
            ),
          ),
        );
    }
  }
}

class SubRouter2 {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case "/library":
        return MaterialPageRoute(builder: (_) => LibraryPage());
      case "/playlist":
        return MaterialPageRoute(builder: (_) {
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
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text("No route defined for ${settings.name}"),
            ),
          ),
        );
    }
  }
}
