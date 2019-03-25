import 'package:flutter/material.dart';

class HistoryPlaceholderWidget extends StatelessWidget {
  final Color color;

  HistoryPlaceholderWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }
}