import 'dart:math';

import 'package:deep_app/analysis/analysis_page.dart';
import 'package:deep_app/analysis/list_item.dart';
import 'package:deep_app/analysis/post.dart';
import 'package:deep_app/utils/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';

class MockImagePicker extends Mock implements ImagePickerHelper {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('AnalysisPage has analyse button', (WidgetTester tester) async {
    MockImagePicker mockImagePicker = MockImagePicker();
    AnalysisPage page = AnalysisPage(onPush: (task) {}, imagePickerHelper: mockImagePicker);

    await tester.pumpWidget(makeTestableWidget(child: page));

    final StatefulElement innerElement = tester.element(find.byType(AnalysisPage));
    final AnalysisPageState analysisPageState = innerElement.state as AnalysisPageState;

    expect(analysisPageState.widget, page);
    expect(analysisPageState.did_init_state, isTrue);

    analysisPageState.post = await tester.runAsync(()async{
      Map<String, dynamic> jsonPredict = await AssetsManager.loadJsonFile("../assets/test/predict.json");
      return analysisPageState.post = Post.fromJson(jsonPredict["post"]);
    });

    await tester.pump();

    expect(find.byKey(Key("analyseButton")), findsOneWidget);
    expect(analysisPageState.data_items, isEmpty);

    analysisPageState.changedDataInputType("urls");
    await tester.pump();
    expect(find.byKey(Key("urlInput")), findsOneWidget);

    await tester.enterText(find.byKey(Key("urlInput")), "https://testfile.com/testimage.jpg");
    expect(analysisPageState.urlController.text,"https://testfile.com/testimage.jpg");

    //print(analysisPageState.urlAddButtonVisibility);
    //expect(find.byKey(Key("addUrlFile")), findsOneWidget);

    //await tester.pump();

    //expect(analysisPageState.isRequiredDataFilled(), isTrue);
    //when(mockImagePicker.getPathOfPickedImage(ImageSource.gallery)).thenAnswer((invocation) => Future.value('test path'));
    //expect(analysisPageState.data_items, isEmpty);

    //expect(find.byKey(Key("listItemPreview")), findsWidgets);
    //await tester.tap(find.byKey(Key('galleryButton')));

    //verify(mockImagePicker.getPathOfPickedImage(ImageSource.gallery));

    //await tester.pump();

    //expect(find.byKey(Key("startTaskIcon")), findsOneWidget);
  });
}