abstract class ListItem{}

class ButtonItem implements ListItem {
  final int id;
  final String image;
  final String text;
  final int width;
  ButtonItem(this.id, this.image, this.text, this.width);
}

class InfoItem implements ListItem {
  final int id;
  final String text;
  InfoItem(this.id, this.text);
}

class PhotoItem implements ListItem {
  final int id;
  final String textimage;
  PhotoItem(this.id, this.textimage);
}