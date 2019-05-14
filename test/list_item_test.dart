import 'package:deep_app/analysis/list_item.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  test('No PhotoItems test', () {
    List<ListItem> items = [
      ButtonItem(AppStrings.camera),
      ButtonItem(AppStrings.file),
      InfoItem(AppStrings.select_photo_info),
    ];

    var result = ListItem.getPhotosPathsList(items);
    expect(result, []);
  });

  test('PhotoItems included test', () {
    List<ListItem> items = [
      ButtonItem(AppStrings.camera),
      ButtonItem(AppStrings.file),
      InfoItem(AppStrings.select_photo_info),
      PhotoItem("test_photo1_path"),
      PhotoItem("test_photo2_path")
    ];

    var result = ListItem.getPhotosPathsList(items);
    expect(result, ["test_photo1_path", "test_photo2_path"]);
  });

  test('No items test', () {
    List<ListItem> items = [];

    var result = ListItem.getPhotosPathsList(items);
    expect(result, []);
  });
}