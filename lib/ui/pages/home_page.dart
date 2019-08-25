import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_exoplayer/audioplayer.dart';
import 'package:myapp/core/view_models/page_models/home_model.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/ui/custom_classes/custom_icons.dart';
import 'package:myapp/ui/pages/base_page.dart';
import 'package:myapp/ui/pages/discover_page.dart';
import 'package:myapp/ui/pages/library_page.dart';
import 'package:myapp/ui/router.dart';
import 'package:myapp/ui/widgets/buttom_navigation_bar.dart';
import 'package:myapp/ui/widgets/sound_bar.dart';
import 'package:myapp/core/tab_navigation/tab_navigator.dart';
import 'package:myapp/ui/widgets/text_style.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeModel _model;
  Expanded soundBar;
  TabItem currentTab = TabItem.discover;
  // Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
  //   TabItem.discover: GlobalKey<NavigatorState>(),
  //   TabItem.library: GlobalKey<NavigatorState>(),
  // };

  void selectTab(TabItem tabItem) {
    setState(() {
      currentTab = tabItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage<HomeModel>(
      onModelReady: (model) {
        _model = model;
        _model.initStreams();
      },
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          // if (navigatorKeys[currentTab].currentState.canPop()) {
          //   await navigatorKeys[currentTab].currentState.maybePop();
          // }
          //return Future.value(false);
        },
        child: Scaffold(
          body: currentTab == TabItem.discover
              ? Navigator(
                  onGenerateRoute: SubRouter.generateRoute,
                  initialRoute: "/discover",
                )
              : Navigator(
                  initialRoute: "/library",
                  onGenerateRoute: SubRouter.generateRoute,
                ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: CustomColors.lightGreyColor,
              textTheme: Theme.of(context).textTheme.copyWith(
                    caption: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                musicPlayerControl(),
                BottomNavigation(
                  currentTab: currentTab,
                  onSelectTab: selectTab,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // //* widgets
  // Widget buildOffstageNavigator(TabItem tabItem) {
  //   return Offstage(
  //     offstage: currentTab != tabItem,
  //     child: TabNavigator(
  //       navigatorKey: navigatorKeys[tabItem],
  //       tabItem: tabItem,
  //     ),
  //   );
  // }

  Widget musicPlayerControl() {
    if (_model.currentSong != null) {
      return GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            color: CustomColors.lightGreyColor,
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 0.5),
            ),
          ),
          height: 45,
          child: Row(
            children: <Widget>[
              _model.playerState == PlayerState.PLAYING
                  ? drawPlayingSoundBar()
                  : drawPausedSoundBar(),
              Expanded(
                flex: 5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextDecoration(
                          txt: _model.currentSong.title,
                          size: 14,
                          color: Colors.white,
                          txtMaxLength: 30,
                          height: 20,
                          width: 260,
                          makeBold: true,
                        ),
                        TextDecoration(
                          txt: _model.currentSong.artist,
                          size: 14,
                          color: Colors.grey,
                          txtMaxLength: 30,
                          height: 20,
                          width: 260,
                          makeBold: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: _model.playerState == PlayerState.PLAYING
                      ? drawPauseIcon()
                      : drawPlayIcon(),
                  iconSize: 20,
                  onPressed: () {
                    if (_model.playerState == PlayerState.PLAYING) {
                      _model.pause();
                    } else if (_model.playerState == PlayerState.PAUSED) {
                      _model.resume();
                    }
                    //! add check for internet
                  },
                ),
              )
            ],
          ),
        ),
        onTap: () => Navigator.pushNamed(
          context,
          "/musicPlayer",
        ),
      );
    } else {
      return Container();
    }
  }

  Widget drawPausedSoundBar() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            color: Colors.white,
            width: 5,
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              color: Colors.white,
              width: 5,
              height: 15,
            ),
          ),
          Container(
            color: Colors.white,
            width: 5,
            height: 5,
          ),
        ],
      ),
    );
  }

  Widget drawPlayingSoundBar() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 8,
            height: 50,
            child: SoundBar(Duration(milliseconds: 400), 15.0, 5.0),
          ),
          Container(
            width: 8,
            height: 50,
            child: SoundBar(Duration(milliseconds: 450), 15.0, 5.0),
          ),
          Container(
            width: 8,
            height: 50,
            child: SoundBar(Duration(milliseconds: 350), 15.0, 5.0),
          ),
        ],
      ),
    );
  }

  Widget drawPauseIcon() {
    return Icon(
      MyCustomIcons.pause_icon,
      color: Colors.white,
    );
  }

  Widget drawPlayIcon() {
    return Icon(
      MyCustomIcons.play_icon,
      color: Colors.white,
    );
  }
}
