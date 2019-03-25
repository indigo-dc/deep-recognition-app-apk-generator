import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/task/list_item.dart';

class NewMultiImageTaskPlaceholderWidget extends StatefulWidget {

  //NewMultiImageTaskPlaceholderWidget();
  List <Item> items;

  NewMultiImageTaskPlaceholderWidget({
    Key key,
    this.items,
  }) : super(key:key);

  NewMultiImageTaskPlaceholderState createState() => NewMultiImageTaskPlaceholderState();
}

class NewMultiImageTaskPlaceholderState extends State<NewMultiImageTaskPlaceholderWidget> {
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
          itemCount: 5,
          itemBuilder: (BuildContext context, int index) {
            return _buildItems(items, index);
          }
      ),
    );
  }

}

Widget _buildItems(List<Item> list, int index) {
  return new Container(
    // color: Colors.blue,
    padding: const EdgeInsets.all(10.0),
    child: Material(
      elevation: 4.0,
      child: Center(
        child:Text(list[index].toString())
      ),
    ),
  );
}