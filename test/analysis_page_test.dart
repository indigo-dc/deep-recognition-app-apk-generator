import 'package:deep_app/analysis/analysis_page.dart';
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

  testWidgets('Start task icon test', (WidgetTester tester) async {

    MockImagePicker mockImagePicker = MockImagePicker();
    when(mockImagePicker.getPathOfPickedImage(ImageSource.gallery)).thenAnswer((invocation) => Future.value('test path'));

    AnalysisPage page = AnalysisPage(onPush: (task) {}, imagePickerHelper: mockImagePicker);

    await tester.pumpWidget(makeTestableWidget(child: page));

    await tester.tap(find.byKey(Key('galleryButton')));

    verify(mockImagePicker.getPathOfPickedImage(ImageSource.gallery));

    await tester.pump();

    expect(find.byKey(Key("startTaskIcon")), findsOneWidget);
  });
}