import 'dart:async';
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
  StreamSubscription playerSubscription;
  bool urlAddButtonVisibility;
  TextEditingController urlController;
  bool is_analysis_in_progress;

  bool did_init_state = false;

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
    did_init_state = true;
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
      ),
      body: SingleChildScrollView(
        child: buildPageColumn(),
      ),
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
                key: Key("inputTypeChose"),
                disabledHint: Text(current_data_input),
                value: current_data_input,
                items: items,
                onChanged: !is_analysis_in_progress ? changedDataInputType : null))));

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
            //buildRecorderButtonContainer(),
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
        key: Key("analyseButton"),
        color: AppColors.accent_color,
        onPressed: isRequiredDataFilled() && !is_analysis_in_progress ? () => pressedAnalyseButton(current_data_input, data_items, query_values) : null,
        child: Text("Analyse"),
      ),
    ));

    return Column(
      children: columns,
    );
  }

  //unused
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

  Container buildUrlAudioInput() {
    return Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 8,
              child: TextField(
                enabled: !is_analysis_in_progress,
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
                key: Key("urlInput"),
                enabled: !is_analysis_in_progress,
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
                      key: Key("addUrlFile"),
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

  Stack buildImageStack(PhotoItem item) {
    return Stack(
      children: <Widget>[
        GestureDetector(
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
              onTap: !is_analysis_in_progress ? () {
                setState(() {
                  data_items.remove(item);
                });
              } : null,
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
                      color: !is_analysis_in_progress ? Colors.red : Colors.grey,
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
          onTap: !is_analysis_in_progress ? () async {
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
          } : null,
          child: Container(
              alignment: Alignment.center,
              child: Icon(Icons.music_note, size: 70, color: Colors.grey[200])),
        ),
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
              onTap: !is_analysis_in_progress ? () {
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
              } : null,
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
                      color: !is_analysis_in_progress ? Colors.red : Colors.grey,
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
              style: TextStyle(color: !is_analysis_in_progress ? Colors.black : Colors.grey),
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
    query_controllers.putIfAbsent(
        p, () => TextEditingController()..text = query_values[p]);
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
              enabled: !is_analysis_in_progress,
              controller: query_controllers[p],
              style: TextStyle(color: !is_analysis_in_progress ? Colors.black : Colors.grey),
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
            onChanged: !is_analysis_in_progress ? (selectedItem) => changedQueryEnumValue(selectedItem, p) : null,
            disabledHint: Text(query_values[p]),
          ),
        )
      ],
    );
  }

  //setting defauld data to page when it starts
  void setDefaultData() {
    image_preview_path = AppStrings.preview_default_img_path;
    data_items = [];

    media_input_type = "";
    data_inputs = List();
    query_parameters = [];
    query_values = Map();
    flutterSound = FlutterSound();
    urlAddButtonVisibility = false;
    urlController = TextEditingController();
    query_controllers = Map();
    is_analysis_in_progress = false;
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
    setState(() {
      query_values[query_paremeter] = selectedItem;
    });
  }

  void pressedPickImageFromGallery() async {
    try {
      final path = await widget.imagePickerHelper
          .getPathOfPickedImage(ImageSource.gallery);
      final newPath = await FileManager.copyFileAndGetPath(path);

      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(newPath);
      //print("Analysis page: " + properties.width.toString());

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

  void pressedPickImageFromCamera() async {
    try {
      final path = await widget.imagePickerHelper
          .getPathOfPickedImage(ImageSource.camera);

      final newPath = await FileManager.copyFileAndGetPath(path);

      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(newPath);
      //print("Analysis page: " + properties.width.toString());

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
    if (FileDownloader.isAcceptedImageFile(url)) {
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
    if (FileDownloader.isAcceptedAudioFile(url)) {
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

  Future pressedAnalyseButton(String dataInputType, List dataInputs, Map queryValues) async {
    setState(() {
      is_analysis_in_progress = true;
    });
    RecognitionApi recognitionApi = RecognitionApi();
    Map<String, dynamic> queryMap = Map();
    for (Parameter p in queryValues.keys) {
      if (p.enum_ == null) {
        queryMap.putIfAbsent(p.name, () => query_controllers[p].text);
      } else {
        queryMap.putIfAbsent(p.name, () => queryValues[p]);
      }
    }
    if (dataInputType == "urls") {
      String urlsVal = "";
      for (int i = 0; i < dataInputs.length; i++) {
        urlsVal = urlsVal + dataInputs[i].url;
        if (i + 1 < dataInputs.length) {
          urlsVal = urlsVal + ",";
        }
      }
      queryMap.putIfAbsent("urls", () => urlsVal);

      recognitionApi.postPredictUrl(queryMap).then((val) {
        var filePaths = data_items.map((pi) => pi.path).toList();
        addTaskToRepository(filePaths, val, media_input_type).then((t) {
          setState(() {
            is_analysis_in_progress = false;
            data_items.clear();
          });
          widget.onPush(Task(
              file_paths: filePaths,
              predictResponse: val,
              media_input_type: media_input_type));
        });
      }).catchError((error) {
        showSnackbar(error.toString());
        setState(() {
          is_analysis_in_progress = false;
        });
      });
    } else if (dataInputType == "data") {
      recognitionApi.postPredictData(dataInputs, queryMap).then((val) {
        var filePaths = data_items.map((pi) => pi.path).toList();
        addTaskToRepository(filePaths, val, media_input_type).then((t) {
          setState(() {
            is_analysis_in_progress = false;
            data_items.clear();
          });
          widget.onPush(Task(
              file_paths: filePaths,
              predictResponse: val,
              media_input_type: media_input_type));
        });
      }).catchError((e) {
        showSnackbar(e.toString());
        setState(() {
          is_analysis_in_progress = false;
        });
      });
    }
  }

  bool isRequiredDataFilled() {
    if (data_items.length != 0) {
      return true;
    } else {
      return false;
    }
  }

  //unused
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
          Icon(icon, color: !is_analysis_in_progress ? color : Colors.grey),
          Text(
            text,
            style: TextStyle(color: !is_analysis_in_progress ? color : Colors.grey),
          ),
        ]);
  }

  //unused
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

  Future<Task> addTaskToRepository(List<String> filePaths,
      PredictResponse predictResponse, String mediaInputType) async {
    HistoryRepository hr = HistoryRepository();
    return await hr.addTask(filePaths, predictResponse, mediaInputType);
  }

  showSnackbar(String text) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(text),
    ));
  }

  //loading from JSON file from assets
  Future<Post> loadPredictEndpointInfo() async {
    Map<String, dynamic> json = await AssetsManager.loadJsonAsset("assets/res/predict.json");
    return Post.fromJson(json['post']);
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
