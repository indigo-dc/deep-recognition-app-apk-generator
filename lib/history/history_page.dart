import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({this.onPush});
  final ValueChanged<int> onPush;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HistoryPageState();
  }

}

class HistoryPageState extends State<HistoryPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary_color,
        title: Text(AppStrings.app_label),
      ),
      body: Container(
        child: FlatButton(
          child: Text("wciśnij"),
          onPressed:() => widget.onPush(444),
        ),
      ),
    );
  }

}