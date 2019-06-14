import 'package:flutter/material.dart';
import 'package:myapp/ui/pages/account_page.dart';
import 'package:myapp/ui/pages/discover_page.dart';
import 'package:myapp/ui/pages/playlist_page.dart';
import 'package:myapp/ui/pages/search_page.dart';
import 'package:myapp/ui/widgets/buttom_navigation_bar.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String subTab = '/subTab';
  static const String subTab2 = '/subTab2';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  void _push(BuildContext context,
      {Map playlistValues, bool isFromPublicPlaylists}) {
    var routeBuilders;
    if (playlistValues != null) {
      routeBuilders = _routeBuilders(context, playlistValues: playlistValues);
    } else {
      routeBuilders = _routeBuilders(context);
    }
    if (tabItem == TabItem.discover && playlistValues != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              routeBuilders[TabNavigatorRoutes.subTab2](context),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              routeBuilders[TabNavigatorRoutes.subTab](context),
        ),
      );
    }
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context,
      {Map<String, dynamic> playlistValues}) {
    if (tabItem == TabItem.discover) {
      return {
        TabNavigatorRoutes.root: (context) => DiscoverPage(
              onPush: ({playlistValues}) => playlistValues != null
                  ? _push(context, playlistValues: playlistValues)
                  : _push(context),
            ),
        TabNavigatorRoutes.subTab: (context) => SearchPage(),
        TabNavigatorRoutes.subTab2: (context) => PlaylistPage(
              playlist:
                  playlistValues != null ? playlistValues['playlist'] : null,
              imagePath:
                  playlistValues != null ? playlistValues['imageUrl'] : "",
              playlistCreator: playlistValues != null
                  ? playlistValues['playlistCreator']
                  : null,
              playlistModalSheetMode: playlistValues != null
                  ? playlistValues['playlistModalSheetMode']
                  : null,
            ),
      };
    } else {
      return {
        TabNavigatorRoutes.root: (context) => AccountPage(
              onPush: (playlistValues) => // add isFromPublicPlaylists
                  _push(context, playlistValues: playlistValues),
            ),
        TabNavigatorRoutes.subTab: (context) => PlaylistPage(
              playlist:
                  playlistValues != null ? playlistValues['playlist'] : null,
              imagePath:
                  playlistValues != null ? playlistValues['imageUrl'] : "",
              playlistCreator: playlistValues != null
                  ? playlistValues['playlistCreator']
                  : null,
              playlistModalSheetMode: playlistValues != null
                  ? playlistValues['playlistModalSheetMode']
                  : null,
            ),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context);

    return Navigator(
        key: navigatorKey,
        initialRoute: TabNavigatorRoutes.root,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name](context),
          );
        });
  }
}
