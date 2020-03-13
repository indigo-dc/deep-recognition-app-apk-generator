import 'package:path/path.dart' as path;
import 'dart:io';

class FileDownloader {
  static Future<String> downloadFile(String url) async {
    HttpClient client = new HttpClient();
    client.getUrl(Uri.parse(url)).then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final timestampString = timestamp.toString();
      return response.pipe(new File(timestampString + path.extension(url)).openWrite());
    }).then((f){
      print(f);
    });
  }
}