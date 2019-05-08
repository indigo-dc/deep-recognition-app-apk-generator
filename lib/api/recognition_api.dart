import 'package:deep_app/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';


class RecognitionApi{
  final String server = AppStrings.api_url;

  Future<String> postTask(List<String> photoPaths) async {
    var url = server + AppStrings.post_endpoint;
    var uri = Uri.parse(url);
    var request = http.MultipartRequest("POST", uri);
    for(String p in photoPaths){
      request.files.add(await http.MultipartFile.fromPath("data", p, contentType: MediaType('image', 'jpeg')));
    }
    var streamedResponse = await request.send().catchError((Object error){
      throw AppStrings.network_exception_message;
    });

    if(streamedResponse.statusCode == 200){
      http.Response response = await http.Response.fromStream(streamedResponse);
      return response.body;
    }else{
      final ne = AppStrings.network_error;
      final ec = streamedResponse.statusCode.toString();
      throw '$ne: $ec';
    }
  }

}