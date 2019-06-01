import 'package:flutter/material.dart';

enum TabItem { discover, account }

class TabHelper {
  static TabItem item({int index}) {
    switch (index) {
      case 0:
        return TabItem.discover;
      case 1:
        return TabItem.account;
    }
    return TabItem.discover;
  }

  // static String title(TabItem tabItem) {
  //   switch (tabItem) {
  //     case TabItem.discover:
  //       return 'Discover';
  //     case TabItem.account:
  //       return 'Account';
  //   }
  //   return '';
  // }

  static IconData icon(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.discover:
        return Icons.explore;
      case TabItem.account:
        return Icons.person_outline;
    }
    return null;
  }
}

class BottomNavigation extends StatelessWidget {
  BottomNavigation({this.currentTab, this.onSelectTab});
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      fixedColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentTab == TabItem.discover ? 0 : 1,
      items: [
        buildItem(tabItem: TabItem.discover),
        buildItem(tabItem: TabItem.account),
      ],
      onTap: (index) => onSelectTab(
            TabHelper.item(index: index),
          ),
    );
  }

  BottomNavigationBarItem buildItem({TabItem tabItem}) {
    //String text = TabHelper.title(tabItem);
    IconData icon = TabHelper.icon(tabItem);
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        size: 30,
      ),
      title: Container(height: 0,)
    );
  }
}
