import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/task/list_item.dart';
import 'package:deep_app/task/task.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:deep_app/task/task.dart';
import 'dart:convert';
import 'package:deep_app/task/results_page_widget.dart';
import 'package:deep_app/history/history_repository.dart';
import 'package:path_provider/path_provider.dart';

class AnalysisPage extends StatefulWidget {
  AnalysisPage({this.onPush});
  final ValueChanged<Task> onPush;

  List <ListItem> items = [
    ButtonItem(-3, AppStrings.camera, 35),
    ButtonItem(-2, AppStrings.file, 35),
    InfoItem(-1, AppStrings.select_photo_info),
    //PhotoItem(3, "test"),
    //PhotoItem(4, "test")
  ];


  //String image_preview_path = AppStrings.preview_default_img_path;

  bool start_task_visibility = false;

  bool pickImageScreen = true;

  Task task;

  @override
  State<StatefulWidget> createState() {
    return AnalysisPageState();
  }
}

class AnalysisPageState extends State<AnalysisPage> with AutomaticKeepAliveClientMixin,TickerProviderStateMixin{

  AnimationController controller;
  Animation<Offset> offset;

  String image_preview_path = AppStrings.preview_default_img_path;

  @override
  void initState() {
    //super.initState();

    controller = AnimationController( vsync: this, duration: Duration(milliseconds: 300));

    offset = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset.zero)
        .animate(controller);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: getPickColumn(),
    );
  }

  Column getPickColumn(){
    return Column(
      children: <Widget>[
        /*AppBar(
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
        ),*/
        buildPhotosManagementBar(),
        buildPreviewImageExpanded(image_preview_path)
      ],
    );
  }

  Container buildPhotosManagementBar(){
    return Container(
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
                      final dir = await getApplicationDocumentsDirectory();
                      final path = dir.path;
                      final timestamp = DateTime.now().millisecondsSinceEpoch;
                      final timestampString = timestamp.toString();
                      File newImg = await img.copy("$path/$timestampString.jpg");
                      if(newImg.path.isNotEmpty && widget.items.length >= 3){
                        if(widget.items[2] is InfoItem){
                          widget.items.removeLast();
                        }
                        setState(() {
                          image_preview_path = newImg.path;
                          widget.items.add(PhotoItem(3, newImg.path));
                          widget.start_task_visibility = true;
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
                          image_preview_path = img.path;
                          widget.items.add(PhotoItem(3, img.path));
                          widget.start_task_visibility = true;
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
    );
  }

  

  Expanded buildPreviewImageExpanded(String path){
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


  Column getButtonColumn(IconData icon, String text){
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Icon(icon),
          Text(text),
        ]
    );
  }

  Stack getImageStack(PhotoItem item){
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if(image_preview_path != item.path){
              setState(() {
                image_preview_path = item.path;
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
                  image_preview_path = lastItem.path;
                }else{
                  image_preview_path = AppStrings.preview_default_img_path;
                  widget.items.add(InfoItem(1, AppStrings.select_photo_info));
                  widget.start_task_visibility = false;
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

  onStartTaskPressed() async {
    List <UploadFileInfo> pitems = [];
    List <String> photoPaths = [];
    for(ListItem li in widget.items){
      if(li is PhotoItem){
        pitems.add(UploadFileInfo(File(li.path), li.path));
        photoPaths.add(li.path);
      }
    }
    FormData formData = new FormData.from({
      "data": pitems
    });

    controller.forward();

    Response response = await Dio().post(AppStrings.api_url + AppStrings.post_endpoint, data: formData).catchError((Object error){
      setState(() {
        controller.reset();
      });
    });

    if(response.statusCode == 200){
      final parsed = json.decode(response.toString());

      Results results = new Results.fromJson(parsed);

      //HistoryRepository hr = HistoryRepository();
      controller.reset();
      //final task = await hr.addTask(photoPaths, results);
      addTaskToRepository(photoPaths, results).then((t){
        setState(() {
          setDefaultData();
        });
        widget.onPush(t);
      });
    }
  }

  Future<Task> addTaskToRepository (List<String> photoPaths, Results results) async {
    HistoryRepository hr = HistoryRepository();
    return await hr.addTask(photoPaths, results);
  }

  setDefaultData(){
    image_preview_path = AppStrings.preview_default_img_path;
    widget.items = [
      ButtonItem(-3, AppStrings.camera, 35),
      ButtonItem(-2, AppStrings.file, 35),
      InfoItem(-1, AppStrings.select_photo_info),
      //PhotoItem(3, "test"),
      //PhotoItem(4, "test")
    ];
    widget.start_task_visibility = false;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}