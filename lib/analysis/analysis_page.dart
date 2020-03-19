import 'dart:ffi';

import 'package:deep_app/analysis/post.dart';
import 'package:deep_app/analysis/recorder_page.dart';
import 'package:deep_app/utils/assets_manager.dart';
import 'package:deep_app/utils/file_downloader.dart';
import 'package:deep_app/utils/file_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/analysis/list_item.dart';
import 'package:deep_app/analysis/task.dart';
import 'package:flutter_sound/flutter_sound.dart';

//import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:deep_app/history/history_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:deep_app/api/recognition_api.dart';
import 'package:deep_app/api/mock_recognition_api.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class AnalysisPage extends StatefulWidget {
  AnalysisPage({this.onPush, this.imagePickerHelper, this.onPushRecorder});

  final ValueChanged<Task> onPush;
  final ImagePickerHelper imagePickerHelper;
  final VoidCallback onPushRecorder;

  @override
  State<StatefulWidget> createState() {
    return AnalysisPageState();
  }
}

class AnalysisPageState extends State<AnalysisPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  AnimationController controller;
  Animation<Offset> offset;

  String image_preview_path;

  bool start_task_visibility;

  ImagePickerHelper imagePickerHelper;

  Post post;
  String current_data_input;
  List data_inputs;
  String media_input_type;
  List<ListItem> data_items;
  List<Parameter> query_parameters;
  Map query_values;
  Map query_controllers;
  FlutterSound flutterSound;
  var playerSubscription;
  bool urlAddButtonVisibility;
  TextEditingController urlController;

  //FileManager fileManager;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    offset = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset.zero)
        .animate(controller);

    setDefaultData();
    loadPredictEndpointInfo().then((p) {
      setState(() {
        //setting data input parameters
        post = p;
        for (Parameter p in post.parameters) {
          if (p.name == "urls" || p.name == "data") {
            if (p.description.contains("image")) {
              media_input_type = "image";
              data_inputs.add(p.name);
            } else if (p.description.contains("audio")) {
              media_input_type = "audio";
              data_inputs.add(p.name);
            } else {
              query_parameters.add(p);
              query_values.putIfAbsent(p, () => p.default_);
            }
          } else {
            query_parameters.add(p);
            query_values.putIfAbsent(p, () => p.default_);
          }
        }
        if (data_inputs.length > 0) {
          changedDataInputType(data_inputs[0]);
        }
      });
    });
    super.initState();
  }

  @override
  void didUpdateWidget(AnalysisPage oldWidget) {
    if (Navigator.canPop(context)) {
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
                onPressed: (onStartTaskPressed),
                icon: Icon(
                  Icons.play_arrow,
                  size: 35.0,
                  key: Key("startTaskIcon"),
                )),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: buildPageColumn(),
      ),
      //body: getCustomColumn(),
    );
  }

  Column buildPageColumn() {
    var columns = <Widget>[];
    if (post == null) {
      columns.add(Container(
        child: Align(
          alignment: Alignment.center,
          child: Text("No config file"),
        ),
      ));
    } else {
      if (data_inputs.length > 0) {
        columns.add(buildDataUploadSection(data_inputs));
      }
    }
    return Column(
      children: columns,
    );
  }

  Column buildDataUploadSection(List inputs) {
    var columns = <Widget>[];
    columns.add(Padding(
        padding: EdgeInsets.only(left: 20, top: 10),
        child: Container(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              "Select input type: ",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        )));

    List<DropdownMenuItem<String>> items = new List();
    for (String i in inputs) {
      items.add(DropdownMenuItem(value: i, child: Text(i)));
    }
    columns.add(Padding(
        padding: EdgeInsets.only(left: 20.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: DropdownButton(
                value: current_data_input,
                items: items,
                onChanged: changedDataInputType))));

    columns.add(Padding(
        padding: EdgeInsets.only(left: 20, top: 20),
        child: Container(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              "Load " + media_input_type + " from:",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        )));

    if (media_input_type == "image") {
      if (current_data_input == "data") {
        columns.add(Row(
          children: <Widget>[
            buildImageCameraButtonContainer(),
            buildImageFileButtonContainer()
          ],
        ));
      }
      if (current_data_input == "urls") {
        columns.add(buildUrlImageInput());
      }
    }

    if (media_input_type == "audio") {
      if (current_data_input == "data") {
        columns.add(Row(
          children: <Widget>[
            buildRecorderButtonContainer(),
            buildAudioFileButtonContainer(),
          ],
        ));
      }
      if (current_data_input == "urls") {
        columns.add(buildUrlAudioInput());
      }
    }

    if (data_items.isNotEmpty) {
      columns.add(buildItemPreview());
    }

    for (Parameter p in query_parameters) {
      if (p.enum_ == null) {
        columns.add(
          Container(
            margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
            child: buildQueryParameterTextInputColumn(p),
          ),
        );
      } else {
        columns.add(Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
          child: buildQueryParameterEnumInputColumn(p),
        ));
      }
    }

    columns.add(Container(
      margin: EdgeInsets.only(top: 20.0),
      child: RaisedButton(
        color: AppColors.accent_color,
        onPressed: isRequiredDataFilled() ? () => pressedAnalyseButton(current_data_input, data_items, query_values) : null ,
        child: Text("Analyse"),
      ),
    ));

    return Column(
      children: columns,
    );
  }

  //input data buttons
  Container buildRecorderButtonContainer() {
    return Container(
        margin: EdgeInsets.only(left: 10.0),
        child: RaisedButton(
            key: Key("recorderButton"),
            color: Colors.transparent,
            elevation: 0.0,
            padding: EdgeInsets.all(10.0),
            onPressed: pressedPickAudioFromRecorder,
            child: getButtonColumn(
                Icons.record_voice_over, "RECORDER", Colors.grey)));
  }

  Container buildAudioFileButtonContainer() {
    return Container(
        margin: EdgeInsets.only(left: 10.0),
        child: RaisedButton(
            key: Key("audioFileButton"),
            color: Colors.transparent,
            elevation: 0.0,
            padding: EdgeInsets.all(10.0),
            onPressed: pressedPickAudioFromFile,
            child: getButtonColumn(Icons.file_upload, "FILE", Colors.black)));
  }

  /*Container buildAudioURLButtonContainer() {
    return Container(
      margin: EdgeInsets.only(left: 10.0),
      child: RaisedButton(
          key: Key("audioURLButton"),
          color: Colors.transparent,
          elevation: 0.0,
          padding: EdgeInsets.all(10.0),
          onPressed: pressedPickAudioFromURL,
          child: getButtonColumn(Icons.web_asset, "URL", Colors.black
          )),
    );
  }*/
  Container buildImageCameraButtonContainer() {
    return Container(
        margin: EdgeInsets.only(left: 10.0),
        child: RaisedButton(
            key: Key("cameraButton"),
            color: Colors.transparent,
            elevation: 0.0,
            padding: EdgeInsets.all(10.0),
            onPressed: pressedPickImageFromCamera,
            child:
                getButtonColumn(Icons.photo_camera, "CAMERA", Colors.black)));
  }

  Container buildImageFileButtonContainer() {
    return Container(
        margin: EdgeInsets.only(left: 10.0),
        child: RaisedButton(
            key: Key("galleryButton"),
            color: Colors.transparent,
            elevation: 0.0,
            padding: EdgeInsets.all(10.0),
            onPressed: pressedPickImageFromGallery,
            child:
                getButtonColumn(Icons.file_upload, "GALLERY", Colors.black)));
  }

  /*Container buildImageURLButtonContainer() {
    return Container(
      margin: EdgeInsets.only(left: 10.0),
      child: RaisedButton(
          key: Key("imageURLButton"),
          color: Colors.transparent,
          elevation: 0.0,
          padding: EdgeInsets.all(10.0),
          onPressed: pressedPickImageFromURL,
          child: getButtonColumn(Icons.web_asset, "URL", Colors.black)),
    );
  }*/

  Container buildUrlAudioInput() {
    return Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 8,
              child: TextField(
                onChanged: (text) {
                  if (text.isEmpty) {
                    setState(() {
                      urlAddButtonVisibility = false;
                    });
                  } else {
                    setState(() {
                      urlAddButtonVisibility = true;
                    });
                  }
                },
                decoration:
                InputDecoration(hintText: "https://url-of-audio-file"),
                controller: urlController,
              ),
            ),
            Expanded(
              flex: 2,
              child: urlAddButtonVisibility
                  ? Align(
                alignment: Alignment.center,
                child: RaisedButton(
                  child: Icon(
                    Icons.add_circle,
                    color: AppColors.accent_color,
                    size: 30,
                  ),
                  elevation: 0.0,
                  onPressed: () {
                    pressedPickAudioFromURL(urlController.text);
                  },
                  color: Colors.transparent,
                ),
              )
                  : Container(),
            )
          ],
        ));
  }

  Container buildUrlImageInput() {
    return Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 8,
              child: TextField(
                onChanged: (text) {
                  if (text.isEmpty) {
                    setState(() {
                      urlAddButtonVisibility = false;
                    });
                  } else {
                    setState(() {
                      urlAddButtonVisibility = true;
                    });
                  }
                },
                decoration:
                InputDecoration(hintText: "https://url-of-image-file"),
                controller: urlController,
              ),
            ),
            Expanded(
              flex: 2,
              child: urlAddButtonVisibility
                  ? Align(
                alignment: Alignment.center,
                child: RaisedButton(
                  child: Icon(
                    Icons.add_circle,
                    color: AppColors.accent_color,
                    size: 30,
                  ),
                  elevation: 0.0,
                  onPressed: () {
                    pressedPickImageFromURL(urlController.text);
                  },
                  color: Colors.transparent,
                ),
              )
                  : Container(),
            )
          ],
        ));
  }

  //returns multiline list of picked items
  Container buildItemPreview() {
    return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Wrap(
            spacing: 10.0,
            runSpacing: 5.0,
            direction: Axis.horizontal,
            children: data_items.map((item) {
              var myStack = Stack();
              if (item is PhotoItem) {
                myStack = buildImageStack(item);
              } else if (item is AudioItem) {
                myStack = buildAudioStack(item);
              }
              return Container(
                width: 75.0,
                height: 75.0,
                //padding: EdgeInsets.all(5.0),
                child: Material(elevation: 4.0, child: myStack),
              );
            }).toList()));
  }

  //unused
  /*Column getPickColumn() {
    return Column(
      children: <Widget>[
        buildPhotosManagementBar(),
        buildPreviewImageExpanded(image_preview_path)
      ],
    );
  }*/

  Stack buildImageStack(PhotoItem item) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          /*onTap: () {
            if(image_preview_path != item.path){
              setState(() {
                image_preview_path = item.path;
              });
            }
          },*/
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: FileImage(File(item.path)), fit: BoxFit.cover),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
              onTap: () {
                setState(() {
                  data_items.remove(item);
                  /*final lastItem = data_items.last;
                  if(lastItem is PhotoItem){
                    image_preview_path = lastItem.path;
                  }else{
                    data_items.add(InfoItem(AppStrings.select_photo_info));
                    start_task_visibility = false;
                    image_preview_path = AppStrings.preview_default_img_path;
                  }
                */
                });
              },
              child: Container(
                  height: 25.0,
                  width: 25.0,
                  margin: EdgeInsets.only(top: 3.0, right: 3.0),
                  //padding: EdgeInsets.only(left: 0.0, right: 5.0, top: 5.0, bottom: 0.0),
                  color: AppColors.notification_color,
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.clear,
                      color: Colors.red,
                      size: 18,
                    ),
                  ))),
        )
      ],
    );
  }

  Stack buildAudioStack(AudioItem item) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () async {
            if (!item.is_playing) {
              File fin = await File(item.path);
              flutterSound.startPlayer(fin.path).then((path) {
                print('startPlayer: $path');
                setState(() {
                  item.is_playing = true;
                });
                playerSubscription =
                    flutterSound.onPlayerStateChanged.listen((e) {
                  if (e != null) {
                    if (e.currentPosition == e.duration) {
                      setState(() {
                        playerSubscription.cancel();
                        item.is_playing = false;
                      });
                    }
                  }
                });
              });
            }
          },
          child: Container(
              alignment: Alignment.center,
              child: Icon(Icons.music_note, size: 70, color: Colors.grey[200])),
        ),
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
              onTap: () {
                if (item.is_playing) {
                  flutterSound.stopPlayer().then((val) {
                    playerSubscription.cancel();
                    setState(() {
                      item.is_playing = false;
                      data_items.remove(item);
                    });
                  });
                } else {
                  setState(() {
                    data_items.remove(item);
                  });
                }
              },
              child: Container(
                  height: 20.0,
                  width: 20.0,
                  margin: EdgeInsets.only(top: 3.0, right: 3.0),
                  //padding: EdgeInsets.only(left: 0.0, right: 5.0, top: 5.0, bottom: 0.0),
                  color: AppColors.notification_color,
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.clear,
                      color: Colors.red,
                      size: 18,
                    ),
                  ))),
        ),
        Container(
            margin: EdgeInsets.only(bottom: 3.0, left: 3.0, right: 3.0),
            alignment: Alignment.bottomCenter,
            child: Text(
              path.basename(item.path),
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            )),
        Visibility(
          visible: item.is_playing,
          child: GestureDetector(
            onTap: () {
              flutterSound.stopPlayer().then((val) {
                playerSubscription.cancel();
                setState(() {
                  item.is_playing = false;
                });
              });
            },
            child: Container(
              alignment: Alignment.center,
              child: Icon(Icons.pause_circle_outline,
                  size: 30, color: Colors.black),
            ),
          ),
        )
      ],
    );
  }

  Column buildQueryParameterTextInputColumn(Parameter p) {
    query_controllers.putIfAbsent(p, () => TextEditingController()..text = query_values[p]);
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Text(p.name,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: query_controllers[p],
              //initialValue: query_values[p],
            ))
      ],
    );
  }

  Column buildQueryParameterEnumInputColumn(Parameter p) {
    List<DropdownMenuItem<String>> enum_items = new List();
    for (String i in p.enum_) {
      enum_items.add(DropdownMenuItem(value: i, child: Text(i)));
    }

    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Text(p.name,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: DropdownButton(
            items: enum_items,
            value: query_values[p],
            onChanged: (selectedItem) {
              changedQueryEnumValue(selectedItem, p);
            },
          ),
        )
      ],
    );
  }

  //setting defauld data to page when it starts
  void setDefaultData() {
    image_preview_path = AppStrings.preview_default_img_path;
    data_items = [
      //ButtonItem(AppStrings.camera),
      //ButtonItem(AppStrings.file),
      //InfoItem(AppStrings.select_photo_info),
    ];
    start_task_visibility = false;

    media_input_type = "";
    data_inputs = List();
    query_parameters = [];
    query_values = Map();
    flutterSound = FlutterSound();
    urlAddButtonVisibility = false;
    urlController = TextEditingController();
    query_controllers = Map();
  }

  //method when user chose different data input type
  void changedDataInputType(String selectedItem) {
    if (selectedItem != current_data_input) {
      setState(() {
        current_data_input = selectedItem;
        data_items.clear();
      });
    }
  }

  //method when user chose different enum value for query parameter
  void changedQueryEnumValue(String selectedItem, Parameter query_paremeter) {
    //var key = query_values.keys.firstWhere((k) => query_values[k] == selectedItem, orElse: () => null);
    setState(() {
      query_values[query_paremeter] = selectedItem;
    });
  }

  void pressedPickImageFromGallery() async {
    try {
      final path = await widget.imagePickerHelper
          .getPathOfPickedImage(ImageSource.gallery);
      //print('Picked image path: $path');
      final newPath = await FileManager.copyFileAndGetPath(path);

      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(newPath);
      print("Analysis page: " + properties.width.toString());

      var imagePath;

      if (properties.width > 2000 && properties.height > 2000) {
        File compressedFile =
            await FlutterNativeImage.compressImage(newPath, quality: 90);
        imagePath = compressedFile.path;
      } else {
        imagePath = newPath;
      }

      setState(() {
        data_items.add(PhotoItem(imagePath));
      });

      /*if(imagePath.isNotEmpty && data_items.length >= 3){
        if(data_items[2] is InfoItem){
          data_items.removeLast();
        }
        setState(() {
          image_preview_path = imagePath;
          data_items.add(PhotoItem(imagePath));
          start_task_visibility = true;
        });
      }*/
    } catch (e) {
      print('Error: $e');
    }
  }

  void pressedPickImageFromCamera() async {
    try {
      final path = await widget.imagePickerHelper
          .getPathOfPickedImage(ImageSource.camera);

      final newPath = await FileManager.copyFileAndGetPath(path);

      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(newPath);
      print("Analysis page: " + properties.width.toString());

      var imagePath;

      if (properties.width > 2000 && properties.height > 2000) {
        File compressedFile =
            await FlutterNativeImage.compressImage(newPath, quality: 90);
        imagePath = compressedFile.path;
      } else {
        imagePath = newPath;
      }

      setState(() {
        data_items.add(PhotoItem(imagePath));
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void pressedPickImageFromURL(String url) async {
    if(FileDownloader.isAcceptedImageFile(url)) {
      String filePath = await FileDownloader.downloadFile(url);
      if (filePath != null) {
        urlController.clear();
        setState(() {
          data_items.add(PhotoItem(filePath, url: url));
          urlAddButtonVisibility = false;
        });
      } else {
        showSnackbar("File downloading problem");
      }
    } else {
      showSnackbar("Wrong file extension");
    }
  }

  void pressedPickAudioFromRecorder() async {
    showSnackbar("Not implemented yet");
    // widget.onPushRecorder();
  }

  void pressedPickAudioFromFile() async {
    try {
      final path = await FilePickerHelper.getPathOfPickedAudio();
      if (path != null) {
        setState(() {
          data_items.add(AudioItem(path, false));
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void pressedPickAudioFromURL(String url) async {
    if(FileDownloader.isAcceptedAudioFile(url)) {
      String filePath = await FileDownloader.downloadFile(url);
      if (filePath != null) {
        urlController.clear();
        setState(() {
          data_items.add(AudioItem(filePath, false, url: url));
          urlAddButtonVisibility = false;
        });
      } else {
        showSnackbar("File downloading problem");
      }
    } else {
      showSnackbar("Wrong file extension");
    }
  }

  void pressedAnalyseButton(String dataInputType, List dataInputs, Map queryValues) async {
    RecognitionApi recognitionApi = RecognitionApi();
    Map<String, dynamic> queryMap = Map();
    for(Parameter p in queryValues.keys) {
      if(p.enum_ == null) {
        queryMap.putIfAbsent(p.name, () => query_controllers[p].text);
      } else {
        queryMap.putIfAbsent(p.name, () => queryValues[p]);
      }
    }
    if(dataInputType == "urls") {
      String urlsVal = "";
      for(int i=0; i<dataInputs.length; i++) {
        urlsVal = urlsVal + dataInputs[i].url;
        if(i+1 < dataInputs.length) {
          urlsVal = urlsVal + ",";
        }
      }
      queryMap.putIfAbsent("urls", () => urlsVal);

      recognitionApi.postPredictUrl(queryMap)
          .then((val) {
            showSnackbar(val);
            //widget.onPush(Task());
          })
          .catchError((error) {
            showSnackbar(error.toString());
      });
    } else if(dataInputType == "data") {
      recognitionApi.postPredictData(dataInputs, queryMap)
          .then((val){
            showSnackbar(val);
          })
          .catchError((e) {
            showSnackbar(e.toString());
          });
    }
  }

  bool isRequiredDataFilled() {
    if(data_items.length != 0) {
      return true;
    } else {
      return false;
    }
  }


  //old code
  /*Container buildPhotosManagementBar() {
    return Container(
      height: 85.0,
      width: double.infinity,
      color: AppColors.accent_color,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: data_items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = data_items[index];

            if (item is ButtonItem) {
              if (item.text == AppStrings.camera) {
                return RaisedButton(
                    key: Key("cameraButton"),
                    elevation: 0.0,
                    padding: EdgeInsets.all(10.0),
                    color: AppColors.accent_color,
                    onPressed: pressedPickImageFromCamera,
                    child: getButtonColumn(
                        Icons.photo_camera, item.text, Colors.black));
              } else if (item.text == AppStrings.file) {
                return RaisedButton(
                    key: Key("galleryButton"),
                    elevation: 0.0,
                    padding: EdgeInsets.all(10.0),
                    color: AppColors.accent_color,
                    onPressed: pressedPickImageFromGallery,
                    child: getButtonColumn(
                        Icons.file_upload, item.text, Colors.black));
              }
            } else if (item is InfoItem) {
              return Container(
                padding: EdgeInsets.all(5.0),
                child: Material(
                  color: AppColors.accent_color,
                  child: Center(child: Text(item.text)),
                ),
              );
            } else if (item is PhotoItem) {
              return Container(
                width: 85.0,
                padding: EdgeInsets.all(5.0),
                child: Material(elevation: 4.0, child: buildImageStack(item)),
              );
            }
          }),
    );
  }*/

  Expanded buildPreviewImageExpanded(String path) {
    var pv;

    if (path != AppStrings.preview_default_img_path) {
      pv = PhotoView(
        imageProvider: AssetImage(path),
        backgroundDecoration: BoxDecoration(color: Colors.white),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained * 1.8,
        initialScale: PhotoViewComputedScale.contained,
      );
    } else {
      pv = Image.asset(path);
    }

    return Expanded(
      child: Stack(
        children: <Widget>[
          Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  if (image_preview_path ==
                      AppStrings.preview_default_img_path) {
                    showSnackbar(AppStrings.default_preview_message);
                  }
                },
                child: ClipRect(child: pv),
              )),
          Align(
            alignment: Alignment.topCenter,
            child: FadeTransition(
                child: SlideTransition(
                  position: offset,
                  child: Container(
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

  Column getButtonColumn(IconData icon, String text, Color color) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Icon(icon, color: color),
          Text(
            text,
            style: TextStyle(color: color),
          ),
        ]);
  }

  List<PhotoView> buildPhotoViewsList(List<String> imgPaths) {
    List<PhotoView> imagesWidgets = [];

    for (String ip in imgPaths) {
      imagesWidgets.add(PhotoView(
        imageProvider: AssetImage(ip),
        backgroundDecoration: BoxDecoration(color: Colors.white),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained * 1.8,
        initialScale: PhotoViewComputedScale.contained,
      ));
    }
    return imagesWidgets;
  }

  onStartTaskPressed() async {
    controller.forward();

    final photoPaths = ListItem.getPhotosPathsList(data_items);

    String stringResponse = await MockRecognitionApi()
        .postTask(photoPaths)
        .catchError((Object error) {
      setState(() {
        controller.reset();
        showSnackbar(error.toString());
      });
    });

    final parsed = json.decode(stringResponse);
    Results results = Results.fromJson(parsed);
    controller.reset();
    addTaskToRepository(photoPaths, results).then((t) {
      setState(() {
        setDefaultData();
      });
      widget.onPush(t);
    });
  }

  Future<Task> addTaskToRepository(
      List<String> photoPaths, Results results) async {
    HistoryRepository hr = HistoryRepository();
    return await hr.addTask(photoPaths, results);
  }


  //used code
  showSnackbar(String text) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(text),
    ));
  }

  //loading from JSON file from assets
  Future<Post> loadPredictEndpointInfo() async {
    return await AssetsManager.getPredictEndpointInfo();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}

class ImagePickerHelper {
  Future<String> getPathOfPickedImage(ImageSource imageSource) async {
    final File file = await ImagePicker.pickImage(source: imageSource);
    return file?.path;
  }
}

class FilePickerHelper {
  static Future<String> getPathOfPickedAudio() async {
    File file = await FilePicker.getFile(type: FileType.AUDIO);
    return file?.path;
  }
}

/*class FileManager{
  Future<String> copyFileAndGetPath(String path) async {
    final dir = await getApplicationDocumentsDirectory();
    final dirPath = dir.path;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final timestampString = timestamp.toString();
    File newImg = await File(path).copy("$dirPath/$timestampString.jpg");
    return newImg?.path;
  }
}*/
