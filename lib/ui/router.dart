import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/ui/pages/artist_page.dart';
import 'package:myapp/ui/pages/home_page.dart';
import 'package:myapp/ui/pages/login_page.dart';
import 'package:myapp/ui/pages/music_player_page.dart';
import 'package:myapp/ui/pages/root_page.dart';
import 'package:myapp/ui/pages/sign_up_page.dart';
import 'package:myapp/ui/pages/welcome_page.dart';

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
          if(args is Map){
            artist = args['artist'];
          }
          return ArtistPage(artist);
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
