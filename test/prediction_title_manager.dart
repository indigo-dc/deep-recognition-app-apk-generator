import 'package:deep_app/analysis/task.dart';
import 'package:deep_app/api/mock_recognition_api.dart';
import 'package:deep_app/history/history_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  test('Low probability test', () async {
    WidgetsFlutterBinding.ensureInitialized();

    MockRecognitionApi mockRecognitionApi = MockRecognitionApi();
    PredictResponse predictResponse = await mockRecognitionApi.postPredictData("assets/res/test/response_for_test_low.json");

    var result = PredictionTitleManager.getTitleForPrediction(predictResponse);
    expect(result, "valley (!)");
  });


  test('High probability test', () async {
    WidgetsFlutterBinding.ensureInitialized();

    MockRecognitionApi mockRecognitionApi = MockRecognitionApi();
    PredictResponse predictResponse = await mockRecognitionApi.postPredictData("assets/res/test/response_for_test_high.json");

    var result = PredictionTitleManager.getTitleForPrediction(predictResponse);
    expect(result, "pot");
  });
}
