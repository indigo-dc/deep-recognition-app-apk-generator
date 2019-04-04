import 'package:flutter/material.dart';
import 'package:deep_app/task/task.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:page_indicator/page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultsPageWidget extends StatelessWidget{
  final Task task;

  ResultsPageWidget(this.task);

  @override
  Widget build(BuildContext context) {

    var images = getImagesWidgetList(task.images_paths);

    return Expanded(
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
                            color: Colors.grey,
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
                                    fontSize: AppDimensions.task_result_row_size,
                                    color: text_color,
                                  ),
                                ),
                              ),
                              Expanded(
                                  flex: 15,
                                  child:
                                  GestureDetector(
                                    onTap: () {
                                      print("Tapped info icon");
                                      _launchURL(item.info.links[1].url);
                                    },
                                    child: Icon(
                                      Icons.info,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ),
                              Expanded(
                                flex: 18,
                                child: Text(
                                  (item.probability * 100).toStringAsFixed(2) + " %",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: AppDimensions.task_result_row_size,
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

  List<Widget> getImagesWidgetList(List <String> img_paths){
    List<Widget> imagesWidgets  = [];

    for(String ip in img_paths){
      imagesWidgets.add(Image.asset(ip));
    }

    return imagesWidgets;
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}