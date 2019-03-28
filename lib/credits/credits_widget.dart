import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';

class CreditsPlaceholderWidget extends StatelessWidget {
  final Color color;

  CreditsPlaceholderWidget(this.color);

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