import 'package:flutter/material.dart';
import 'package:myapp/ui/widgets/buttom_navigation_bar.dart';

class TabNavigationService {
  GlobalKey<NavigatorState> _tabNavigatorKey = GlobalKey<NavigatorState>();
  TabItem _currentTab = TabItem.discover;

  GlobalKey<NavigatorState> get tabNavigatorKey => _tabNavigatorKey;

  TabItem get currentTab => _currentTab;

  void selectTab(TabItem tabItem) {
    _currentTab = tabItem;
    if (_currentTab == TabItem.library) {
      _tabNavigatorKey.currentState.pushReplacementNamed("/library");
    } else {
      _tabNavigatorKey.currentState.pushReplacementNamed("/");
    }
  }

  Future<void> goBack() async {
    if (_tabNavigatorKey.currentState.canPop()) {
      await _tabNavigatorKey.currentState.maybePop();
    }
  }
}
