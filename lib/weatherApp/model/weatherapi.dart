import 'package:dio/dio.dart';
import 'package:weatherapp/weatherApp/model/postModels.dart';

import 'api.dart';
class PostRepository {
  API api = API();

  Future<PostModels> fetchPosts(String cityName) async {
    try {
      Response response = await api.sendRequests.get("/weather?q=$cityName&appid=bd5e378503939ddaee76f12ad7a97608");
      Map<String, dynamic> postMap = response.data;
      return PostModels.fromJson(postMap);
    } catch (err) {
      throw (err);
    }
  }
}