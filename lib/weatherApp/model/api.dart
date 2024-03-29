import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class API{
  final Dio _dio = Dio();

  API(){

    _dio.options.baseUrl = "https://api.open-meteo.com/v1";
    _dio.interceptors.add(PrettyDioLogger());

  }

  Dio get sendRequests => _dio;
}