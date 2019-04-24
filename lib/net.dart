import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gbk2utf8/gbk2utf8.dart';

class NetUtils {
  static Dio createDio() {
    Dio dio = Dio();
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
    dio.options.contentType = ContentType.parse("application/x-www-form-urlencoded");
    dio.options.responseType = ResponseType.json;
    return dio;
  }
  static Future<String> query(String url, {Map<String, dynamic> queryParameters}) async {
    Dio dio = createDio();
    Response response = await dio.get(url, queryParameters: queryParameters);
    return response.data;
  }

  static Future<String> queryUri(Uri uri) async {
    Dio dio = createDio();
    Response response = await dio.getUri(uri);
    return gbk.decode(response.data);
  }

  static HttpClient createHttpClient() {
    HttpClient httpClient = HttpClient();
    httpClient.findProxy = (uri) {
      return "PROXY 192.168.20.254:8888";
    };
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };
    return httpClient;
  }
  static Future<String> clientQuery(String url) async {
    HttpClient httpClient = createHttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    Future<String> result = response.transform(gbk.decoder).join();
    httpClient.close();
    return result;
  }
}