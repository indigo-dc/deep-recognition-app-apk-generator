import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/task/list_item.dart';

class NewMultiImageTaskPlaceholderWidget extends StatefulWidget {

  List <ListItem> items = [
    ButtonItem(0, "im", "CAMERA", 35),
    ButtonItem(1, "im", "FILE", 35),
    InfoItem(2, "Select at least one photo"),
    PhotoItem(3, "test"),
    PhotoItem(4, "test")
  ];

  @override
  State<StatefulWidget> createState() {
    return NewMultiImageTaskPlaceholderState();
  }
}

class NewMultiImageTaskPlaceholderState extends State<NewMultiImageTaskPlaceholderWidget> with AutomaticKeepAliveClientMixin{
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
          itemCount: widget.items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = widget.items[index];

            if(item is ButtonItem) {
              if(item.text == 'CAMERA'){
                return new RaisedButton(
                  elevation: 0.0,
                  padding: const EdgeInsets.all(10.0),
                  color: AppColors.accent_color,
                  onPressed: (){

                  },
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      new Icon(Icons.photo_camera),
                      new Text('CAMERA'),
                    ],
                  ),
                );
              }else if(item.text == 'FILE'){
                return new RaisedButton(
                  elevation: 0.0,
                  padding: const EdgeInsets.all(10.0),
                  color: AppColors.accent_color,
                  onPressed: (){

                  },
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      new Icon(Icons.file_upload),
                      new Text('FILE'),
                    ],
                  ),
                );
              }
            }else if(item is InfoItem) {
              return new Container(
                // color: Colors.blue,
                padding: const EdgeInsets.all(10.0),
                child: Material(
                  color: AppColors.accent_color,
                  child: Center(
                      child:Text(item.text)
                  ),
                ),
              );
            }else if(item is PhotoItem){
              return new Container(
                //color: Colors.blue,
                width: 85.0,
                padding: const EdgeInsets.all(10.0),
                child: Material(
                  elevation: 4.0,
                  child: Center(
                      child:Text(item.textimage)
                  ),
                ),
              );
            }
          }
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}