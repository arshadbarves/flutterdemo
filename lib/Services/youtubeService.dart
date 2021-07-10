import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:videodown/Models/yDMVideoResponse.dart';

class YouTubeService {
  late Dio _dio;
  Map videoType = {
    '249': '57 KBPS',
    '250': '75 KBPS',
    '140': '129 KBPS',
    '251': '146 KBPS',
    '394': '144P HDR',
    '160': '144P',
    '278': '144P',
    '694': '144P HDR (60FPS)',
    '330': '144P HDR (60FPS)',
    '395': '240P HDR',
    '242': '240P',
    '133': '240P',
    '695': '240P HDR (60FPS)',
    '331': '240P HDR (60FPS)',
    '396': '360P HDR',
    '243': '360P',
    '134': '360P',
    '696': '360P HDR (60FPS)',
    '332': '360P HDR (60FPS)',
    '397': '480P HDR',
    '244': '480P',
    '135': '480P',
    '697': '480P HDR (60FPS)',
    '333': '480P HDR (60FPS)',
    '398': '720P HDR (60FPS)',
    '247': '720P',
    '136': '720P',
    '302': '720P (60FPS)',
    '298': '720P (60FPS)',
    '698': '720P HDR (60FPS)',
    '334': '720P (60FPS)',
    '399': '1080P HDR (60FPS)',
    '303': '1080P (60FPS)',
    '299': '1080P (60FPS)',
    '248': '1080P HDR (30FPS)',
    '699': '1080P HDR (60FPS)',
    '335': '1080P HDR (60FPS)',
    '137': '1080P HDR (30FPS)',
    '400': '1440P HDR (60FPS)',
    '308': '1440P (60FPS)',
    '700': '1440P HDR (60FPS)',
    '336': '1440P HDR (60FPS)',
    '401': '2160P HDR (60FPS)',
    '701': '2160P HDR (60FPS)',
    '315': '2160P (60FPS)',
    '337': '2160P HDR (60FPS)',
    '571': '4320P - 4K (60FPS)',
    '703': '4320P HDR (60FPS)',
    '702': '4320P HDR (60FPS)',
    '18': '360P',
    '22': '720P',
  };

  final baseUrl = "https://urlprocess.herokuapp.com/api/info?url=";

  YouTubeService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
    ));

    initializeInterceptor();
  }
  Future<List<VideoDetails>> getRequest(String endPoint) async {
    Response response;
    List<VideoDetails> videoDetails = [];
    List<VideoFormat> videoOptions = [];
    List<AudioFormat> audioOptions = [];

    try {
      response = await Dio().get(baseUrl + endPoint);
    } on DioError catch (e) {
      print(e.message);
      throw Exception(e.message);
    }

    var jsonData = json.decode(response.toString());
    if (jsonData.containsKey('error')) {
      VideoDetails videoDetail = VideoDetails(
          'Null', 'Null', 'Null', videoOptions, false, jsonData['error']);
      videoDetails.add(videoDetail);
    } else if (jsonData['info'].containsKey('formats')) {
      for (var video in jsonData['info']['formats']) {
        String? videoID = video['format_id'];

        VideoFormat videoOption = VideoFormat(
            video['format_id'],
            video['filesize'] != null ? video['filesize'] : 0,
            videoType.containsKey(videoID) ? videoType['$videoID'] : 'Unknown',
            video['ext'] != null ? video['ext'] : 'Unknown',
            video['url']);
        videoOptions.add(videoOption);
      }
      VideoDetails videoDetail = VideoDetails(
          jsonData['url'],
          jsonData['info']['title'],
          jsonData['info']['thumbnail'],
          videoOptions,
          true,
          'Successfull');
      videoDetails.add(videoDetail);
    } else {
      VideoDetails videoDetail = VideoDetails(
          'Null', 'Null', 'Null', videoOptions, false, 'Invalid Url');
      videoDetails.add(videoDetail);
    }

    return videoDetails;
  }

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
