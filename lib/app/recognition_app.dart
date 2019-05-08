import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/app/bottom_navigation.dart';
import 'package:deep_app/app/tab_navigator.dart';
import 'dart:io';

class RecognitionApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<RecognitionApp>{

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
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(children: <Widget>[
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
    )
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
}