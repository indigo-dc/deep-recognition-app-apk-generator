import 'package:deep_app/analysis/recorder_page.dart';
import 'package:flutter/material.dart';
import 'package:deep_app/app/bottom_navigation.dart';
import 'package:deep_app/history/history_page.dart';
import 'package:deep_app/history/result_page.dart';
import 'package:deep_app/analysis/analysis_page.dart';
import 'package:deep_app/credits/credits_page.dart';
import 'package:deep_app/analysis/task.dart';

class TabNavigatorRoutes{
  static const String root = "/";
  static const String results = "/results";
  static const String recorder = "/recorder";
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem, this.onAppBarVisibility});
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;
  final ValueChanged<bool> onAppBarVisibility;

  _push(BuildContext context, {Task task}) {
    var routeBuilders = _routeBuilders(context, task: task);

    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            routeBuilders[TabNavigatorRoutes.results](context))
    );
  }

  _pushRecorder(BuildContext context) {
    var routeBuilders = _routeBuilders(context);

    onAppBarVisibility(true);

    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                routeBuilders[TabNavigatorRoutes.recorder](context))
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context,
      {Task task}) {

    final analysisMap = {
      TabNavigatorRoutes.root: (context) => AnalysisPage(
        onPush: (task) => _push(context, task: task),
        imagePickerHelper: ImagePickerHelper(),
        onPushRecorder: () =>_pushRecorder(context),
        //fileManager: FileManager(),
      ),
      TabNavigatorRoutes.results: (context) => ResultPage(
        task: task,
      ),
      TabNavigatorRoutes.recorder: (context) => RecorderPage()
    };

    final historyMap = {
      TabNavigatorRoutes.root: (context) => HistoryPage(
        onPush: (task) => _push(context, task: task),
      ),
      TabNavigatorRoutes.results: (context) => ResultPage(
        task: task,
      )
    };

    final creditsMap = {
      TabNavigatorRoutes.root: (context) => CreditsPage(),
    };


    switch(tabItem){
      case TabItem.analysis:
        return analysisMap;
      case TabItem.history:
        return historyMap;
      case TabItem.credits:
        return creditsMap;
      default:
        return analysisMap;
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
          builder: (context) => routeBuilders[routeSettings.name](context)
        );
      },
    );
  }
}