import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deep_app/task/task.dart';
import 'dart:convert';


class OfflineStorage{

  String TAG = "OfflineStorage";

   static putList(List<Task> tasks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    TasksList tasksList = TasksList(tasks);
    final myJsonStr = jsonEncode(tasksList);
    print(myJsonStr);
  }

}

class TasksList{
  List<Task> tasks;

  TasksList(this.tasks);

  //Map toJson() => {"tasksList": tasks};

  TasksList.fromJson(Map<String, dynamic> json)
      : tasks = json['name'];

  Map<String, dynamic> toJson() =>
      {
        "tasks": tasks
      };
}