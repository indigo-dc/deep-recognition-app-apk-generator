import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deep_app/task/task.dart';
import 'dart:convert';


class OfflineStorage{

  String TAG = "OfflineStorage";

   static putList(TasksList tasksList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //TasksList tasksList = TasksList(tasks: tasks);
    final myJsonStr = jsonEncode(tasksList.toJson());
    print("json encoded length: " + myJsonStr.length.toString());
    print(tasksList.toJson());
    await prefs.setString('tasks', myJsonStr);
  }

  static Future<TasksList> getList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString("tasks");
    if(tasksJson != null){
      print("json decoded length: " + tasksJson.length.toString());
      Map<String, dynamic> value = jsonDecode(tasksJson);
      print(value);
      TasksList tasksList = TasksList.fromJson(value);
      print(tasksList);
      return tasksList;
    }else{
      print("json decoded length: empty");
      return new TasksList(tasks: []);
    }
  }
}

class TasksList{
  List<Task> tasks;

  TasksList({this.tasks});

  factory TasksList.fromJson(Map<String, dynamic> json) {
    var list = json["tasks"] as List;
    List<Task> tasks = list.map((i) =>
        Task.fromJson(i)).toList();
    return TasksList(
        tasks: tasks
    );
  }

  Map<String, dynamic> toJson() =>
      {
        "tasks": tasks.map((t) => t.toJson()).toList()
      };
}