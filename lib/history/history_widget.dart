import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/task/task.dart';
import 'package:deep_app/history/history_repository.dart';
import 'dart:io';
import 'package:transparent_image/transparent_image.dart';

class HistoryPlaceholderWidget extends StatefulWidget {

  HistoryPlaceholderWidget();

  List<Task> tasks;

  @override
  State<StatefulWidget> createState() {
    return HistoryPlaceholderState();
  }
}

class HistoryPlaceholderState extends State<HistoryPlaceholderWidget>{

  @override
  void initState() {
    loadTasks().then((t){
      setState(() {
        widget.tasks = t;
        for(Task t in widget.tasks){
          precacheImage(FileImage(File(t.image_paths[0])),context);
        }
      });
    });

    //super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks == null){
      return Container();
    }else{
      return buildGridWidget();
    }
  }

  buildGridWidget(){
    return Column(
      children: <Widget>[
        AppBar(
          backgroundColor: AppColors.primary_color,
          title: Text(AppStrings.app_label),
        ),
        Expanded(
          child:  GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 15.0,
              crossAxisSpacing: 15.0,
              //padding: EdgeInsets.all(10.0),
              childAspectRatio: 1.5,
              padding: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0, bottom: 0.0),
              children: buildGridTiles(widget.tasks)
          ),
        )
      ],
    );
  }

  List<Widget> buildGridTiles(List<Task> tasks){
    return List<Container>.generate(tasks.length,
            (int index){
          return Container(
            child: Stack(
              children: <Widget>[
                FadeInImage(
                  fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: MemoryImage(kTransparentImage),//AssetImage("assets/images/plant.png"),
                    image: FileImage(File(tasks[index].image_paths[0]))
                ),
                /*Image.file(File(
                    tasks[index].image_paths[0]),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),*/
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: AppColors.notification_color,
                    width: double.infinity,
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      tasks[index].results.predictions[0].label,
                      style: TextStyle(
                          color: Colors.white
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }
    );
  }

  buildResultsWidget(){
    
  }

  Future<List<Task>> loadTasks() async{
    HistoryRepository historyRepository = HistoryRepository();
    final tasks = await historyRepository.getTasks();
    return tasks;
  }

}