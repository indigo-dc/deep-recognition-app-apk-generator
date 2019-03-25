import 'package:flutter/material.dart';

class CreditsPlaceholderWidget extends StatelessWidget {
  final Color color;

  CreditsPlaceholderWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }
}