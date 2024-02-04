part of 'data_loader_bloc.dart';

@immutable
abstract class WeatherState {}

class WeatherInitialState extends WeatherState {}

class WeatherLoadingState extends WeatherState {}

class WeatherLoadedState extends WeatherState {
  final WeatherModel weather;

  WeatherLoadedState(this.weather);
}

class WeatherErrorState extends WeatherState {
  final String error;

  WeatherErrorState(this.error);
}