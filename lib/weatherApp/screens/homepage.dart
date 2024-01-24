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
  double? temperatureCelsius = 0.0;
  int offsetSeconds = 0;
  DateTime localTime = DateTime.now();

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
        double? temperatureKelvin = postModel.main!.temp!.toDouble();
        temperatureCelsius = temperatureKelvin! - 273.15;

        offsetSeconds = postModel.timezone!;
        DateTime utcTime = DateTime.now().toUtc();
        Duration offsetDuration = Duration(seconds: offsetSeconds);
        localTime = utcTime.add(offsetDuration);
        setState(() {
          city = cityName;
        });

        print('Temperature for $cityName (Kelvin): $temperatureKelvin');
        print('Temperature for $cityName (Celsius): $temperatureCelsius');
      } else {
        print('No temperature data available for $cityName');
      }
    } catch (e) {
      print('Error getting weather data: $e');
      // Handle the error and show a message to the user
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
    await getWeather(city);
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
      String? imagePath;
      Color textColor = Colors.white;

      if (localTime.hour >= 19 || localTime.hour < 5) {
        imagePath = 'lib/weatherAssets/night.jpg';
      } else {
        imagePath = 'lib/weatherAssets/sunny.jpg';
      }
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath ?? ''),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 100, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  city,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: textColor),
                ),Text(
                  '${temperatureCelsius?.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _textEditingController,
                  style: TextStyle(color: Colors.white), // Set text color to white
                  decoration: InputDecoration(
                    labelText: 'Enter City Name',
                    hintText: 'e.g Lahore',
                    labelStyle: TextStyle(color: Colors.white), // Set label color to white
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), // Set hint color to semi-transparent white
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white), // Set border color to white
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white), // Set focused border color to white
                    ),
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
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // Set button background color to white
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.black), // Set button text color to black
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
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
