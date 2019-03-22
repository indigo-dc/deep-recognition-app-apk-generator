import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/task/new_multi_image_task.dart';
import 'package:deep_app/credits/credits.dart';
import 'package:deep_app/history/history.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    NewMultiImageTaskPlaceholderWidget(),
    HistoryPlaceholderWidget(Colors.green),
    CreditsPlaceholderWidget(Colors.pink)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary_color,
        title: Text(AppStrings.app_label),
      ),
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
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}