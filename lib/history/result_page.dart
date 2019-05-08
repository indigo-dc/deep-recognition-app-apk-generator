import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/analysis/task.dart';
import 'package:page_indicator/page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:deep_app/history/history_repository.dart';
import 'package:photo_view/photo_view.dart';

class ResultPage extends StatelessWidget {
  ResultPage({this.task});
  final Task task;
  bool isDeleted = false;

  @override
  Widget build(BuildContext context) {

    var images = getImagesWidgetList(task.image_paths);

    return Scaffold(
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
                    if(isDeleted){
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
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    child: ListView.builder(
                        padding: EdgeInsets.only(top: 0.0),
                        itemCount: task.results.predictions.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = task.results.predictions[index];
                          var background_color;
                          var text_color;
                          var iconContainer;

                          if(index == 0){

                            background_color = AppColors.primary_dark_color;

                            var icon;

                            if(item.probability <= 0.3){
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
                                      item.label,
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
                                        _launchURL(item.info.links[1].url);
                                      },
                                      child: Icon(
                                        Icons.info,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 20,
                                    child: Text(
                                      (item.probability * 100).toStringAsFixed(2) + " %",
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
    );
  }

  List<Widget> getImagesWidgetList(List <String> imgPaths){
    List<Widget> imagesWidgets  = [];

    for(String ip in imgPaths){
      imagesWidgets.add(
          //Image.asset(ip)
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

  Widget showAlertDialog(BuildContext context, int taskid){
    return AlertDialog(
      content: Text(AppStrings.delete_alert_content),
      actions: <Widget>[
        FlatButton(
            child: Text(AppStrings.yes),
            onPressed: () {
              _deleteTaskFromRepository(taskid).then((x){
                Navigator.pop(context);
                isDeleted = true;
              });
            }
        ),
        FlatButton(
          child: Text(AppStrings.no),
          onPressed: () {
            Navigator.pop(context);
            isDeleted = false;
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
  }

}
