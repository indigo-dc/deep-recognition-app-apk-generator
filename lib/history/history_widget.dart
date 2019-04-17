import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/task/task.dart';
import 'package:deep_app/history/history_repository.dart';
import 'dart:io';
import 'package:transparent_image/transparent_image.dart';
import 'package:deep_app/task/results_page_widget.dart';

class HistoryPlaceholderWidget extends StatefulWidget {

  HistoryPlaceholderWidget();

  List<Task> tasks;

  //bool resultsPage = false;

  Task currentTask;

  @override
  State<StatefulWidget> createState() {
    return HistoryPlaceholderState();
  }
}

class HistoryPlaceholderState extends State<HistoryPlaceholderWidget> with AutomaticKeepAliveClientMixin{

  bool resultsPage = false;



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
        if(resultsPage){
        return buildResultsWidget(widget.currentTask);
      }else{
        return buildGridWidget();
      }
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
            child: GestureDetector(
              onTap: () {
                setState(() {
                  widget.currentTask = tasks[index];
                  resultsPage = true;
                });
              },
              child: Stack(
                children: <Widget>[
                  FadeInImage(
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: MemoryImage(kTransparentImage),//AssetImage("assets/images/plant.png"),
                      image: FileImage(File(tasks[index].image_paths[0]))
                  ),
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
            ),
          );
        }
    );
  }

  buildResultsWidget(Task task){
    var appBar;
    if(Platform.isAndroid){
      appBar = buildAndroidAppBar();
    }else{
      appBar = buildIOSAppBar();
    }
    return Column(
        children: <Widget>[
          appBar,
          ResultsPageWidget(task)
        ]
    );
  }

  Widget buildIOSAppBar(){
    return AppBar(
      backgroundColor: AppColors.primary_color,
      title: Text(AppStrings.app_label),
      leading: Icon(Icons.arrow_back_ios),
      actions: <Widget>[
        IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text(AppStrings.delete_alert_content),
                      actions: <Widget>[
                        FlatButton(
                            child: Text(AppStrings.yes),
                            onPressed: () {
                              deleteTaskFromRepository(widget.currentTask.id).then((d){
                                return loadTasks();
                              }).then((l){
                                setState(() {
                                  widget.tasks = l;
                                  resultsPage = false;
                                });
                              });
                              Navigator.pop(context);
                            }
                        ),
                        FlatButton(
                          child: Text(AppStrings.no),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  }
              );
            },
            icon: Icon(
              Icons.delete,
              size: 25.0,
              color: Colors.white,
            )
        ),
      ],
    );
  }

  Widget buildAndroidAppBar(){
    return AppBar(
      backgroundColor: AppColors.primary_color,
      title: Text(AppStrings.app_label),
      actions: <Widget>[
        IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text(AppStrings.delete_alert_content),
                      actions: <Widget>[
                        FlatButton(
                            child: Text(AppStrings.yes),
                            onPressed: () {
                              deleteTaskFromRepository(widget.currentTask.id).then((d){
                                return loadTasks();
                              }).then((l){
                                setState(() {
                                  widget.tasks = l;
                                  resultsPage = false;
                                });
                              });
                              Navigator.pop(context);
                            }
                        ),
                        FlatButton(
                          child: Text(AppStrings.no),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  }
              );
            },
            icon: Icon(
              Icons.delete,
              size: 25.0,
              color: Colors.white,
            )
        ),
      ],
    );
  }

  onBackPressed(){
    setState(() {

    });
  }

  Future<List<Task>> loadTasks() async{
    HistoryRepository historyRepository = HistoryRepository();
    final tasks = await historyRepository.getTasks();
    return tasks;
  }

  Future<bool>deleteTaskFromRepository(int taskId) async{
    HistoryRepository historyRepository = HistoryRepository();
    return await historyRepository.removeTask(taskId);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;

}