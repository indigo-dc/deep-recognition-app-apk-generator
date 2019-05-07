import 'package:deep_app/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class RecognitionApi{
  final String server = AppStrings.api_url;

  postTask(List<String> photoPaths) async {
    var url = server + AppStrings.post_endpoint;
    var uri = Uri.parse(url);
    var request = http.MultipartRequest("POST", uri);
    for(String p in photoPaths){
      request.files.add(await http.MultipartFile.fromPath("data", p));
    }
    var response = await request.send();
    if(response.statusCode == 200){
      //print("Uploaded");
      //final parsed = json.decode(response.toString());
      //print(parsed);
    }
  }

}