import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherapp/weatherApp/controller/data_loader_bloc.dart';
import 'package:weatherapp/weatherApp/model/weatherapi.dart';
import 'package:weatherapp/weatherApp/view/homepage.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => WeatherBloc(GetWeatherUpdate()),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
