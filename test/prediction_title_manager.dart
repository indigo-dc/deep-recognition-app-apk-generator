import 'package:deep_app/analysis/task.dart';
import 'package:deep_app/history/history_page.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {

  test('Low probability test', () {
    Prediction prediction = Prediction(
        info: Info(
            links: Links(
                wikipedia: "https://www.google.es/search?q=Anethum+graveolens&tbm=isch",
                google_images: "https://en.wikipedia.org/wiki/Anethum_graveolens"
            ),
            metadata: ""
        ),
        label_id: 999,
        probability: 0.299,
        label: "Aconitum napellus"
    );

    var result =  PredictionTitleManager.getTitleForPrediction(prediction);
    expect(result, "Aconitum napellus (!)");
  });


  test('High probability test', () {
    Prediction prediction = Prediction(
        info: Info(
            links: Links(
                wikipedia: "https://www.google.es/search?q=Anethum+graveolens&tbm=isch",
                google_images: "https://en.wikipedia.org/wiki/Anethum_graveolens"
            ),
            metadata: ""
        ),
        label_id: 999,
        probability: 0.3,
        label: "Aconitum napellus"
    );

    var result =  PredictionTitleManager.getTitleForPrediction(prediction);
    expect(result, "Aconitum napellus");
  });
}
