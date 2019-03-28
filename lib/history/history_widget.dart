import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';

class HistoryPlaceholderWidget extends StatelessWidget {
  final Color color;

  HistoryPlaceholderWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AppBar(
          backgroundColor: AppColors.primary_color,
          title: Text(AppStrings.app_label),
        )
      ],
    );
  }
}