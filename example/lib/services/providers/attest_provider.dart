import 'dart:io';

import 'package:dio/dio.dart';

class AttestProvider {


  late Dio _dio;
  late String _baseURl;

  AttestProvider() {
    BaseOptions options = BaseOptions(
      // receiveTimeout: 15000,
      // connectTimeout: 15000,
      // headers: {
      //   "ignoreToken": true,
      //   "Access-Control-Allow-Origin": "*", // Required for CORS support to work
      //   "Access-Control-Allow-Credentials": true, // Required for cookies, authorization headers with HTTPS
      //   "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
      //   "Access-Control-Allow-Methods": "GET, POST, OPTIONS"
      // },
        contentType: ContentType.parse('application/json').toString());
    _dio = Dio(options);
    _baseURl = 'http://192.168.15.130:3001';
  }


  Future<String> getSession() async {
    try {
      String route = '$_baseURl/attest/getSession';

      final Response response = await _dio.get(route);

      if (response.statusCode != 200) {
        throw HttpException(response.statusMessage!);
      }

      return response.toString();
    } on DioException {
      rethrow;
    }
  }

}