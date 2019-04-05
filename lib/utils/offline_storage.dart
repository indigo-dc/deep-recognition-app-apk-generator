import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deep_app/task/task.dart';

class OfflineStorage{

  String TAG = "OfflineStorage";

   static putList(List<Task> tasks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

  }

}