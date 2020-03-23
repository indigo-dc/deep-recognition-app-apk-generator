import 'package:deep_app/analysis/list_item.dart';
import 'package:deep_app/analysis/task.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;


class RecognitionApi{
  final String server = AppStrings.api_url;
  //final String server = "http://192.168.0.21:5000/";

  Future<PredictResponse> postPredictUrl(Map queryMap) async {
    try{
      Dio dio = Dio();
      String url = server + AppStrings.post_endpoint;
      Response response = await dio.post(url, queryParameters: queryMap, options: Options(headers: {"Accept" : "application/json"}));
      return PredictResponse.fromJson(response.data);
    } catch(e) {
      return Future.error(e);
    }
  }

  Future<PredictResponse> postPredictData(List dataInputs, Map queryMap) async{
    try{
      Dio dio = Dio();
      String url = server + AppStrings.post_endpoint;
      FormData formData = FormData();
      for(ListItem li in dataInputs) {
        MediaType mediaType;
        if(li is PhotoItem) {
          mediaType = MediaType('image', 'jpeg');
        }else {
          //TODO
        }
        formData.files.add(MapEntry("data", MultipartFile.fromFileSync(li.path, filename: path.basename(li.path), contentType: mediaType)));
      }
      Response response = await dio.post(url, queryParameters: queryMap, data: formData, options: Options(headers: {"Accept" : "application/json", "Content-Type" : "multipart/form-data"}));
      return PredictResponse.fromJson(response.data);
    } catch(e) {
      return Future.error(e);
    }
  }

}