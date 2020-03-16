import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileDownloader {
  static bool isAcceptedAudioFile(String url) {
    if(path.extension(url) == ".mp3") {
      return true;
    } else {
      return false;
    }
  }

  static bool isAcceptedImageFile(String url) {
    if(path.extension(url) == ".jpg" || path.extension(url) == ".png") {
      return true;
    } else {
      return false;
    }
  }

  static Future<String> downloadFile(String url) async {
    Dio dio = Dio();
    try{
      final dir = await getTemporaryDirectory();
      final dirPath = dir.path;
      final fileName = path.basename(url);
      final filePath = "$dirPath/$fileName";
      await dio.download(url, filePath);
      return filePath;
    }catch(e) {
     print(e);
    }
    return null;
  }
}