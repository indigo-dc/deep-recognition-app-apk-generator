import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class AssetsManager {
  /*static getPredictEndpointInfo() async {
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
  }*/

  static Future<Map<String, dynamic>> loadJsonAsset(String responsePath) async {
    String jsonString = await rootBundle.loadString(responsePath);
    return json.decode(jsonString);
  }

  static Future<Map<String, dynamic>> loadJsonFile(String filePath) async {
    final file = new File(filePath);
    return jsonDecode(await file.readAsString());
  }
}