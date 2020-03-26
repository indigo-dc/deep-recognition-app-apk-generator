abstract class ListItem{
  final String path;
  final String url;
  ListItem(this.path, {this.url});
  static getPhotosPathsList(List<ListItem> items){
    List <String> photoPaths = [];
    for(ListItem li in items){
      if(li is PhotoItem){
        photoPaths.add(li.path);
      }
    }
    return photoPaths;
  }

}

class PhotoItem implements ListItem {
  final String path;
  final String url;
  PhotoItem(this.path, {this.url});
}

class AudioItem implements ListItem {
  final String path;
  final String url;
  bool is_playing;
  AudioItem(this.path, this.is_playing, {this.url});
}