import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../model/postModels.dart';
import '../model/weatherapi.dart';

part 'data_loader_event.dart';
part 'data_loader_state.dart';


class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetWeatherUpdate getWeatherUpdate;

  WeatherBloc(this.getWeatherUpdate) : super(WeatherInitialState()) {
    on<FetchWeatherEvent>((event, emit) async {
      emit(WeatherLoadingState());
      try {
        WeatherModel weatherInfo = await getWeatherUpdate.fetchWeather(event.lat, event.long);
        if (weatherInfo.current != null && weatherInfo.hourlyUnits != null) {
          emit(WeatherLoadedState(weatherInfo));
        }
      } catch (error) {
        emit(WeatherErrorState(error.toString()));
      }
    });
  }
}

