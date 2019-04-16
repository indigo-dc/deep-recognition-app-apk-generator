import 'package:flutter/material.dart';
import 'package:deep_app/home/bottom_navigation.dart';
import 'package:deep_app/task/new_multi_image_task_widget.dart';
import 'package:deep_app/history/history_page.dart';
import 'package:deep_app/history/result_page.dart';

class TabNavigatorRoutes{
  static const String root = "/";
  static const String detail = "/detail";
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  void _push(BuildContext context, {int materialIndex: 500}) {
    var routeBuilders = _routeBuilders(context, materialIndex: materialIndex);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            routeBuilders[TabNavigatorRoutes.detail](context)));
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context,
      {int materialIndex: 500}) {
    return {
      TabNavigatorRoutes.root: (context) => HistoryPage(
        onPush: (materialIndex) => _push(context, materialIndex: materialIndex),
      ),
      TabNavigatorRoutes.detail: (context) => ResultPage(

      )
    };
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