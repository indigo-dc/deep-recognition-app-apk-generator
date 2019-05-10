import 'package:deep_app/analysis/analysis_page.dart';
import 'package:deep_app/analysis/task.dart';
import 'package:deep_app/app/recognition_app.dart';
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

  testWidgets('Pick image from gallery test', (WidgetTester tester) async {
    // Build our app and trigger a frame.

    MockImagePicker mockImagePicker = MockImagePicker();
    when(mockImagePicker.getPathOfPickedImage(ImageSource.gallery)).thenAnswer((invocation) => Future.value('test path'));

    AnalysisPage page = AnalysisPage(onPush: (task) {}, imagePickerHelper: mockImagePicker);

    await tester.pumpWidget(makeTestableWidget(child: page));

    await tester.tap(find.byKey(Key('galleryButton')));

    verify(mockImagePicker.getPathOfPickedImage(ImageSource.gallery));

    //tester.pumpAndSettle();

    expect(find.byKey(Key("startTaskIcon")), findsOneWidget);

    // Verify that our counter starts at 0.
    /*expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);*/
  });
}