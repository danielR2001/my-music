import 'package:flutter/material.dart';
import 'package:myapp/ui/decorations/my_custom_icons.dart';

enum TabItem { discover, library }

class TabHelper {
  static TabItem item({int index}) {
    switch (index) {
      case 0:
        return TabItem.discover;
      case 1:
        return TabItem.library;
    }
    return TabItem.discover;
  }

  static Icon icon(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.discover:
        return Icon(
          Icons.explore,
          size: 30,
        );
      case TabItem.library:
        return Icon(
          MyCustomIcons.library_icon,
          size: 24,
        );
    }
    return null;
  }

  static String title(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.discover:
        return 'Discover';
      case TabItem.library:
        return 'Your Library';
    }
    return '';
  }
}

class BottomNavigation extends StatelessWidget {
  BottomNavigation({this.currentTab, this.onSelectTab});
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      unselectedFontSize: 11,
      selectedFontSize: 11,
      fixedColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentTab == TabItem.discover ? 0 : 1,
      items: [
        buildItem(tabItem: TabItem.discover),
        buildItem(tabItem: TabItem.library),
      ],
      onTap: (index) => onSelectTab(
        TabHelper.item(index: index),
      ),
    );
  }

  BottomNavigationBarItem buildItem({TabItem tabItem}) {
    //String text = TabHelper.title(tabItem);
    Icon icon = TabHelper.icon(tabItem);
    String title = TabHelper.title(tabItem);
    return BottomNavigationBarItem(
      icon: icon,
      title: Text(
        title,
      ),
    );
  }
}
