import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';

enum TabItem {analysis, history, credits}

class TabHelper{
  static TabItem item({int index}) {
    switch (index) {
      case 0:
        return TabItem.analysis;
      case 1:
        return TabItem.history;
      case 2:
        return TabItem.credits;
    }
    return TabItem.analysis;
  }

  static String description(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.analysis:
        return AppStrings.analysis;
      case TabItem.history:
        return AppStrings.history;
      case TabItem.credits:
        return AppStrings.credits;
    }
    return '';
  }

  static IconData icon(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.analysis:
        return Icons.add_circle_outline;
      case TabItem.history:
        return Icons.access_time;
      case TabItem.credits:
        return Icons.info_outline;
    }
    return Icons.add_circle_outline;
  }
}

class BottomNavigation extends StatelessWidget {
  BottomNavigation({this.currentTab, this.onSelectTab});
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildItem(tabItem: TabItem.analysis),
        _buildItem(tabItem: TabItem.history),
        _buildItem(tabItem: TabItem.credits),
      ],
      onTap: (index) => onSelectTab(
        TabHelper.item(index: index),
      ),
    );
  }

  BottomNavigationBarItem _buildItem({TabItem tabItem}) {
    String text = TabHelper.description(tabItem);
    IconData icon = TabHelper.icon(tabItem);
    return BottomNavigationBarItem(
      icon: Icon(
        icon
      ),
      title: Text(
        text
      )
    );
  }

}