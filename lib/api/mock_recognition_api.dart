import 'package:deep_app/utils/constants.dart';
import 'package:flutter/services.dart' show rootBundle;


class MockRecognitionApi{
  final String server = AppStrings.api_url;

  Future<String> postTask(List<String> photoPaths) async {
    final response = loadAsset();
    return response;
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/res/response_new_api');
  }

}