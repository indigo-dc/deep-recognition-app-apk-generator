import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/analysis/list_item.dart';
import 'package:deep_app/analysis/task.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:deep_app/history/history_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:deep_app/api/recognition_api.dart';

class AnalysisPage extends StatefulWidget {
  AnalysisPage({this.onPush});
  final ValueChanged<Task> onPush;

  @override
  State<StatefulWidget> createState() {
    return AnalysisPageState();
  }
}

class AnalysisPageState extends State<AnalysisPage> with AutomaticKeepAliveClientMixin,TickerProviderStateMixin{

  AnimationController controller;
  Animation<Offset> offset;

  String image_preview_path;
  List<ListItem> items;
  bool start_task_visibility;


  @override
  void initState() {
    controller = AnimationController( vsync: this, duration: Duration(milliseconds: 300));
    offset = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset.zero)
        .animate(controller);

    setDefaultData();

    super.initState();
  }

  @override
  void didUpdateWidget(AnalysisPage oldWidget) {
    if(Navigator.canPop(context)){
      Navigator.pop(context);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary_color,
        title: Text(AppStrings.app_label),
        actions: <Widget>[
          Visibility(
            visible: start_task_visibility,
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
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = items[index];

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
                      if(newImg.path.isNotEmpty && items.length >= 3){
                        if(items[2] is InfoItem){
                          items.removeLast();
                        }
                        setState(() {
                          image_preview_path = newImg.path;
                          items.add(PhotoItem(newImg.path));
                          start_task_visibility = true;
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
                      if(img.path.isNotEmpty && items.length >= 3){
                        if(items[2] is InfoItem){
                          items.removeLast();
                        }
                        setState(() {
                          image_preview_path = img.path;
                          items.add(PhotoItem(img.path));
                          start_task_visibility = true;
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
                    child: getImageStack(item, index)
                ),
              );
            }
          }
      ),
    );
  }

  

  Expanded buildPreviewImageExpanded(String path){
    var pv;

    if(path != AppStrings.preview_default_img_path){
      pv = PhotoView(
        imageProvider: AssetImage(path),
        backgroundDecoration: BoxDecoration(color: Colors.white),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained * 1.8,
        initialScale: PhotoViewComputedScale.contained,
      );
    }else{
      pv = Image.asset(path);
    }

    return Expanded(
        child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                if(image_preview_path == AppStrings.preview_default_img_path){
                  showSnackbar(AppStrings.default_preview_message);
                }
              },
              child: ClipRect(
                child: pv
              ),
            )
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
                      AppStrings.task_processing_message,
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

  Stack getImageStack(PhotoItem item, index){
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
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
              onTap: () {
                setState(() {
                  items.remove(item);
                  final lastItem = items.last;
                  if(lastItem is PhotoItem){
                    image_preview_path = lastItem.path;
                  }else{
                    items.add(InfoItem(AppStrings.select_photo_info));
                    start_task_visibility = false;
                    image_preview_path = AppStrings.preview_default_img_path;
                  }
                });
              },
              child: Container(
                height: 25.0,
                width: 25.0,
                  margin: EdgeInsets.only(top: 5.0, right: 5.0),
                //padding: EdgeInsets.only(left: 0.0, right: 5.0, top: 5.0, bottom: 0.0),
                color: AppColors.notification_color,
                child: Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.clear,
                    color: Colors.red,
                  ),
                )
              )
          ),
        )
      ],
    );
  }

  List<PhotoView> buildPhotoViewsList(List <String> imgPaths) {
    List<PhotoView> imagesWidgets = [];

    for (String ip in imgPaths) {
      imagesWidgets.add(
          PhotoView(
            imageProvider: AssetImage(ip),
            backgroundDecoration: BoxDecoration(color: Colors.white),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.contained * 1.8,
            initialScale: PhotoViewComputedScale.contained,
          )
      );
    }
    return imagesWidgets;
  }

  onStartTaskPressed() async {
    controller.forward();

    final photoPaths = getImagePathsList(items);

    String stringResponse = await RecognitionApi().postTask(photoPaths).catchError((Object error){
      setState(() {
        controller.reset();
        showSnackbar(error.toString());
      });
    });


    final parsed = json.decode(stringResponse);
    Results results = Results.fromJson(parsed);
    controller.reset();
    addTaskToRepository(photoPaths, results).then((t){
      setState(() {
        setDefaultData();
      });
      widget.onPush(t);
    });
  }

  Future<Task> addTaskToRepository (List<String> photoPaths, Results results) async {
    HistoryRepository hr = HistoryRepository();
    return await hr.addTask(photoPaths, results);
  }

  setDefaultData(){
    image_preview_path = AppStrings.preview_default_img_path;
    items = [
      ButtonItem(AppStrings.camera),
      ButtonItem(AppStrings.file),
      InfoItem(AppStrings.select_photo_info),
    ];
    start_task_visibility = false;
  }

  showSnackbar(String text){
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(text),
    ));
  }

  changePreviewImage(String path){
    image_preview_path = path;
  }

  List<String> getImagePathsList(List<ListItem> items){
    List <String> photoPaths = [];
    for(ListItem li in items){
      if(li is PhotoItem){
        photoPaths.add(li.path);
      }
    }
    return photoPaths;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}