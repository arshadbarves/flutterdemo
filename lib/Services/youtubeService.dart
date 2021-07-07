import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:videodown/Models/ydMReponse.dart';

class YouTubeService {
  late Dio _dio;

  final baseUrl = "https://urlprocess.herokuapp.com/api/info?url=";

  YouTubeService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
    ));

    initializeInterceptor();
  }
  Future<List<VideoList>> getRequest(String endPoint) async {
    Response response;

    try {
      response = await Dio().get(baseUrl + endPoint);
    } on DioError catch (e) {
      print(e.message);
      throw Exception(e.message);
    }
    var jsonData = json.decode(response.toString());
    List<VideoList> downloadOptions = [];

    for (var d in jsonData['info']['formats']) {
      VideoList downloadOption = VideoList(
          d['ext'],
          d['filesize'] != null ? d['filesize'] : 0,
          d['format'],
          d['format_id'],
          d['quality'] != null ? d['quality'] : 0,
          d['url']);
      downloadOptions.add(downloadOption);
    }

    return downloadOptions;
  }

  // dataProcess(Response response) {
  //   var jsonData = json.decode(response.toString());
  //   List<VideoList> downloadOptions = [];

  //   for (var d in jsonData['info']['formats']) {
  //     VideoList downloadOption = VideoList(
  //         d['ext'],
  //         d['filesize'] != null ? d['filesize'] : 0,
  //         d['format'],
  //         d['format_id'],
  //         d['quality'] != null ? d['quality'] : 0,
  //         d['url']);
  //     downloadOptions.add(downloadOption);
  //   }
  //   print(downloadOptions.length);
  //   return downloadOptions;
  // }

  initializeInterceptor() {
    _dio.interceptors
        .add(InterceptorsWrapper(onError: (error, errorInterceptorHandler) {
      print(error.message);
    }, onRequest: (request, requestInterceptorHandler) {
      print("${request.method} | ${request.path}");
    }, onResponse: (response, responseInterceptorHandler) {
      print('${response.statusCode} ${response.statusCode} ${response.data}');
    }));
  }
}
