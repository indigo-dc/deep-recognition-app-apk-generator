import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/task/task.dart';
import 'package:deep_app/history/history_repository.dart';

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
          child:  GridView.extent(
              maxCrossAxisExtent: 150.0,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 5.0,
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
                Image.asset(
                    tasks[index].image_paths[0],
                  fit: BoxFit.cover,
                ),
                Text(tasks[index].results.predictions[0].label)
              ],
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

}