import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/analysis/task.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:page_indicator/page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:deep_app/history/history_repository.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path/path.dart' as path;

class ResultPage extends StatefulWidget {
  ResultPage({this.task});
  final Task task;

  @override
  State<StatefulWidget> createState() {
    return ResultPageState();
  }
}

class ResultPageState extends State<ResultPage> {
  bool is_deleted;
  Task task;
  FlutterSound flutterSound;
  bool is_playing;
  StreamSubscription playerSubscription;

  @override
  void initState() {
    task = widget.task;
    flutterSound = FlutterSound();
    is_playing = false;
    is_deleted = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var media_items;
    if(task.media_input_type == "audio") {
      media_items = getAudioWidgetsList(task.file_paths);
    } else if(task.media_input_type == "image") {
      media_items = getImagesWidgetList(task.file_paths);
    }

    return WillPopScope(
      onWillPop: () {
        if(is_playing) {
          playerSubscription.cancel();
          flutterSound.stopPlayer();
          setState(() {
            is_playing = false;
          });
        }
        return Future.value(true);
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary_color,
            title: Text(AppStrings.app_label),
            actions: <Widget>[
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return showAlertDialog(context, task.id);
                        }
                    ).then((val){
                      if(is_deleted){
                        Navigator.pop(context, true);
                      }
                    });
                  },
                  icon: Icon(
                    Icons.delete,
                    size: 25.0,
                    color: Colors.white,
                  )
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Stack(
                  children: <Widget>[
                    PageIndicatorContainer(
                      pageView: PageView(
                        onPageChanged: (v){
                          if(is_playing) {
                            playerSubscription.cancel();
                            flutterSound.stopPlayer();
                            setState(() {
                              is_playing = false;
                            });
                          }
                        },
                        children: media_items,
                      ),
                      align: IndicatorAlign.bottom,
                      length: media_items.length,
                      padding: EdgeInsets.only(bottom: 20.0),
                      size: 10.0,
                      indicatorSpace: 10.0,
                      indicatorSelectorColor: Colors.white,
                      indicatorColor: Colors.grey,
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  child: ListView.builder(
                      padding: EdgeInsets.only(top: 0.0),
                      itemCount: task.predictResponse.predictions.labels.length,
                      itemBuilder: (BuildContext context, int index) {
                        //final item = task.results.predictions[index];
                        var background_color;
                        var text_color;
                        var iconContainer;

                        if(index == 0){

                          background_color = AppColors.primary_dark_color;

                          var icon;

                          if(task.predictResponse.predictions.probabilities[index] <= 0.3){
                            text_color = Colors.red;
                            icon = Icon(
                              Icons.warning,
                              color: Colors.white,
                            );
                          }else{
                            text_color = Colors.white;
                            icon = Icon(
                              Icons.star,
                              color: Colors.orangeAccent,
                            );
                          }
                          iconContainer = Container(
                            child: icon,
                          );

                        }else{
                          text_color = AppColors.primary_dark_color;
                          background_color = Colors.transparent;
                          iconContainer = Container();
                        }

                        return Container(
                          color: background_color,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    flex: 17,
                                    child: iconContainer
                                ),
                                Expanded(
                                  flex: 50,
                                  child: Text(
                                    task.predictResponse.predictions.labels[index],
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: text_color,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 13,
                                  child:
                                  GestureDetector(
                                    onTap: () {
                                      //print("Tapped info icon");
                                      _launchURL(task.predictResponse.predictions.links.wikipedia[index]);
                                    },
                                    child: Icon(
                                      Icons.info,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 13,
                                  child:
                                  GestureDetector(
                                    onTap: () {
                                      //print("Tapped info icon");
                                      _launchURL(task.predictResponse.predictions.links.googleImages[index]);
                                    },
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 20,
                                  child: Text(
                                    (task.predictResponse.predictions.probabilities[index] * 100).toStringAsFixed(2) + " %",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        color: text_color
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }
                  ),
                ),
              )
            ],
          )
      ),
    );
  }


  List<Widget> getImagesWidgetList(List <String> imgPaths){
    List<Widget> imagesWidgets  = [];

    for(String ip in imgPaths){
      imagesWidgets.add(
        //Image.asset(ip)
          PhotoView(
            imageProvider: FileImage(File(ip)),
            backgroundDecoration: BoxDecoration(color: Colors.white),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.contained * 1.8,
            initialScale: PhotoViewComputedScale.contained,
          )
      );
    }

    return imagesWidgets;
  }

  List<Widget> getAudioWidgetsList(List<String> audioPaths) {
    return audioPaths.map((ap) {
      return Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: Icon(Icons.music_note, size: 220, color: Colors.grey[200]),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Text(path.basename(ap))
          ),
          GestureDetector(
            onTap: () {
              if(is_playing) {
                playerSubscription.cancel();
                flutterSound.stopPlayer();
                setState(() {
                  is_playing = false;
                });
              }else {
                flutterSound.startPlayer(ap).then((path) {
                  playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
                    if(e != null) {
                      if (e.currentPosition == e.duration) {
                        setState(() {
                          playerSubscription.cancel();
                          is_playing = false;
                        });
                      }
                    }
                  });
                  setState(() {
                    is_playing = true;
                  });
                });
              }
            },
            child: Align(
                alignment: Alignment.center,
                child: !is_playing ? Icon(Icons.play_circle_outline, size: 80) : Icon(Icons.pause_circle_outline, size: 80)),
          )
        ],
      );
    }).toList();
  }

  Widget showAlertDialog(BuildContext context, int taskid){
    return AlertDialog(
      content: Text(AppStrings.delete_alert_content),
      actions: <Widget>[
        FlatButton(
            child: Text(AppStrings.yes),
            onPressed: () {
              _deleteTaskFromRepository(taskid).then((x){
                Navigator.pop(context);
                is_deleted = true;
              });
            }
        ),
        FlatButton(
          child: Text(AppStrings.no),
          onPressed: () {
            Navigator.pop(context);
            is_deleted = false;
          },
        )
      ],
    );
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      final msg = AppStrings.launch_exception;
      throw "$msg $url";
    }
  }

  Future<bool> _deleteTaskFromRepository(int taskId) async{
    HistoryRepository historyRepository = HistoryRepository();
    return await historyRepository.removeTask(taskId);
    return true;
  }

}
