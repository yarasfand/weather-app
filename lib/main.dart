import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherapp/weatherApp/controller/data_loader_bloc.dart';
import 'package:weatherapp/weatherApp/model/weatherapi.dart';
import 'package:weatherapp/weatherApp/view/homepage.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => WeatherBloc(GetWeatherUpdate()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
