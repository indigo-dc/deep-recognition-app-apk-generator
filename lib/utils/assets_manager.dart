import 'dart:convert';

import 'package:deep_app/analysis/post.dart';
import 'package:flutter/services.dart' show rootBundle;

class AssetsManager {
  static getPredictEndpointInfo() async {
    try {
      var predictEndpoint = await rootBundle.loadString(
          'assets/res/predict.json');
      var value = jsonDecode(predictEndpoint);
      var poststring = value["post"];
      print(poststring);
      Post post = Post.fromJson(value['post']);
      return post;
    } catch (e) {
      print('Error: $e');
    }
  }
}