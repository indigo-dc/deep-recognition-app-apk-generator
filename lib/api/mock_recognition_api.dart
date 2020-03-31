import 'dart:io';

import 'package:deep_app/analysis/task.dart';
import 'package:deep_app/utils/assets_manager.dart';


class MockRecognitionApi{
  Future<PredictResponse> postPredictData(String responsePath) async {
    final Map<String, dynamic> response = await AssetsManager.loadJsonFile(responsePath);
    return PredictResponse.fromJson(response);
  }
}