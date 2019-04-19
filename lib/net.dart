import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gbk2utf8/gbk2utf8.dart';

class NetUtils {
  static Future<String> query(String url) async {
//    http.Response dd = await http.get(url);
//    return decodeGbk(dd.bodyBytes);
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
    Response response = await dio.get(url);
    return decodeGbk(response.data);
  }
}