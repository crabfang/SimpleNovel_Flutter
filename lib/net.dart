import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gbk2utf8/gbk2utf8.dart';

class NetUtils {
  static Dio createDio() {
    Dio dio = new Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
      client.findProxy = (uri) {
        return "PROXY 192.168.20.254:8888";
      };
    };
    dio.interceptors.add(LogInterceptor());
    dio.options.connectTimeout = 5000;
    dio.options.responseType = ResponseType.bytes;
    return dio;
  }
  static Future<String> query(String url, {Map<String, dynamic> queryParameters}) async {
    Dio dio = createDio();
    Response response = await dio.get(url, queryParameters: queryParameters);
    return gbk.decode(response.data);
  }

  static Future<String> queryUri(Uri uri) async {
    Dio dio = createDio();
    Response response = await dio.getUri(uri);
    return gbk.decode(response.data);
  }
}