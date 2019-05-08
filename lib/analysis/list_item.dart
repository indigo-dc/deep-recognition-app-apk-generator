abstract class ListItem{}

class ButtonItem implements ListItem {
  final String text;
  ButtonItem(this.text);
}

class InfoItem implements ListItem {
  final String text;
  InfoItem(this.text);
}

class PhotoItem implements ListItem {
  final String path;
  PhotoItem(this.path);
}