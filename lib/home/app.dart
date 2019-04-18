import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/task/new_multi_image_task_widget.dart';
import 'package:deep_app/credits/credits_page.dart';
import 'package:deep_app/history/history_widget.dart';
import 'package:deep_app/home/bottom_navigation.dart';
import 'package:deep_app/home/tab_navigator.dart';
import 'dart:io';

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
      //_buildOffstageNavigator(tabItem);
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

  Future<bool> _onWillPop() {
    if(navigatorKeys[currentTab].currentState.canPop()){
      navigatorKeys[currentTab].currentState.maybePop();
    }else{
      if(currentTab != TabItem.analysis){
        setState(() {
          currentTab = TabItem.analysis;
        });
      }else{
        exit(0);
      }
    }
    /*setState(() {
      if(currentTab == TabItem.analysis){
        navigatorKeys[currentTab].currentState.maybePop();
        print(navigatorKeys[currentTab].currentState.canPop());
        print("print");
      }else{
        currentTab = TabItem.analysis;
      }
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
          /*() async =>
      !await navigatorKeys[currentTab].currentState.maybePop(),*/
      child: Scaffold(
        body: Stack(children: <Widget>[
          //_buildOffstageNavigator(currentTab),
          _buildOffstageNavigator(TabItem.analysis),
          _buildOffstageNavigator(TabItem.history),
          _buildOffstageNavigator(TabItem.credits)
        ],),
        bottomNavigationBar: Theme(
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
            onSelectTab: _selectTab,
          ),
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