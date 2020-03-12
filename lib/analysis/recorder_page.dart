import 'package:deep_app/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecorderPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RecordPageState();
  }
}

class RecordPageState extends State<RecorderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary_color,
        title: Text("Recorder"),
      ),
    );
  }

}