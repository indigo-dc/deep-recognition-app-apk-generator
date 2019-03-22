import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';

class NewMultiImageTaskPlaceholderWidget extends StatelessWidget {


  NewMultiImageTaskPlaceholderWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.0,
      width: double.infinity,
      color: AppColors.accent_color,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: 2,
          itemBuilder: (BuildContext context, int index) {
            return _buildItems(index);
          }
      ),
    );
  }
}

Widget _buildItems(int index) {
  return new Container(
    // color: Colors.blue,
    padding: const EdgeInsets.all(10.0),
    child: new Row(
      children: [
        new Row(children: [
          new RaisedButton(
            child: new Text("Hii"),
            onPressed: () {},
          ),
        ])
      ],
    ),
  );
}