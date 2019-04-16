import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/task/new_multi_image_task_widget.dart';
import 'package:deep_app/credits/credits_widget.dart';
import 'package:deep_app/history/history_widget.dart';
import 'package:deep_app/home/bottom_navigation.dart';
import 'package:deep_app/home/tab_navigator.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App>{
  /*
  int _currentIndex = 0;
  List<Widget> _children;

  final navigatorKey = GlobalKey<NavigatorState>();
*/
  TabItem currentTab = TabItem.analysis;
  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.analysis: GlobalKey<NavigatorState>(),
    TabItem.history: GlobalKey<NavigatorState>(),
    TabItem.credits: GlobalKey<NavigatorState>()
  };

  void _selectTab(TabItem tabItem){
    setState(() {
      currentTab = tabItem;
    });
  }

  /*@override
  void initState() {
    _children = [
      NewMultiImageTaskPlaceholderWidget(),
      HistoryPlaceholderWidget(),
      CreditsPlaceholderWidget()
    ];

    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
      !await navigatorKeys[currentTab].currentState.maybePop(),
      child: Scaffold(
        body: Stack(children: <Widget>[
          _buildOffstageNavigator(TabItem.analysis),
          _buildOffstageNavigator(TabItem.history),
          _buildOffstageNavigator(TabItem.credits)
        ],),
        bottomNavigationBar: BottomNavigation(
          currentTab: currentTab,
          onSelectTab: _selectTab,
        )
        /*Theme(
          data: Theme.of(context).copyWith(
            // sets the background color of the `BottomNavigationBar`
              canvasColor: AppColors.primary_color,
              // sets the active color of the `BottomNavigationBar` if `Brightness` is light
              primaryColor: Colors.white,
              textTheme: Theme
                  .of(context)
                  .textTheme
                  .copyWith(caption: new TextStyle(color: Colors.white70))),
          child: BottomNavigation(
              currentTab: currentTab,
              onSelectTab: _selectTab
          )
      )*/,
    )




    /*return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: new Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
          canvasColor: AppColors.primary_color,
          // sets the active color of the `BottomNavigationBar` if `Brightness` is light
          primaryColor: Colors.white,
          textTheme: Theme
            .of(context)
            .textTheme
            .copyWith(caption: new TextStyle(color: Colors.white70))),
        child: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex, // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
                icon: new Icon(Icons.add_circle_outline),
                title: new Text(AppStrings.analysis),
            ),
            BottomNavigationBarItem(
                icon: new Icon(Icons.access_time),
                title: new Text(AppStrings.history),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.info_outline),
                title: Text(AppStrings.credits)
            )
          ],
        ),
      )
    );*/

    );
  }

  Widget _buildOffstageNavigator(TabItem tabItem) {
    Widget widget = new Container();

    switch(tabItem){
      case TabItem.analysis:
        widget = NewMultiImageTaskPlaceholderWidget();
        break;
      case TabItem.history:
        widget = HistoryPlaceholderWidget();
        break;
      case TabItem.credits:
        widget = CreditsPlaceholderWidget();
        break;
    }
    return Offstage(
      offstage: currentTab != tabItem,
      child: TabNavigator(
        navigatorKey: navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }

  /*void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }*/



}