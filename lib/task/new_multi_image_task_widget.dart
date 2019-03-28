import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/task/list_item.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewMultiImageTaskPlaceholderWidget extends StatefulWidget {

  List <ListItem> items = [
    ButtonItem(0, AppStrings.camera, 35),
    ButtonItem(1, AppStrings.file, 35),
    InfoItem(2, AppStrings.select_photo_info),
    //PhotoItem(3, "test"),
    //PhotoItem(4, "test")
  ];

  String image_preview_path = AppStrings.preview_default_img_path;

  @override
  State<StatefulWidget> createState() {
    return NewMultiImageTaskPlaceholderState();
  }
}

class NewMultiImageTaskPlaceholderState extends State<NewMultiImageTaskPlaceholderWidget> with AutomaticKeepAliveClientMixin{

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
          Container(
          height: 85.0,
          width: double.infinity,
          color: AppColors.accent_color,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: widget.items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = widget.items[index];

                if(item is ButtonItem) {
                  if(item.text == AppStrings.camera){
                    return RaisedButton(
                      elevation: 0.0,
                      padding: EdgeInsets.all(10.0),
                      color: AppColors.accent_color,
                      onPressed: () async {
                        File img = await ImagePicker.pickImage(source: ImageSource.camera);
                        if(img.path.isNotEmpty && widget.items.length >= 3){
                          if(widget.items[2] is InfoItem){
                            widget.items.removeLast();
                          }
                          setState(() {
                            widget.image_preview_path = img.path;
                            widget.items.add(PhotoItem(3, img.path));
                          });
                        }
                      },
                      child: getButtonColumn(Icons.photo_camera, item.text)
                    );
                  }else if(item.text == AppStrings.file){
                    return RaisedButton(
                      elevation: 0.0,
                      padding: EdgeInsets.all(10.0),
                      color: AppColors.accent_color,
                      onPressed: () async{
                        File img = await ImagePicker.pickImage(source: ImageSource.gallery);
                        if(img.path.isNotEmpty && widget.items.length >= 3){
                          if(widget.items[2] is InfoItem){
                            widget.items.removeLast();
                          }
                          setState(() {
                            widget.image_preview_path = img.path;
                            widget.items.add(PhotoItem(3, img.path));
                          });
                        }
                      },
                      child: getButtonColumn(Icons.file_upload, item.text)
                    );
                  }
                }else if(item is InfoItem) {
                  return Container(
                    padding: EdgeInsets.all(5.0),
                    child: Material(
                      color: AppColors.accent_color,
                      child: Center(
                          child:Text(item.text)
                      ),
                    ),
                  );
                }else if(item is PhotoItem){
                  return Container(
                    width: 85.0,
                    padding: EdgeInsets.all(5.0),
                    child: Material(
                      elevation: 4.0,
                      child: getImageStack(item)
                    ),
                  );
                }
              }
          ),
        ),
        getPreviewImageExpanded(widget.image_preview_path)
      ],
    );
  }

  Stack getImageStack(PhotoItem item){
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if(widget.image_preview_path != item.path){
              setState(() {
                widget.image_preview_path = item.path;
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(item.path),
                  fit: BoxFit.cover
              ),
            ),
          ),
        ),
        GestureDetector(
            onTap: () {
              setState(() {
                widget.items.remove(item);
                final lastItem = widget.items.last;
                if(lastItem is PhotoItem){
                  widget.image_preview_path = lastItem.path;
                }else{
                  widget.image_preview_path = AppStrings.preview_default_img_path;
                  widget.items.add(InfoItem(1, AppStrings.select_photo_info));
                }
              });
            },
            child: Icon(
              Icons.delete,
              color: Colors.red,
            )
        )
      ],
    );
  }

  Column getButtonColumn(IconData icon, String text){
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Icon(icon),
          Text(text),
        ]
    );
  }
  
  Expanded getPreviewImageExpanded(String path){
    return Expanded(
        child: Container(
            child: Image.asset(
                path
            )
        )
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}