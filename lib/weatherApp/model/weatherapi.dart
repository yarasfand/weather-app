import 'package:dio/dio.dart';
import 'package:weatherapp/weatherApp/model/postModels.dart';

import 'api.dart';

class GetWeatherUpdate {
  API api = API();

  Future<WeatherModel> fetchWeather(String lat, String long) async {
    try {
      Response response = await api.sendRequests.get("/forecast?latitude=$lat&longitude=$long&current=temperature_2m,wind_speed_10m&hourly=temperature_2m,wind_speed_10m,weather_code&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset");
      Map<String, dynamic> postMap = response.data;
      return WeatherModel.fromJson(postMap);
    } catch (err) {
      throw (err);
    }
  }
}