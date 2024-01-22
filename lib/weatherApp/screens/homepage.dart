import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../model/postModels.dart';
import '../model/weatherapi.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool locationError = false;
  double? currentLat;
  double? currentLong;
  String currentLocation = "";
  String city = "";
  double cityTemp = 0.0;

  Future<void> checkLocationPermission() async {
    Geolocator.getServiceStatusStream().listen((status) {
      if (mounted) {
        setState(() {
          locationError = status != ServiceStatus.enabled;
        });
      }
    });
  }

  Future<void> checkLocationPermissionAndFetchLocation() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      try {
        final data = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        if (mounted) {
          currentLat = data.latitude;
          currentLong = data.longitude;
          await getAddress(currentLat!, currentLong!);
          locationError = false;
        }
      } catch (e) {
        print('Error getting location: $e');
      }
    } else {
      if (mounted) {
        locationError = true;
      }
    }
  }

  Future<void> getAddress(double lat, double long) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, long);
      if (mounted && placemarks.isNotEmpty) {
        String Street = "";
        String SubLocality = "";
        String countryName = "";
        setState(() {
          if (placemarks[3].street != null) {
            Street = placemarks[2].street!;
          }
          if (placemarks[3].subLocality != null) {
            SubLocality = placemarks[3].subLocality!;
          }
          if (placemarks[4].locality != null) {
            city = placemarks[4].locality!;
          }
          final List<String> countryNameParts = [];
          if (placemarks[4].locality != null) {
            countryNameParts.add(placemarks[4].locality!);
          }
          if (placemarks[0].country != null) {
            countryNameParts.add(placemarks[0].country!);
          }
          countryName = countryNameParts.join(', ');
        });
        currentLocation = "${Street} ${SubLocality} ${countryName}";
        print("${currentLocation}");
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  Future<void> getWeather(String cityName) async {
    print('Fetching weather for $cityName');
    try {
      PostRepository postRepository = PostRepository();
      PostModels postModel = await postRepository.fetchPosts(cityName);

      if (postModel.main != null) {
        double? temperatureKelvin = postModel.main!.temp;
        double? temperatureCelsius = temperatureKelvin! - 273.15;

        print('Temperature for $cityName (Kelvin): $temperatureKelvin');
        print('Temperature for $cityName (Celsius): $temperatureCelsius');
      } else {
        print('No temperature data available for $cityName');
      }
    } catch (e) {
      print('Error getting weather data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeLocation();
  }

  Future<void> initializeLocation() async {
    await checkLocationPermission();
    await checkLocationPermissionAndFetchLocation();
  }

  Widget build(BuildContext context) {
    TextEditingController _textEditingController = TextEditingController();
    String _enteredText = '';
    if (locationError) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Fetching Location..."),
            ],
          ),
        ),
      );
    } else if (currentLat != null && currentLong != null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Weather App'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  labelText: 'Enter text',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _enteredText = _textEditingController.text;
                    print('$_enteredText');
                    getWeather(_enteredText);
                  });
                },
                child: Text('Submit'),
              ),
              SizedBox(height: 16),
              Text(
                'Entered Text: $_enteredText',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    } else {
      checkLocationPermission();
      checkLocationPermissionAndFetchLocation();
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Fetching Location..."),
            ],
          ),
        ),
      );
    }
  }
}
