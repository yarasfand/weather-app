part of 'data_loader_bloc.dart';

@immutable
abstract class WeatherEvent {}

class FetchWeatherEvent extends WeatherEvent {
  final String lat;
  final String long;

  FetchWeatherEvent(this.lat, this.long);
}