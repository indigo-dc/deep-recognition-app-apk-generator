import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/analysis/task.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:io';
import 'package:deep_app/history/history_repository.dart';
import 'package:deep_app/history/result_page.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({this.onPush});
  final ValueChanged<Task> onPush;

  @override
  State<StatefulWidget> createState() {
    return HistoryPageState();
  }
}

class HistoryPageState extends State<HistoryPage> with AutomaticKeepAliveClientMixin{
  List<Task> tasks = [];
  Task currentTask;

  @override
  void didUpdateWidget(HistoryPage oldWidget) {
    if(Navigator.canPop(context)){
      Navigator.pop(context);
    }
    loadTasks().then((t){
      setState(() {
        //print(t);
        tasks = t;
        /*for(Task t in tasks){
          precacheImage(FileImage(File(t.image_paths[0])),context);
        }*/
      });
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {

    var body;
    if(tasks.isNotEmpty){
      body = GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 15.0,
          crossAxisSpacing: 15.0,
          childAspectRatio: 1.5,
          padding: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0, bottom: 0.0),
          children: buildGridTiles(tasks)
      );
    }else{
      body = Container(
        child: Align(
          alignment: Alignment.center,
          child: Text(AppStrings.no_history),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary_color,
        title: Text(AppStrings.app_label),
      ),
      body: body
    );
  }

  List<Widget> buildGridTiles(List<Task> tasks){
    return List<Container>.generate(tasks.length,
            (int index){
          return Container(
            child: GestureDetector(
              onTap: () {
                var future = Navigator.push(context, MaterialPageRoute(builder: (context) => ResultPage(task: tasks[index])));
                future.then((val){
                  if(val == true){
                    loadTasks().then((t){
                      setState(() {
                        this.tasks = t;
                      });
                    });
                  }
                });
              },
              child: Stack(
                children: <Widget>[
                  FadeInImage(
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: MemoryImage(kTransparentImage),
                      image: FileImage(File(tasks[index].file_paths[0]))
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: AppColors.notification_color,
                      width: double.infinity,
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                          getTaskTitleString(tasks[index].predictResponse),
                        //PredictionTitleManager.getTitleForPrediction(/*tasks[index].results.predictions[0]*/ ),
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  Future<List<Task>> loadTasks() async{
    HistoryRepository historyRepository = HistoryRepository();
    final tasks = await historyRepository.getTasks();
    return tasks;
  }

  String getTaskTitleString(PredictResponse predictResponse){
    if(predictResponse.predictions.probabilities[0] < 0.3){
      return predictResponse.predictions.labels[0] + " (!)";
    }else{
      return predictResponse.predictions.labels[0];
    }
  }

  @override
  bool get wantKeepAlive => false;

}

/*class PredictionTitleManager{
  static String getTitleForPrediction(Prediction prediction){
    if(prediction.probability < 0.3){
      return prediction.label + " (!)";
    }else{
      return prediction.label;
    }
  }
}*/