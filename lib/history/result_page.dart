import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';

class ResultPage extends StatefulWidget {
  ResultPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ResultPageState();
  }

}

class ResultPageState extends State<ResultPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary_color,
        title: Text(AppStrings.app_label),
      ),
    );
  }

}