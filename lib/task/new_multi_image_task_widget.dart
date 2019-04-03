import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/task/list_item.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:deep_app/task/task.dart';
import 'package:page_indicator/page_indicator.dart';


class NewMultiImageTaskPlaceholderWidget extends StatefulWidget {

  List <ListItem> items = [
    ButtonItem(0, AppStrings.camera, 35),
    ButtonItem(1, AppStrings.file, 35),
    InfoItem(2, AppStrings.select_photo_info),
    //PhotoItem(3, "test"),
    //PhotoItem(4, "test")
  ];

  String image_preview_path = AppStrings.preview_default_img_path;

  bool start_task_visibility = false;

  bool pickImageScreen = true;



  @override
  State<StatefulWidget> createState() {
    return NewMultiImageTaskPlaceholderState();
  }

}

class NewMultiImageTaskPlaceholderState extends State<NewMultiImageTaskPlaceholderWidget> with AutomaticKeepAliveClientMixin,TickerProviderStateMixin{
  AnimationController controller;
  Animation<Offset> offset;
  List<Widget> images;
  int photoNum = 0;
  Task task;

  @override
  void initState() {
    super.initState();

    controller = AnimationController( vsync: this, duration: Duration(milliseconds: 300));

    offset = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset.zero)
        .animate(controller);
  }

  @override
  Widget build(BuildContext context) {

    if(widget.items.length > 2){
      if(widget.items[2] is PhotoItem){
        widget.start_task_visibility = true;
      }else{
        widget.start_task_visibility = false;
      }
    }

    if(widget.pickImageScreen){
      return getPickColumn();
    }else{
      return getResultForum();
    }


  }

  Column getResultForum(){

    images = getPhotosWidgetList(widget.items);

    return Column(
      children: <Widget>[
        AppBar(
          backgroundColor: AppColors.primary_color,
          title: Text(AppStrings.app_label),
          actions: <Widget>[
            Visibility(
              visible: widget.start_task_visibility,
              child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 25.0,
                    color: Colors.white,
                  )
              ),
            )
          ],
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Stack(
                  children: <Widget>[
                    PageIndicatorContainer(
                      pageView: PageView(
                        children: images,
                      ),
                      align: IndicatorAlign.bottom,
                      length: images.length,
                      padding: EdgeInsets.only(bottom: 10.0),
                      size: 10.0,
                      indicatorSpace: 10.0,
                      indicatorSelectorColor: Colors.white,
                      indicatorColor: Colors.grey,
                    )

                    /*
                    Container(
                      child: PageView.builder(
                        itemBuilder: (BuildContext context, int index) {
                        photoNum = index;
                        return images[index];
                      },
                        itemCount: images.length,
                      ),
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: new Center(
                        child: Container(
                          child: DotsIndicator(
                            numberOfDot: images.length,
                            position: photoNum,
                          ),
                        ),
                      ),
                    )*/
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(

                ),
              )
            ],
          )
        )
      ]
    );
  }

  Column getPickColumn(){
    return Column(
      children: <Widget>[
        AppBar(
          backgroundColor: AppColors.primary_color,
          title: Text(AppStrings.app_label),
          actions: <Widget>[
            Visibility(
              visible: widget.start_task_visibility,
              child: IconButton(
                  onPressed: (
                      onStartTaskPressed
                  ),
                  icon: Icon(
                    Icons.play_arrow,
                    size: 35.0,
                  )
              ),
            )
          ],
        ),
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
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Image.asset(path),
          ),
          Align(
            alignment: Alignment.topCenter,
              child: FadeTransition(
                  child: SlideTransition(
                    position: offset,
                    child:  Container(
                      padding: EdgeInsets.all(15.0),
                      width: double.infinity,
                      color: AppColors.notification_color,
                      child: Text(
                          "Please wait...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  opacity: controller),
          )
        ],
      ),
    );
  }

  onStartTaskPressed() async {
    List <UploadFileInfo> pitems = [];
    for(ListItem li in widget.items){
      if(li is PhotoItem){
        pitems.add(UploadFileInfo(File(li.path), li.path));
      }
    }
    FormData formData = new FormData.from({
      "data": pitems
    });
    controller.forward();
    Response response = await Dio().post(AppStrings.api_url + AppStrings.post_endpoint, data: formData);
    print(response.toString());

    setState(() {
      widget.pickImageScreen = false;

    });
  }

  List<Widget> getPhotosWidgetList(List <ListItem> items){
    List<Widget> images  = [];
    for(ListItem li in items){
      if(li is PhotoItem){
        images.add(Image.asset(li.path));
      }
    }
    return images;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}